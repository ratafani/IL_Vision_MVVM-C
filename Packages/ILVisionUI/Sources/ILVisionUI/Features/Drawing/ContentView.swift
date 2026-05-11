import SwiftUI
import ILVisionDomain
import ILVisionCore

public struct ContentView: View {
    @Environment(AppModel.self) var appModel
    @Environment(AppCoordinator.self) var coordinator
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 80))
                .foregroundStyle(.cyan.gradient)
                .padding(.top, 20)
            
            Text("Clean Spatial Draw")
                .font(.largeTitle.bold())
            
            Text("A modular clean architecture visionOS project")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Extend your pinky to draw", systemImage: "hand.point.up.left")
                Label("Curl all fingers to stop", systemImage: "hand.raised.slash")
                Label("Use the palette to change colors", systemImage: "paintpalette")
                Label("Share with others to draw together", systemImage: "person.2.fill")
            }
            .font(.body)
            .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack(spacing: 16) {
                // Main Start/Stop button
                Button {
                    handleToggle()
                } label: {
                    Text(appModel.immersiveSpaceState == .open ? "Exit Drawing" : "Start Drawing")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(appModel.immersiveSpaceState == .open ? .red : .cyan)
                .disabled(appModel.immersiveSpaceState == .inTransition)
                
                // Share button
                if appModel.immersiveSpaceState != .inTransition {
                    Button {
                        Task {
                            await coordinator.activateSharePlay()
                        }
                    } label: {
                        Image(systemName: "shareplay")
                            .font(.title3)
                            .padding(12)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())
                    .help("Start SharePlay")
                }
            }
        }
        .padding(32)
    }
    
    private func handleToggle() {
        Task {
            if appModel.immersiveSpaceState == .open {
                await coordinator.endSimulation(
                    dismissImmersiveSpace: dismissImmersiveSpace
                )
            } else if appModel.immersiveSpaceState == .closed {
                await coordinator.startSimulation(
                    openImmersiveSpace: openImmersiveSpace,
                    openWindow: openWindow
                )
            }
        }
    }
}
