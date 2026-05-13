import SwiftUI
import ILVisionDomain
import ILVisionCore
import ILVisionData

public struct DrawingControlView: View {
    @Environment(AppModel.self) var appModel
    @Environment(AppCoordinator.self) var coordinator
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: DrawingViewModel?
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            // Color palette
            if let vm = viewModel {
                ForEach(DrawColor.allCases) { color in
                    Button {
                        vm.selectedColor = color
                    } label: {
                        Circle()
                            .fill(color.uiColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: vm.selectedColor == color ? 3 : 0)
                            )
                            .scaleEffect(vm.selectedColor == color ? 1.15 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: vm.selectedColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider().frame(height: 30)

            // Undo button
            Button {
                undoLastAction()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel?.strokeCount == 0)

            // Clear button
            Button {
                clearCanvas()
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            
            Divider().frame(height: 30)
            
            // Playback Toggle
            Button {
                viewModel?.togglePlayback()
            } label: {
                Label(appModel.isPlaybackActive ? "Stop" : "Play", 
                      systemImage: appModel.isPlaybackActive ? "stop.fill" : "play.fill")
            }
            .buttonStyle(.bordered)
            .tint(appModel.isPlaybackActive ? .orange : .blue)
            
            if appModel.isPlaybackActive {
                Slider(value: Bindable(appModel).playbackProgress, in: 0...1)
                    .frame(width: 150)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            Divider().frame(height: 30)
            
            // Exit button
            Button(role: .destructive) {
                exitDrawing()
            } label: {
                Label("Exit", systemImage: "xmark.circle.fill")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onAppear {
            viewModel = DrawingViewModel(
                useCase: ILVisionInjection.shared.useCase,
                appModel: appModel
            )
        }
        .onDisappear {
            viewModel?.stopPlayback()
        }
    }
    
    private func clearCanvas() {
        // 1. Tell Simulation to remove entities
        appModel.isRequestingClear = true
        
        // 2. Broadcast clear to SharePlay
        let manager = ILVisionInjection.shared.sharePlayManager
        if manager.isSharing {
            let msg = StrokeMessage.clear(senderID: manager.localParticipantID)
            Task { await manager.sendStroke(msg) }
        }
        
        // 3. Reset local counts
        viewModel?.strokeCount = 0
        
        // Note: We do NOT call historyRepository.clearHistory() here,
        // so that 'Play' still works after 'Clear'.
    }
    
    private func undoLastAction() {
        let manager = ILVisionInjection.shared.sharePlayManager
        Task {
            await manager.undo()
            if let count = viewModel?.strokeCount {
                viewModel?.strokeCount = max(0, count - 1)
            }
        }
    }
    
    private func exitDrawing() {
        viewModel?.stopPlayback()
        Task {
            await coordinator.endSimulation(
                dismissImmersiveSpace: dismissImmersiveSpace,
                openWindow: openWindow,
                dismiss: dismiss
            )
        }
    }
}
