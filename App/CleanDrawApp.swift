import SwiftUI
import RealityKit
import ILVisionDomain
import ILVisionCore
import ILVisionSimulation
import ILVisionUI
import ILVisionData

@main
@MainActor
struct CleanDrawApp: App {
    @State private var appModel = AppModel()
    @State private var coordinator: AppCoordinator
    
    init() {
        let model = AppModel()
        self._appModel = State(initialValue: model)
        self._coordinator = State(initialValue: AppCoordinator(appModel: model))
        
        // Register ECS Systems
        DrawingSystem.registerSystem()
        
        // Start SharePlay listener
        Task {    
            await ILVisionInjection.shared.sharePlayManager.startListening()
        }
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environment(appModel)
                .environment(coordinator)
        }
        .defaultSize(width: 480, height: 360)
        
        WindowGroup(id: "controls") {
            DrawingControlView()
                .environment(appModel)
                .environment(coordinator)
        }
        .defaultSize(width: 400, height: 100)
        
        ImmersiveSpace(id: "drawingSpace") {
            ImmersiveDrawingView()
                .environment(appModel)
                .environment(coordinator)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
