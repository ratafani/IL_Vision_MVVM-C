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
            
            // Clear button
            Button {
                clearCanvas()
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            
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
    }
    
    private func clearCanvas() {
        let manager = ILVisionInjection.shared.sharePlayManager
        if manager.isSharing {
            let msg = StrokeMessage.clear(senderID: manager.localParticipantID)
            Task { await manager.sendStroke(msg) }
        }
        viewModel?.strokeCount = 0
    }
    
    private func exitDrawing() {
        Task {
            await coordinator.endSimulation(
                dismissImmersiveSpace: dismissImmersiveSpace,
                openWindow: openWindow,
                dismiss: dismiss
            )
        }
    }
}
