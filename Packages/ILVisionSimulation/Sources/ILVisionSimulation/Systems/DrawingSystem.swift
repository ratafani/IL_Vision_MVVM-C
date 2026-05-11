import RealityKit
import UIKit
import ARKit
import ILVisionHandTracking
import ILVisionDomain
import ILVisionData
import ILVisionCore

/// Per-frame system:
/// 1. Reads raw hand skeleton from HandTrackingSystem (toolkit)
/// 2. Detects "pinky extended, all others curled" gesture
/// 3. Reads current color/width from AppModel via AppModelServiceComponent
/// 4. Spawns glowing spheres at pinky tip position on the canvas
/// 5. Synchronizes strokes via SharePlayManager
@MainActor
public struct DrawingSystem: System {
    public static let drawQuery = EntityQuery(where: .has(DrawingComponent.self))
    public static let canvasQuery = EntityQuery(where: .has(CanvasComponent.self))
    public static let receiverQuery = EntityQuery(where: .has(SharePlayReceiverComponent.self))
    
    /// Min distance between spawned spheres (prevents stacking)
    public static let minSpacing: Float = 0.003
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let drawEntities = context.entities(matching: Self.drawQuery, updatingSystemWhen: .rendering)
        let canvasEntities = context.entities(matching: Self.canvasQuery, updatingSystemWhen: .rendering)
        let receiverEntities = context.entities(matching: Self.receiverQuery, updatingSystemWhen: .rendering)
        
        guard let canvas = canvasEntities.first(where: { _ in true }) else { return }
        
        // 1. Process incoming SharePlay strokes
        if let receiver = receiverEntities.first(where: { _ in true }),
           let manager = receiver.components[SharePlayReceiverComponent.self]?.manager {
            let remoteStrokes = manager.consumeRemoteStrokes()
            for stroke in remoteStrokes {
                if stroke.action == .draw {
                    spawnDot(at: stroke.position, color: stroke.color, radius: stroke.radius, on: canvas)
                } else if stroke.action == .clear {
                    clearCanvas(canvas)
                }
            }
        }
        
        // 2. Handle local drawing
        for entity in drawEntities {
            guard var dc = entity.components[DrawingComponent.self] else { continue }
            
            // Read current preferences from AppModel
            if let serviceComp = entity.components[AppModelServiceComponent.self],
               let appModel = serviceComp.appModel {
                dc.currentColor = appModel.selectedColor.simdColor
                dc.sphereRadius = appModel.strokeWidth
            }
            
            // Get the right hand skeleton from the toolkit
            let anchor = HandTrackingSystem.latestRightHand
            guard let anchor, let skeleton = anchor.handSkeleton else {
                dc.isDrawing = false
                dc.pinkyFrameCount = 0
                dc.isPinkyFiltered = false
                entity.components.set(dc)
                continue
            }
            
            // Detect gesture: pinky NOT curled, everything else IS curled
            let isPinkyExtended = !HandPoseUtilities.isFingerCurled(
                skeleton: skeleton,
                tip: .littleFingerTip,
                knuckle: .littleFingerKnuckle
            )
            let thumbCurled = HandPoseUtilities.isThumbCurled(skeleton: skeleton)
            let indexCurled = HandPoseUtilities.isFingerCurled(
                skeleton: skeleton, tip: .indexFingerTip, knuckle: .indexFingerKnuckle
            )
            let middleCurled = HandPoseUtilities.isFingerCurled(
                skeleton: skeleton, tip: .middleFingerTip, knuckle: .middleFingerKnuckle
            )
            let ringCurled = HandPoseUtilities.isFingerCurled(
                skeleton: skeleton, tip: .ringFingerTip, knuckle: .ringFingerKnuckle
            )
            
            let pinkyGestureActive = isPinkyExtended && thumbCurled && indexCurled && middleCurled && ringCurled
            
            // Anti-jitter: require 3 consecutive frames
            if pinkyGestureActive {
                dc.pinkyFrameCount = min(dc.pinkyFrameCount + 1, 10)
            } else {
                dc.pinkyFrameCount = max(dc.pinkyFrameCount - 1, 0)
            }
            
            if dc.pinkyFrameCount >= 3 {
                dc.isPinkyFiltered = true
            } else if dc.pinkyFrameCount == 0 {
                dc.isPinkyFiltered = false
                dc.lastPlacedPosition = nil
            }
            
            dc.isDrawing = dc.isPinkyFiltered
            
            if dc.isDrawing {
                // Get pinky tip world position
                let tipPos = HandPoseUtilities.worldPosition(
                    of: .littleFingerTip,
                    handAnchor: anchor,
                    skeleton: skeleton
                )
                dc.pinkyTipPosition = tipPos
                
                // Only spawn if moved far enough from last placed sphere
                let shouldSpawn: Bool
                if let lastPos = dc.lastPlacedPosition {
                    shouldSpawn = simd_distance(tipPos, lastPos) > Self.minSpacing
                } else {
                    shouldSpawn = true
                }
                
                if shouldSpawn {
                    spawnDot(at: tipPos, color: dc.currentColor, radius: dc.sphereRadius, on: canvas)
                    dc.lastPlacedPosition = tipPos
                    
                    // Send to SharePlay
                    let manager = ILVisionInjection.shared.sharePlayManager
                    if manager.isSharing {
                        let msg = StrokeMessage.draw(
                            senderID: manager.localParticipantID,
                            position: tipPos,
                            color: dc.currentColor,
                            radius: dc.sphereRadius
                        )
                        Task { await manager.sendStroke(msg) }
                    }
                    
                    // Update canvas stroke count
                    if var canvasComp = canvas.components[CanvasComponent.self] {
                        canvasComp.strokeCount += 1
                        canvas.components.set(canvasComp)
                    }
                }
            }
            
            entity.components.set(dc)
        }
    }
    
    /// Spawns a small glowing sphere at the given world position
    private func spawnDot(at position: SIMD3<Float>, color: SIMD4<Float>, radius: Float, on canvas: Entity) {
        var material = UnlitMaterial()
        material.color = .init(tint: .init(
            red: CGFloat(color.x),
            green: CGFloat(color.y),
            blue: CGFloat(color.z),
            alpha: CGFloat(color.w)
        ))
        
        let sphere = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )
        
        sphere.setPosition(position, relativeTo: nil)
        canvas.addChild(sphere)
    }
    
    private func clearCanvas(_ canvas: Entity) {
        canvas.children.removeAll()
    }
}
