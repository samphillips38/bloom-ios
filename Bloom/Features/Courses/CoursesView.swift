import SwiftUI

struct CoursesView: View {
    @StateObject private var viewModel = CoursesViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category tabs
                categoryTabs
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let category = viewModel.selectedCategory {
                            // Section header
                            sectionHeader(for: category)
                            
                            // Course list
                            coursesList
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                .background(Color.bloomBackground)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.categories) { category in
                    CategoryTab(
                        title: category.name,
                        isSelected: viewModel.selectedCategory?.id == category.id,
                        color: categoryColor(for: category.slug)
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private func sectionHeader(for category: Category) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Foundations for \(category.name)")
                    .font(.bloomH2)
                    .foregroundColor(.bloomTextPrimary)
                
                Text("Strengthen your \(category.name.lowercased()) fundamentals")
                    .font(.bloomSmall)
                    .foregroundColor(.bloomTextSecondary)
            }
            
            Spacer()
            
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(categoryColor(for: category.slug).opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: categoryIcon(for: category.slug))
                    .font(.system(size: 32))
                    .foregroundColor(categoryColor(for: category.slug))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [categoryColor(for: category.slug).opacity(0.05), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
    }
    
    private var coursesList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.courses) { course in
                NavigationLink(destination: CourseDetailView(courseId: course.id)) {
                    CourseListItem(course: course)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func categoryColor(for slug: String) -> Color {
        switch slug {
        case "math": return .bloomBlue
        case "logic": return .bloomOrange
        case "writing": return .bloomYellow
        case "science": return .bloomGreen
        case "cs": return .bloomPurple
        default: return .bloomBlue
        }
    }
    
    private func categoryIcon(for slug: String) -> String {
        switch slug {
        case "math": return "x.squareroot"
        case "logic": return "brain"
        case "writing": return "pencil.and.outline"
        case "science": return "atom"
        case "cs": return "chevron.left.forwardslash.chevron.right"
        default: return "book.fill"
        }
    }
}

struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.bloomBodyMedium)
                    .foregroundColor(isSelected ? .bloomTextPrimary : .bloomTextSecondary)
                
                Rectangle()
                    .fill(isSelected ? color : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(2)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CourseListItem: View {
    let course: Course
    
    var body: some View {
        BloomCard {
            HStack(spacing: 16) {
                // Course icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(course.color.opacity(0.1))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "cube.fill")
                        .font(.system(size: 28))
                        .foregroundColor(course.color)
                }
                
                // Course info
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.bloomBodyMedium)
                        .foregroundColor(.bloomTextPrimary)
                    
                    if let description = course.description {
                        Text(description)
                            .font(.bloomSmall)
                            .foregroundColor(.bloomTextSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.bloomTextMuted)
            }
        }
    }
}

#Preview {
    CoursesView()
        .environmentObject(AppState())
}
