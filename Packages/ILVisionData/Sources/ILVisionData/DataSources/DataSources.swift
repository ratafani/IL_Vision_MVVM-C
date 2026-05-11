import Foundation
import ILVisionDomain

/// Protocol for the raw data source
public protocol DrawingSettingsDataSource {
    func getSelectedColor() -> DrawColor
    func setSelectedColor(_ value: DrawColor)
    
    func getStrokeWidth() -> Float
    func setStrokeWidth(_ value: Float)
}

/// Concrete implementation backed by UserDefaults
public class DrawingSettingsDataSourceImpl: DrawingSettingsDataSource {
    private let defaults = UserDefaults.standard
    
    private let colorKey = "drawing_selectedColor"
    private let strokeWidthKey = "drawing_strokeWidth"
    
    public init() {}
    
    public func getSelectedColor() -> DrawColor {
        guard let raw = defaults.string(forKey: colorKey),
              let color = DrawColor(rawValue: raw) else {
            return .white
        }
        return color
    }
    
    public func setSelectedColor(_ value: DrawColor) {
        defaults.set(value.rawValue, forKey: colorKey)
    }
    
    public func getStrokeWidth() -> Float {
        let val = defaults.float(forKey: strokeWidthKey)
        return val == 0.0 ? 0.005 : val // default 5mm
    }
    
    public func setStrokeWidth(_ value: Float) {
        defaults.set(value, forKey: strokeWidthKey)
    }
}
