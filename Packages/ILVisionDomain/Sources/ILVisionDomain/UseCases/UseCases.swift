import Foundation

/// Domain-level use case protocol
public protocol DrawingSettingsUseCase {
    func getSelectedColor() -> DrawColor
    func setSelectedColor(_ value: DrawColor)
    
    func getStrokeWidth() -> Float
    func setStrokeWidth(_ value: Float)
}

/// Concrete use case — delegates to the repository
public class DrawingSettingsUseCaseImpl: DrawingSettingsUseCase {
    private let repository: DrawingSettingsRepository
    
    public init(repository: DrawingSettingsRepository) {
        self.repository = repository
    }
    
    public func getSelectedColor() -> DrawColor {
        return repository.getSelectedColor()
    }
    
    public func setSelectedColor(_ value: DrawColor) {
        repository.setSelectedColor(value)
    }
    
    public func getStrokeWidth() -> Float {
        return repository.getStrokeWidth()
    }
    
    public func setStrokeWidth(_ value: Float) {
        repository.setStrokeWidth(value)
    }
}
