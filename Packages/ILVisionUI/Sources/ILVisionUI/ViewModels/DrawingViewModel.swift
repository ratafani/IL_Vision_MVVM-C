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
    
    // --- CLEAN ARCHITECTURE: Playback Logic in ViewModel ---
    private var playbackTimer: Timer?
    
    public func togglePlayback() {
        appModel.isPlaybackActive.toggle()
        
        if appModel.isPlaybackActive {
            appModel.playbackProgress = 0.0
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    if self.appModel.playbackProgress < 1.0 {
                        self.appModel.playbackProgress += 0.01
                    } else {
                        self.stopPlayback()
                    }
                }
            }
        } else {
            stopPlayback()
        }
    }
    
    public func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        appModel.isPlaybackActive = false
        appModel.playbackProgress = 1.0
    }
}
