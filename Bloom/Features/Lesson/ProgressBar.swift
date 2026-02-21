import SwiftUI

struct LessonProgressBar: View {
    let progress: Double
    var color: Color = .bloomGreen
    var showPercentage: Bool = false
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                
                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress)
                
                // Leading indicator dot
                if animatedProgress > 0 {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
                        .offset(x: max(0, geometry.size.width * animatedProgress - 6))
                }
            }
        }
        .frame(height: 8)
        .overlay(alignment: .trailing) {
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.bloomCaptionMedium)
                    .foregroundColor(.bloomTextSecondary)
                    .padding(.leading, 8)
                    .offset(x: 50)
            }
        }
        .onAppear {
            withAnimation(.bloomSpring) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.bloomSpring) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var color: Color = .bloomGreen
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            Text("\(Int(animatedProgress * 100))%")
                .font(.bloomSmallMedium)
                .foregroundColor(.bloomTextPrimary)
        }
        .onAppear {
            withAnimation(.bloomSpring.delay(0.2)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.bloomSpring) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LessonProgressBar(progress: 0.65, color: .bloomGreen)
            .padding()
        
        LessonProgressBar(progress: 0.3, color: .bloomOrange, showPercentage: true)
            .padding()
        
        CircularProgressBar(progress: 0.75, color: .bloomBlue)
            .frame(width: 80, height: 80)
    }
}
