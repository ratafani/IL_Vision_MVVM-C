import SwiftUI
import Observation
import ILVisionDomain

@MainActor
@Observable
public class DrawingViewModel {
    private let useCase: DrawingSettingsUseCase
    private var appModel: AppModel
    
    public init(useCase: DrawingSettingsUseCase, appModel: AppModel) {
        self.useCase = useCase
        self.appModel = appModel
        
        // Sync appModel with saved settings on initialization
        self.appModel.selectedColor = useCase.getSelectedColor()
        self.appModel.strokeWidth = useCase.getStrokeWidth()
    }
    
    public var selectedColor: DrawColor {
        get { appModel.selectedColor }
        set {
            appModel.selectedColor = newValue
            useCase.setSelectedColor(newValue)
        }
    }
    
    public var strokeWidth: Float {
        get { appModel.strokeWidth }
        set {
            appModel.strokeWidth = newValue
            useCase.setStrokeWidth(newValue)
        }
    }
    
    public var strokeCount: Int {
        get { appModel.strokeCount }
        set { appModel.strokeCount = newValue }
    }
}
