import Foundation
import ILVisionDomain

/// Repository implementation — delegates to data source
public class DrawingSettingsRepositoryImpl: DrawingSettingsRepository {
    private let dataSource: DrawingSettingsDataSource
    
    public init(dataSource: DrawingSettingsDataSource) {
        self.dataSource = dataSource
    }
    
    public func getSelectedColor() -> DrawColor {
        return dataSource.getSelectedColor()
    }
    
    public func setSelectedColor(_ value: DrawColor) {
        dataSource.setSelectedColor(value)
    }
    
    public func getStrokeWidth() -> Float {
        return dataSource.getStrokeWidth()
    }
    
    public func setStrokeWidth(_ value: Float) {
        dataSource.setStrokeWidth(value)
    }
}
