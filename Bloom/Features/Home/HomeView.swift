import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with stats
                    headerView
                    
                    // Recommended Course Card
                    if let course = viewModel.recommendedCourses.first {
                        recommendedCourseCard(course)
                    }
                    
                    // Course pagination dots
                    if viewModel.recommendedCourses.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(0..<min(viewModel.recommendedCourses.count, 5), id: \.self) { index in
                                Circle()
                                    .fill(index == viewModel.selectedCourseIndex ? course.color : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    
                    // Lessons section
                    if let course = viewModel.selectedCourse {
                        lessonSection(course)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.bloomBackground)
            .refreshable {
                await viewModel.loadData()
            }
        }
        .task {
            await viewModel.loadData()
            if let stats = appState.userStats {
                viewModel.updateStats(stats)
            }
        }
    }
    
    private var course: Course {
        viewModel.recommendedCourses.first ?? Course(
            id: "",
            categoryId: "",
            title: "Loading...",
            description: nil,
            iconUrl: nil,
            themeColor: "#FF6B35",
            lessonCount: 0,
            exerciseCount: 0,
            isRecommended: true,
            collaborators: nil,
            orderIndex: 0
        )
    }
    
    private var headerView: some View {
        HStack {
            StatBadge(
                value: "\(viewModel.currentStreak)",
                icon: "flame.fill",
                color: .bloomOrange
            )
            
            Spacer()
            
            StatBadge(
                value: "\(viewModel.energy)",
                icon: "bolt.fill",
                color: .bloomYellow
            )
        }
        .padding(.top, 8)
    }
    
    private func recommendedCourseCard(_ course: Course) -> some View {
        NavigationLink(destination: CourseDetailView(courseId: course.id)) {
            VStack(spacing: 16) {
                // Recommended badge
                Text("RECOMMENDED")
                    .font(.bloomCaptionMedium)
                    .foregroundColor(course.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(course.color.opacity(0.15))
                    )
                
                // Course title
                Text(course.title)
                    .font(.bloomH2)
                    .foregroundColor(.bloomTextPrimary)
                    .multilineTextAlignment(.center)
                
                // Level indicator
                Text("LEVEL 1")
                    .font(.bloomLevelBadge)
                    .foregroundColor(course.color)
                
                // Course illustration
                ZStack {
                    Circle()
                        .fill(course.color.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(course.color)
                }
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func lessonSection(_ course: Course) -> some View {
        BloomCard {
            VStack(alignment: .leading, spacing: 16) {
                // First lesson row
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.bloomGreen.opacity(0.15))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "equal.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.bloomGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Similarity")
                            .font(.bloomBodyMedium)
                            .foregroundColor(.bloomTextPrimary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
                
                Divider()
                
                // Second lesson row
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    
                    Text("Forming Clusters")
                        .font(.bloomBody)
                        .foregroundColor(.bloomTextSecondary)
                    
                    Spacer()
                    
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
                
                // Start button
                NavigationLink(destination: LessonView(lessonId: viewModel.firstLessonId ?? "")) {
                    Text("Start")
                        .font(.bloomButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(course.color)
                                .shadow(color: course.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .disabled(viewModel.firstLessonId == nil)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
