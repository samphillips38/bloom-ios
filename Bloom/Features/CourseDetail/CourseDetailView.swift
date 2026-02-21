import SwiftUI

struct CourseDetailView: View {
    let courseId: String
    @StateObject private var viewModel = CourseDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showOverview = false
    
    var body: some View {
        ZStack {
            // Background gradient based on course color
            LinearGradient(
                colors: [courseColor.opacity(0.15), Color.bloomBackground],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with stats
                    headerView
                    
                    // Course icon and level badge
                    VStack(spacing: 20) {
                        // Course illustration
                        courseIllustration
                            .onTapGesture {
                                showOverview = true
                            }
                        
                        // Level badge
                        if let level = viewModel.course?.levels.first {
                            LevelBadge(
                                level: 1,
                                title: level.title,
                                color: courseColor
                            )
                        }
                    }
                    
                    // Lesson path
                    lessonPathView
                    
                    // Start button
                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.bloomTextPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                StatBadge(
                    value: "\(viewModel.energy)",
                    icon: "bolt.fill",
                    color: .bloomYellow
                )
            }
        }
        .sheet(isPresented: $showOverview) {
            if let course = viewModel.course {
                CourseOverview(course: course)
            }
        }
        .task {
            await viewModel.loadCourse(id: courseId)
        }
    }
    
    private var courseColor: Color {
        viewModel.course?.color ?? .bloomOrange
    }
    
    private var headerView: some View {
        HStack {
            StatBadge(
                value: "\(viewModel.streak)",
                icon: "flame.fill",
                color: .bloomOrange
            )
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private var courseIllustration: some View {
        ZStack {
            Circle()
                .fill(courseColor.opacity(0.15))
                .frame(width: 120, height: 120)
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(courseColor)
        }
    }
    
    private var lessonPathView: some View {
        VStack(spacing: 0) {
            if let levels = viewModel.course?.levels {
                ForEach(Array(levels.enumerated()), id: \.element.id) { levelIndex, level in
                    ForEach(Array(level.lessons.enumerated()), id: \.element.id) { lessonIndex, lesson in
                        LessonNode(
                            lesson: lesson,
                            isFirst: levelIndex == 0 && lessonIndex == 0,
                            isLast: levelIndex == levels.count - 1 && lessonIndex == level.lessons.count - 1,
                            isCompleted: viewModel.isLessonCompleted(lesson.id),
                            isLocked: !viewModel.isLessonUnlocked(lessonIndex: lessonIndex, levelIndex: levelIndex),
                            color: courseColor
                        )
                    }
                }
            }
        }
    }
    
    private var startButton: some View {
        BloomCard {
            VStack(spacing: 16) {
                Text(viewModel.course?.title ?? "")
                    .font(.bloomH3)
                    .foregroundColor(.bloomTextPrimary)
                
                NavigationLink(destination: LessonView(lessonId: viewModel.nextLessonId ?? "")) {
                    Text("Start")
                        .font(.bloomButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(courseColor)
                                .shadow(color: courseColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .disabled(viewModel.nextLessonId == nil)
            }
        }
    }
}

struct LessonNode: View {
    let lesson: Lesson
    let isFirst: Bool
    let isLast: Bool
    let isCompleted: Bool
    let isLocked: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Vertical line and node
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : color.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
                
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.1) : color.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .stroke(isLocked ? Color.gray.opacity(0.3) : color, lineWidth: 3)
                        .frame(width: 64, height: 64)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(color)
                    } else {
                        Image(systemName: lesson.isExercise ? "pencil" : "lightbulb.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isLocked ? .gray.opacity(0.5) : color)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : color.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
            }
            
            // Lesson info
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.bloomBodyMedium)
                    .foregroundColor(isLocked ? .bloomTextMuted : .bloomTextPrimary)
                
                if lesson.isExercise {
                    Text("Exercise")
                        .font(.bloomCaption)
                        .foregroundColor(.bloomTextSecondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        CourseDetailView(courseId: "co100000-0000-0000-0000-000000000001")
    }
    .environmentObject(AppState())
}
