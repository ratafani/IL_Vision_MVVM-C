import Foundation
import ILVisionDomain
import ILVisionData

/// Dependency Injection container — wires DataSource → Repository → UseCase
@MainActor
public struct ILVisionInjection {
    public static let shared = ILVisionInjection()
    
    private let dataSource: DrawingSettingsDataSource
    private let repository: DrawingSettingsRepository
    public let useCase: DrawingSettingsUseCase
    public let sharePlayManager: SharePlayManager
    public let historyRepository: DrawingHistoryRepository
    
    private init() {
        let ds = DrawingSettingsDataSourceImpl()
        self.dataSource = ds
        let repo = DrawingSettingsRepositoryImpl(dataSource: ds)
        self.repository = repo
        self.useCase = DrawingSettingsUseCaseImpl(repository: repo)
        self.sharePlayManager = SharePlayManager()
        self.historyRepository = DrawingHistoryRepositoryImpl()
    }
}
