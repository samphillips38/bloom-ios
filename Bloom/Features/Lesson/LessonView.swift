import SwiftUI

struct LessonView: View {
    let lessonId: String
    @StateObject private var viewModel = LessonViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    contentView
                }
                
                // Continue button
                continueButton
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadLesson(id: lessonId)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.bloomTextPrimary)
            }
            
            BloomProgressBar(
                progress: viewModel.progress,
                color: .bloomGreen
            )
            .padding(.horizontal, 16)
            
            StatBadge(
                value: "\(viewModel.energy)",
                icon: "bolt.fill",
                color: .bloomYellow
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let content = viewModel.currentContent {
                    LessonContentView(
                        content: content,
                        onAnswerSelected: viewModel.handleAnswer
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }
    
    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                handleContinue()
            } label: {
                Text(viewModel.isLastContent ? "Complete" : "Continue")
                    .font(.bloomButton)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(viewModel.canContinue ? Color.bloomTextPrimary : Color.gray.opacity(0.3))
                    )
            }
            .disabled(!viewModel.canContinue)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
    }
    
    private func handleContinue() {
        if viewModel.isLastContent {
            Task {
                await viewModel.completeLesson()
                await appState.refreshStats()
                dismiss()
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.nextContent()
            }
        }
    }
}

struct LessonContentView: View {
    let content: LessonContent
    var onAnswerSelected: ((Int) -> Void)?
    
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch content.contentData {
            case .text(let textContent):
                textView(textContent)
                
            case .image(let imageContent):
                imageView(imageContent)
                
            case .question(let questionContent):
                questionView(questionContent)
                
            case .interactive:
                interactiveView()
            }
        }
    }
    
    private func textView(_ content: ContentData.TextContent) -> some View {
        Text(content.text)
            .font(content.formatting?.bold == true ? .bloomBodyBold : .bloomBody)
            .foregroundColor(.bloomTextPrimary)
            .lineSpacing(6)
    }
    
    private func imageView(_ content: ContentData.ImageContent) -> some View {
        VStack(spacing: 12) {
            // Placeholder for image
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.3))
                )
            
            if let caption = content.caption {
                Text(caption)
                    .font(.bloomSmall)
                    .foregroundColor(.bloomTextSecondary)
                    .italic()
            }
        }
    }
    
    private func questionView(_ content: ContentData.QuestionContent) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(content.question)
                .font(.bloomH3)
                .foregroundColor(.bloomTextPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(content.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedAnswer = index
                            onAnswerSelected?(index)
                            
                            if index == content.correctIndex {
                                showExplanation = true
                            }
                        }
                    } label: {
                        HStack {
                            Text(option)
                                .font(.bloomBody)
                                .foregroundColor(.bloomTextPrimary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if selectedAnswer == index {
                                Image(systemName: index == content.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(index == content.correctIndex ? .bloomSuccess : .bloomError)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(backgroundColor(for: index, correct: content.correctIndex))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(borderColor(for: index, correct: content.correctIndex), lineWidth: 2)
                                )
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            
            if showExplanation, let explanation = content.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.bloomYellow)
                        Text("Explanation")
                            .font(.bloomSmallMedium)
                            .foregroundColor(.bloomTextPrimary)
                    }
                    
                    Text(explanation)
                        .font(.bloomSmall)
                        .foregroundColor(.bloomTextSecondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.bloomYellow.opacity(0.1))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func interactiveView() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.bloomBlue.opacity(0.1))
            .frame(height: 200)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.bloomBlue)
                    Text("Interactive Content")
                        .font(.bloomBodyMedium)
                        .foregroundColor(.bloomTextSecondary)
                }
            )
    }
    
    private func backgroundColor(for index: Int, correct: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white
        }
        
        if index == correct {
            return Color.bloomSuccess.opacity(0.1)
        } else if index == selected {
            return Color.bloomError.opacity(0.1)
        }
        
        return Color.white
    }
    
    private func borderColor(for index: Int, correct: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.gray.opacity(0.2)
        }
        
        if index == correct {
            return Color.bloomSuccess
        } else if index == selected {
            return Color.bloomError
        }
        
        return Color.gray.opacity(0.2)
    }
}

#Preview {
    LessonView(lessonId: "ls100000-0000-0000-0000-000000000001")
        .environmentObject(AppState())
}
