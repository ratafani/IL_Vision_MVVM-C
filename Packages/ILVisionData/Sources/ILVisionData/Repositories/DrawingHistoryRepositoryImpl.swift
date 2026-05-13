import Foundation
import ILVisionDomain

@MainActor
public class DrawingHistoryRepositoryImpl: DrawingHistoryRepository {
    private var history: [StrokeMessage] = []
    
    public init() {}
    
    public func addStroke(_ message: StrokeMessage) {
        history.append(message)
    }
    
    public func getAllStrokes() -> [StrokeMessage] {
        return history
    }
    
    public func clearHistory() {
        history.removeAll()
    }
    
    public func undoLastStroke() {
        // Find the last stroke ID that was drawn
        if let lastDraw = history.last(where: { $0.action == .draw }),
           let strokeID = lastDraw.strokeID {
            // Remove all messages belonging to this specific stroke
            history.removeAll(where: { $0.strokeID == strokeID })
        } else {
            // Fallback: just remove the last draw if no strokeID exists
            if let lastIndex = history.lastIndex(where: { $0.action == .draw }) {
                history.remove(at: lastIndex)
            }
        }
    }
}
