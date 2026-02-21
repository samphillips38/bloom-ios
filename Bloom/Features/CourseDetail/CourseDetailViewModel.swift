import SwiftUI

@MainActor
class CourseDetailViewModel: ObservableObject {
    @Published var course: CourseWithLevels?
    @Published var progress: [UserProgress] = []
    @Published var streak = 0
    @Published var energy = 5
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = APIClient.shared
    
    var nextLessonId: String? {
        guard let course = course else { return nil }
        
        // Find first incomplete lesson
        for level in course.levels {
            for lesson in level.lessons {
                if !isLessonCompleted(lesson.id) {
                    return lesson.id
                }
            }
        }
        
        // All complete, return first lesson
        return course.levels.first?.lessons.first?.id
    }
    
    func loadCourse(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            course = try await apiClient.getCourse(id: id)
            
            // Try to load progress (may fail if not authenticated)
            do {
                progress = try await apiClient.getCourseProgress(courseId: id)
                let stats = try await apiClient.getUserStats()
                streak = stats.streak?.currentStreak ?? 0
                energy = stats.energy
            } catch {
                // Progress requires auth, ignore if not available
                print("Progress not available: \(error)")
            }
        } catch {
            self.error = error.localizedDescription
            print("Failed to load course: \(error)")
        }
    }
    
    func isLessonCompleted(_ lessonId: String) -> Bool {
        progress.first { $0.lessonId == lessonId }?.completed ?? false
    }
    
    func isLessonUnlocked(lessonIndex: Int, levelIndex: Int) -> Bool {
        // First lesson is always unlocked
        if levelIndex == 0 && lessonIndex == 0 {
            return true
        }
        
        guard let course = course else { return false }
        
        // Check if previous lesson is completed
        if lessonIndex > 0 {
            let previousLesson = course.levels[levelIndex].lessons[lessonIndex - 1]
            return isLessonCompleted(previousLesson.id)
        }
        
        // First lesson of a new level - check last lesson of previous level
        if levelIndex > 0 {
            let previousLevel = course.levels[levelIndex - 1]
            if let lastLesson = previousLevel.lessons.last {
                return isLessonCompleted(lastLesson.id)
            }
        }
        
        return false
    }
}
