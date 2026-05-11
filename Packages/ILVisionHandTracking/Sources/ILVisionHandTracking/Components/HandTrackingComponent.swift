import RealityKit
import ARKit

public struct HandTrackingComponent: Component {
    public var chirality: HandAnchor.Chirality
    public var isGrabbing: Bool = false
    
    // Store relevant joint positions for control interaction
    public var wristPosition: SIMD3<Float> = .zero
    public var palmPosition: SIMD3<Float> = .zero
    
    // For relative movement (e.g. throttle)
    public var initialGrabPosition: SIMD3<Float>? = nil
    
    // Finger states for debugging
    public var thumbCurled: Bool = false
    public var indexCurled: Bool = false
    public var middleCurled: Bool = false
    public var ringCurled: Bool = false
    public var pinkyCurled: Bool = false
    
    // Anti-jitter
    public var grabFrameCount: Int = 0
    public var isGrabbingFiltered: Bool = false
    
    public init(chirality: HandAnchor.Chirality) {
        self.chirality = chirality
    }
}
