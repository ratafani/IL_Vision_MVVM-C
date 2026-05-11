import Foundation
@preconcurrency import GroupActivities
import Combine
import ILVisionDomain

/// Defines the SharePlay activity for collaborative drawing
public struct DrawingActivity: GroupActivity {
    public static let activityIdentifier = "com.ratafani.SpatialDraw.drawing"
    
    public init() {}
    
    public var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "SpatialDraw"
        meta.subtitle = "Draw together in 3D space"
        meta.type = .generic
        meta.supportsContinuationOnTV = false
        return meta
    }
}

@MainActor
public class SharePlayManager: SharePlayRepository, ObservableObject {
    @Published public var isSharing: Bool = false
    public let localParticipantID = UUID()
    
    private var session: GroupSession<DrawingActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions = Set<AnyCancellable>()
    
    // Buffer for ECS system to consume (Accessed only on MainActor)
    private var remoteStrokeBuffer: [StrokeMessage] = []
    
    public init() {}
    
    public func consumeRemoteStrokes() -> [StrokeMessage] {
        let messages = remoteStrokeBuffer
        remoteStrokeBuffer.removeAll()
        return messages
    }
    
    // For the AsyncStream of incoming strokes
    private var strokeContinuation: AsyncStream<StrokeMessage>.Continuation?
    public lazy var incomingStrokes: AsyncStream<StrokeMessage> = {
        AsyncStream { continuation in
            self.strokeContinuation = continuation
        }
    }()
    
    public func startListening() async {
        for await session in DrawingActivity.sessions() {
            await configureSession(session)
        }
    }
    
    public func activateActivity() async {
        let activity = DrawingActivity()
        do {
            _ = try await activity.activate()
        } catch {
            print("Failed to activate SharePlay: \(error)")
        }
    }
    
    public func stopSharing() {
        session?.leave()
        session = nil
        messenger = nil
        isSharing = false
    }
    
    private func configureSession(_ session: GroupSession<DrawingActivity>) async {
        self.session = session
        let messenger = GroupSessionMessenger(session: session)
        self.messenger = messenger
        
        // Listen for strokes from others
        Task {
            for await (message, _) in messenger.messages(of: StrokeMessage.self) {
                // Since this Task inherits MainActor, we call it directly
                self.receiveMessage(message)
            }
        }
        
        // Handle session state changes
        session.$state.sink { state in
            if case .invalidated = state {
                Task { @MainActor in
                    self.stopSharing()
                }
            }
        }
        .store(in: &subscriptions)
        
        // Enable Spatial Personas (systemCoordinator is async)
        if let coordinator = await session.systemCoordinator {
            var configuration = SystemCoordinator.Configuration()
            configuration.supportsGroupImmersiveSpace = true
            coordinator.configuration = configuration
        }
        
        session.join()
        isSharing = true
    }
    
    /// Internal helper to update buffer on MainActor
    private func receiveMessage(_ message: StrokeMessage) {
        self.remoteStrokeBuffer.append(message)
        self.strokeContinuation?.yield(message)
    }
    
    public func sendStroke(_ message: StrokeMessage) async {
        guard let messenger = messenger else { return }
        try? await messenger.send(message)
    }
}
