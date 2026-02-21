import SwiftUI

struct LessonRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    let isCompleted: Bool
    let isLocked: Bool
    let color: Color
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Lesson icon
            ZStack {
                Circle()
                    .fill(isLocked ? Color.gray.opacity(0.1) : color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isLocked ? .gray.opacity(0.5) : color)
                }
            }
            .scaleEffect(isAnimating && !isLocked && !isCompleted ? 1.05 : 1)
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            // Lesson info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.bloomBodyMedium)
                    .foregroundColor(isLocked ? .bloomTextMuted : .bloomTextPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bloomSmall)
                        .foregroundColor(.bloomTextSecondary)
                }
            }
            
            Spacer()
            
            // Status indicator
            ZStack {
                Circle()
                    .stroke(
                        isCompleted ? color : Color.gray.opacity(0.2),
                        lineWidth: 2
                    )
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            if !isLocked && !isCompleted {
                isAnimating = true
            }
        }
    }
}

struct LessonRowCompact: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isLocked: Bool
    let color: Color
    
    var body: some View {
        LessonRow(
            title: lesson.title,
            subtitle: lesson.isExercise ? "Exercise" : nil,
            icon: lesson.isExercise ? "pencil" : "lightbulb.fill",
            isCompleted: isCompleted,
            isLocked: isLocked,
            color: color
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        LessonRow(
            title: "What is Logic?",
            subtitle: nil,
            icon: "lightbulb.fill",
            isCompleted: true,
            isLocked: false,
            color: .bloomOrange
        )
        
        LessonRow(
            title: "Statements and Truth",
            subtitle: nil,
            icon: "lightbulb.fill",
            isCompleted: false,
            isLocked: false,
            color: .bloomOrange
        )
        
        LessonRow(
            title: "Practice: Basic Logic",
            subtitle: "Exercise",
            icon: "pencil",
            isCompleted: false,
            isLocked: true,
            color: .bloomOrange
        )
    }
    .padding()
}
