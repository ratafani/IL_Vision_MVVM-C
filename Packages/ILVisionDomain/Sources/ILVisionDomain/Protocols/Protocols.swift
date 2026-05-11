import Foundation

/// Domain-level protocol for persisting drawing preferences
public protocol DrawingSettingsRepository {
    func getSelectedColor() -> DrawColor
    func setSelectedColor(_ value: DrawColor)
    
    func getStrokeWidth() -> Float
    func setStrokeWidth(_ value: Float)
}

/// Domain-level protocol for SharePlay session management
@MainActor
public protocol SharePlayRepository: AnyObject {
    /// Whether a SharePlay session is currently active
    var isSharing: Bool { get }
    
    /// Unique ID for this local participant
    var localParticipantID: UUID { get }
    
    /// Start listening for incoming SharePlay sessions
    func startListening() async
    
    /// Activate a new SharePlay activity (invite others)
    func activateActivity() async
    
    /// Leave the current session
    func stopSharing()
    
    /// Send a stroke to all participants
    func sendStroke(_ message: StrokeMessage) async
    
    /// Stream of incoming strokes from other participants
    var incomingStrokes: AsyncStream<StrokeMessage> { get }
}
