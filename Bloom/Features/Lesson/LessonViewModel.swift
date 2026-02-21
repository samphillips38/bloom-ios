import SwiftUI

@MainActor
class LessonViewModel: ObservableObject {
    @Published var lesson: LessonWithContent?
    @Published var currentIndex = 0
    @Published var energy = 5
    @Published var isLoading = false
    @Published var error: String?
    @Published var answeredCorrectly = false
    
    private let apiClient = APIClient.shared
    
    var currentContent: LessonContent? {
        guard let lesson = lesson, currentIndex < lesson.content.count else { return nil }
        return lesson.content[currentIndex]
    }
    
    var isLastContent: Bool {
        guard let lesson = lesson else { return true }
        return currentIndex >= lesson.content.count - 1
    }
    
    var progress: Double {
        guard let lesson = lesson, !lesson.content.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(lesson.content.count)
    }
    
    var canContinue: Bool {
        guard let content = currentContent else { return false }
        
        switch content.contentData {
        case .question:
            return answeredCorrectly
        default:
            return true
        }
    }
    
    func loadLesson(id: String) async {
        guard !id.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            lesson = try await apiClient.getLesson(id: id)
            
            // Get user stats
            do {
                let stats = try await apiClient.getUserStats()
                energy = stats.energy
            } catch {
                print("Stats not available: \(error)")
            }
        } catch {
            self.error = error.localizedDescription
            print("Failed to load lesson: \(error)")
        }
    }
    
    func nextContent() {
        guard let lesson = lesson else { return }
        
        if currentIndex < lesson.content.count - 1 {
            currentIndex += 1
            answeredCorrectly = false
        }
    }
    
    func handleAnswer(_ index: Int) {
        guard let content = currentContent else { return }
        
        if case .question(let questionContent) = content.contentData {
            answeredCorrectly = (index == questionContent.correctIndex)
        }
    }
    
    func completeLesson() async {
        guard let lesson = lesson else { return }
        
        do {
            _ = try await apiClient.updateProgress(lessonId: lesson.id, completed: true, score: 100)
        } catch {
            print("Failed to update progress: \(error)")
        }
    }
}
