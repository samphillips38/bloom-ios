import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendedCourses: [Course] = []
    @Published var selectedCourseIndex = 0
    @Published var courseDetails: CourseWithLevels?
    @Published var currentStreak = 0
    @Published var energy = 5
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = APIClient.shared
    
    var selectedCourse: Course? {
        guard selectedCourseIndex < recommendedCourses.count else { return nil }
        return recommendedCourses[selectedCourseIndex]
    }
    
    var firstLessonId: String? {
        courseDetails?.levels.first?.lessons.first?.id
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            recommendedCourses = try await apiClient.getRecommendedCourses()
            
            if let firstCourse = recommendedCourses.first {
                courseDetails = try await apiClient.getCourse(id: firstCourse.id)
            }
        } catch {
            self.error = error.localizedDescription
            print("Failed to load home data: \(error)")
        }
    }
    
    func updateStats(_ stats: UserStats) {
        currentStreak = stats.streak?.currentStreak ?? 0
        energy = stats.energy
    }
    
    func selectCourse(at index: Int) {
        guard index < recommendedCourses.count else { return }
        selectedCourseIndex = index
        
        Task {
            do {
                courseDetails = try await apiClient.getCourse(id: recommendedCourses[index].id)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
