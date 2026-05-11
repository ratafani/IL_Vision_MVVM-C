import SwiftUI
import Observation
import ILVisionDomain
import ILVisionCore

@MainActor
@Observable
public class AppCoordinator {
    private var appModel: AppModel
    
    public init(appModel: AppModel) {
        self.appModel = appModel
    }
    
    public func startSimulation(
        openImmersiveSpace: OpenImmersiveSpaceAction,
        openWindow: OpenWindowAction
    ) async {
        appModel.immersiveSpaceState = .inTransition
        let result = await openImmersiveSpace(id: "drawingSpace")
        if result == .opened {
            appModel.immersiveSpaceState = .open
            openWindow(id: "controls")
        } else {
            appModel.immersiveSpaceState = .closed
        }
    }
    
    public func endSimulation(
        dismissImmersiveSpace: DismissImmersiveSpaceAction,
        openWindow: OpenWindowAction? = nil,
        dismiss: DismissAction? = nil
    ) async {
        appModel.immersiveSpaceState = .inTransition
        await dismissImmersiveSpace()
        appModel.immersiveSpaceState = .closed
        
        if let openWindow = openWindow {
            openWindow(id: "main")
        }
        
        if let dismiss = dismiss {
            dismiss()
        }
    }
    
    public func activateSharePlay() async {
        await ILVisionInjection.shared.sharePlayManager.activateActivity()
    }
}
