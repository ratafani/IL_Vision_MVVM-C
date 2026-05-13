import RealityKit
import Foundation
import ILVisionDomain
import ILVisionData

/// Bridges AppModel into the ECS world so Systems can read user preferences
public struct AppModelServiceComponent: Component {
    public weak var appModel: AppModel?
    
    public init(appModel: AppModel) {
        self.appModel = appModel
    }
}

public struct DrawingComponent: Component {
    public var isDrawing: Bool = false
    public var pinkyTipPosition: SIMD3<Float> = .zero
    public var lastPlacedPosition: SIMD3<Float>? = nil
    
    // Appearance
    public var currentColor: SIMD4<Float> = [1, 1, 1, 1]
    public var sphereRadius: Float = 0.005
    
    // Anti-jitter: require N consecutive frames before drawing starts
    public var pinkyFrameCount: Int = 0
    public var isPinkyFiltered: Bool = false
    
    /// Reference to the entity grouping current dots (used for flattening)
    public var currentStrokeEntity: Entity? = nil
    
    /// Unique ID for the current stroke (used for history grouping)
    public var currentStrokeID: UUID? = nil
    
    public init() {}
}

/// Marks the canvas root entity — all drawn spheres are children of this
public struct CanvasComponent: Component {
    public var strokeCount: Int = 0
    
    public init() {}
}

/// ECS component attached to the canvas to handle incoming SharePlay strokes
public struct SharePlayReceiverComponent: Component {
    public weak var manager: SharePlayManager?
    
    public init(manager: SharePlayManager) {
        self.manager = manager
    }
}

/// Stores simulation-side state for the playback animation
public struct PlaybackComponent: Component {
    public var isPlaying: Bool = false
    
    public init() {}
}
