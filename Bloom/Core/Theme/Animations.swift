import SwiftUI

// MARK: - Animation Extensions
extension Animation {
    static let bloomSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let bloomBounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let bloomSmooth = Animation.easeInOut(duration: 0.3)
    static let bloomQuick = Animation.easeOut(duration: 0.2)
    static let bloomSlow = Animation.easeInOut(duration: 0.5)
}

// MARK: - View Transitions
extension AnyTransition {
    static var bloomSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    static var bloomScale: AnyTransition {
        .scale(scale: 0.9).combined(with: .opacity)
    }
    
    static var bloomFade: AnyTransition {
        .opacity.animation(.bloomSmooth)
    }
}

// MARK: - View Modifiers
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.5),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.bloomQuick, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.bloomSpring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1)
            .animation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions
extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
    
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
    
    func pulse() -> some View {
        modifier(PulseModifier())
    }
    
    func staggeredFadeIn(index: Int, baseDelay: Double = 0.05) -> some View {
        fadeIn(delay: Double(index) * baseDelay)
    }
}

// MARK: - Matched Geometry Effect Helper
struct CourseCardTransition: View {
    let course: Course
    @Namespace var animation
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(course.color.opacity(0.1))
                .matchedGeometryEffect(id: "card-\(course.id)", in: animation)
        }
    }
}
