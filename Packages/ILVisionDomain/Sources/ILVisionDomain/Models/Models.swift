import Foundation
import SwiftUI
import Observation

/// Data packet sent between devices via SharePlay
public struct StrokeMessage: Codable, Sendable {
    public let id: UUID
    public let senderID: UUID
    public let action: StrokeAction
    
    // Drawing data (only used when action == .draw)
    public let positionX: Float
    public let positionY: Float
    public let positionZ: Float
    public let colorR: Float
    public let colorG: Float
    public let colorB: Float
    public let colorA: Float
    public let radius: Float
    
    public enum StrokeAction: String, Codable, Sendable {
        case draw
        case clear
    }
    
    /// Convenience: create a draw message
    public static func draw(
        senderID: UUID,
        position: SIMD3<Float>,
        color: SIMD4<Float>,
        radius: Float
    ) -> StrokeMessage {
        StrokeMessage(
            id: UUID(),
            senderID: senderID,
            action: .draw,
            positionX: position.x,
            positionY: position.y,
            positionZ: position.z,
            colorR: color.x,
            colorG: color.y,
            colorB: color.z,
            colorA: color.w,
            radius: radius
        )
    }
    
    /// Convenience: create a clear message
    public static func clear(senderID: UUID) -> StrokeMessage {
        StrokeMessage(
            id: UUID(),
            senderID: senderID,
            action: .clear,
            positionX: 0, positionY: 0, positionZ: 0,
            colorR: 0, colorG: 0, colorB: 0, colorA: 0,
            radius: 0
        )
    }
    
    /// Reconstruct SIMD types
    public var position: SIMD3<Float> { [positionX, positionY, positionZ] }
    public var color: SIMD4<Float> { [colorR, colorG, colorB, colorA] }
}

@Observable
public class AppModel {
    public var immersiveSpaceState: ImmersiveSpaceState = .closed
    public var isSharing: Bool = false
    
    // Drawing settings (persisted via DI)
    public var selectedColor: DrawColor = .white
    public var strokeWidth: Float = 0.005
    public var strokeCount: Int = 0
    
    public init() {}
    
    public enum ImmersiveSpaceState {
        case closed, inTransition, open
    }
}

/// Predefined colors that look great as glowing dots in space
public enum DrawColor: String, CaseIterable, Identifiable, Codable {
    case white, red, cyan, yellow, green, purple
    
    public var id: String { rawValue }
    
    public var simdColor: SIMD4<Float> {
        switch self {
        case .white:  return [1.0, 1.0, 1.0, 1.0]
        case .red:    return [1.0, 0.2, 0.15, 1.0]
        case .cyan:   return [0.0, 0.9, 1.0, 1.0]
        case .yellow: return [1.0, 0.9, 0.1, 1.0]
        case .green:  return [0.2, 1.0, 0.4, 1.0]
        case .purple: return [0.7, 0.3, 1.0, 1.0]
        }
    }
    
    public var uiColor: Color {
        switch self {
        case .white:  return .white
        case .red:    return Color(red: 1.0, green: 0.2, blue: 0.15)
        case .cyan:   return Color(red: 0.0, green: 0.9, blue: 1.0)
        case .yellow: return Color(red: 1.0, green: 0.9, blue: 0.1)
        case .green:  return Color(red: 0.2, green: 1.0, blue: 0.4)
        case .purple: return Color(red: 0.7, green: 0.3, blue: 1.0)
        }
    }
    
    public var label: String { rawValue.capitalized }
}
