import SwiftUI
import RealityKit
import ARKit
import GroupActivities
import ILVisionHandTracking
import ILVisionDomain
import ILVisionCore
import ILVisionSimulation
import ILVisionData

public struct ImmersiveDrawingView: View {
    @Environment(AppModel.self) var appModel
    
    @State private var viewModel: DrawingViewModel?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            RealityView { content in
                // Initialize ViewModel with DI
                let vm = DrawingViewModel(
                    useCase: ILVisionInjection.shared.useCase,
                    appModel: appModel
                )
                viewModel = vm
                
                // 1. Start hand tracking session
                Task { await HandTrackingSystem.runSession() }
                
                // 2. Create hand tracking entities
                let rightHand = Entity()
                rightHand.name = "RightHand"
                rightHand.components.set(HandTrackingComponent(chirality: .right))
                content.add(rightHand)
                
                let leftHand = Entity()
                leftHand.name = "LeftHand"
                leftHand.components.set(HandTrackingComponent(chirality: .left))
                content.add(leftHand)
                
                // 3. Create the canvas
                let canvas = Entity()
                canvas.name = "Canvas"
                canvas.components.set(CanvasComponent())
                canvas.components.set(SharePlayReceiverComponent(manager: ILVisionInjection.shared.sharePlayManager))
                content.add(canvas)
                
                // 4. Create the draw controller entity
                var drawComp = DrawingComponent()
                drawComp.currentColor = appModel.selectedColor.simdColor
                drawComp.sphereRadius = appModel.strokeWidth
                
                let drawController = Entity()
                drawController.name = "DrawController"
                drawController.components.set(drawComp)
                drawController.components.set(AppModelServiceComponent(appModel: appModel))
                content.add(drawController)
            }
        }
    }
}
