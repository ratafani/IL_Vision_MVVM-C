import RealityKit
import ILVisionDomain
import ILVisionCore
import Foundation

/// Handles replaying the drawing animation incrementally to avoid system crashes
@MainActor
public struct PlaybackSystem: System {
    public static let canvasQuery = EntityQuery(where: .has(CanvasComponent.self))
    public static let appModelQuery = EntityQuery(where: .has(AppModelServiceComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let appModelEntities = context.entities(matching: Self.appModelQuery, updatingSystemWhen: .rendering)
        guard let appModelEntity = appModelEntities.first(where: { _ in true }),
              let appModel = appModelEntity.components[AppModelServiceComponent.self]?.appModel else { return }
        
        let canvasEntities = context.entities(matching: Self.canvasQuery, updatingSystemWhen: .rendering)
        guard let canvas = canvasEntities.first(where: { _ in true }) else { return }
        
        if !appModel.isPlaybackActive { return }
        
        // Re-render the canvas incrementally
        renderPlaybackIncremental(on: canvas, progress: appModel.playbackProgress)
    }
    
    private func renderPlaybackIncremental(on canvas: Entity, progress: Float) {
        let history = ILVisionInjection.shared.historyRepository.getAllStrokes().filter { $0.action == .draw }
        guard !history.isEmpty else { return }
        
        // Calculate how many dots should be visible
        let dotsToDraw = min(Int(Double(history.count) * Double(progress)), history.count)
        let currentCount = canvas.children.count
        
        // 1. If nothing changed, do nothing
        if dotsToDraw == currentCount { return }
        
        // 2. If progress went backward (scrubbing), we must clear and restart
        if dotsToDraw < currentCount {
            canvas.children.removeAll()
            for i in 0..<dotsToDraw {
                spawnDotFromHistory(history[i], on: canvas)
            }
        } 
        // 3. If progress went forward (standard playback), just add the new dots
        else {
            for i in currentCount..<dotsToDraw {
                spawnDotFromHistory(history[i], on: canvas)
            }
        }
    }
    
    private func spawnDotFromHistory(_ msg: StrokeMessage, on canvas: Entity) {
        DrawingSystem.spawnDot(
            at: msg.position,
            color: msg.color,
            radius: msg.radius,
            on: canvas
        )
    }
}
