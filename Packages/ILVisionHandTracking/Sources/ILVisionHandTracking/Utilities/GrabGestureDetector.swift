import ARKit

// all fingers curled = grab
public struct GrabGestureDetector {
    public struct FingerStatus {
        public let index: Bool
        public let middle: Bool
        public let ring: Bool
        public let pinky: Bool
        public let thumb: Bool
        
        public var isGrabbing: Bool {
            // Relaxed logic: Thumb + Index + Middle is enough for a "grab"
            return thumb && index && middle
        }
    }

    public static func getDetails(skeleton: HandSkeleton) -> FingerStatus {
        let index  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .indexFingerTip,  knuckle: .indexFingerKnuckle)
        let middle = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .middleFingerTip, knuckle: .middleFingerKnuckle)
        let ring   = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .ringFingerTip,   knuckle: .ringFingerKnuckle)
        let pinky  = HandPoseUtilities.isFingerCurled(skeleton: skeleton, tip: .littleFingerTip, knuckle: .littleFingerKnuckle)
        let thumb  = HandPoseUtilities.isThumbCurled(skeleton: skeleton)
        
        return FingerStatus(index: index, middle: middle, ring: ring, pinky: pinky, thumb: thumb)
    }

    public static func isGrabbing(skeleton: HandSkeleton) -> Bool {
        return getDetails(skeleton: skeleton).isGrabbing
    }
}
