import SwiftUI

struct CourseCard: View {
    let course: Course
    let level: Int
    @State private var isAnimating = false
    
    var body: some View {
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
                .fadeIn(delay: 0.1)
            
            // Course title
            Text(course.title)
                .font(.bloomH2)
                .foregroundColor(.bloomTextPrimary)
                .multilineTextAlignment(.center)
                .fadeIn(delay: 0.2)
            
            // Level indicator
            Text("LEVEL \(level)")
                .font(.bloomLevelBadge)
                .foregroundColor(course.color)
                .fadeIn(delay: 0.3)
            
            // Course illustration with animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(course.color.opacity(0.05))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimating ? 1.1 : 1)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Main circle
                Circle()
                    .fill(course.color.opacity(0.1))
                    .frame(width: 180, height: 180)
                
                // Inner elements
                ZStack {
                    // Decorative shapes
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(course.color.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .offset(
                                x: cos(Double(index) * .pi / 3) * 60,
                                y: sin(Double(index) * .pi / 3) * 60
                            )
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                    
                    // Center icon
                    Image(systemName: courseIcon)
                        .font(.system(size: 64))
                        .foregroundColor(course.color)
                        .rotationEffect(.degrees(isAnimating ? 5 : -5))
                        .animation(
                            .easeInOut(duration: 3)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            .padding(.vertical, 20)
            .fadeIn(delay: 0.4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 4)
        )
        .pressEffect()
        .onAppear {
            isAnimating = true
        }
    }
    
    private var courseIcon: String {
        switch course.categoryId {
        case let id where id.contains("logic"):
            return "brain.head.profile"
        case let id where id.contains("writing"):
            return "pencil.and.outline"
        case let id where id.contains("math"):
            return "x.squareroot"
        case let id where id.contains("science"):
            return "atom"
        default:
            return "lightbulb.fill"
        }
    }
}

#Preview {
    CourseCard(
        course: Course(
            id: "1",
            categoryId: "logic",
            title: "Introduction to Logic",
            description: "Learn logical thinking",
            iconUrl: nil,
            themeColor: "#FF6B35",
            lessonCount: 8,
            exerciseCount: 24,
            isRecommended: true,
            collaborators: nil,
            orderIndex: 1
        ),
        level: 1
    )
    .padding()
}
