import ARKit
import simd

public enum HandPoseUtilities {
    public static func position(
        of joint: HandSkeleton.JointName,
        in skeleton: HandSkeleton
    ) -> SIMD3<Float> {
        let t = skeleton.joint(joint).anchorFromJointTransform
        return SIMD3<Float>(t.columns.3.x, t.columns.3.y, t.columns.3.z)
    }

    public static func worldPosition(
        of joint: HandSkeleton.JointName,
        handAnchor: HandAnchor,
        skeleton: HandSkeleton
    ) -> SIMD3<Float> {
        let anchorFromJoint = skeleton.joint(joint).anchorFromJointTransform
        let originFromJoint = handAnchor.originFromAnchorTransform * anchorFromJoint
        return SIMD3<Float>(
            originFromJoint.columns.3.x,
            originFromJoint.columns.3.y,
            originFromJoint.columns.3.z
        )
    }

    public static func curlRatio(
        skeleton: HandSkeleton,
        tip: HandSkeleton.JointName,
        knuckle: HandSkeleton.JointName,
        wrist: HandSkeleton.JointName = .wrist
    ) -> Float {
        let tipPos = position(of: tip, in: skeleton)
        let knucklePos = position(of: knuckle, in: skeleton)
        let wristPos = position(of: wrist, in: skeleton)
        let tipDist = simd_distance(tipPos, wristPos)
        let knuckleDist = simd_distance(knucklePos, wristPos)
        guard knuckleDist > 0.001 else { return 1.0 }
        return tipDist / knuckleDist
    }

    public static func isFingerCurled(
        skeleton: HandSkeleton,
        tip: HandSkeleton.JointName,
        knuckle: HandSkeleton.JointName,
        wrist: HandSkeleton.JointName = .wrist,
        factor: Float = 1.10
    ) -> Bool {
        curlRatio(skeleton: skeleton, tip: tip, knuckle: knuckle, wrist: wrist) < factor
    }

    public static func thumbCurlRatio(skeleton: HandSkeleton) -> Float {
        let thumbTip = position(of: .thumbTip, in: skeleton)
        let palmCenter = position(of: .middleFingerKnuckle, in: skeleton)
        let wrist = position(of: .wrist, in: skeleton)
        let thumbDist = simd_distance(thumbTip, palmCenter)
        let handSize = simd_distance(wrist, palmCenter)
        guard handSize > 0.001 else { return 1.0 }
        return thumbDist / handSize
    }

    public static func isThumbCurled(skeleton: HandSkeleton) -> Bool {
        thumbCurlRatio(skeleton: skeleton) < 0.75
    }
}
