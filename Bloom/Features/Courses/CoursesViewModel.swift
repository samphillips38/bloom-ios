import SwiftUI

@MainActor
class CoursesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = APIClient.shared
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            categories = try await apiClient.getCategories()
            
            if let firstCategory = categories.first {
                selectedCategory = firstCategory
                await loadCourses(for: firstCategory.id)
            }
        } catch {
            self.error = error.localizedDescription
            print("Failed to load categories: \(error)")
        }
    }
    
    func selectCategory(_ category: Category) {
        selectedCategory = category
        Task {
            await loadCourses(for: category.id)
        }
    }
    
    private func loadCourses(for categoryId: String) async {
        do {
            let allCourses = try await apiClient.getCourses()
            courses = allCourses.filter { $0.categoryId == categoryId }
        } catch {
            self.error = error.localizedDescription
            print("Failed to load courses: \(error)")
        }
    }
}
