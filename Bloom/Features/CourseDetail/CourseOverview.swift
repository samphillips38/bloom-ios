import SwiftUI

struct CourseOverview: View {
    let course: CourseWithLevels
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Course illustration
                    ZStack {
                        Circle()
                            .fill(course.color.opacity(0.15))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 56))
                            .foregroundColor(course.color)
                    }
                    .padding(.top, 20)
                    
                    // Title and description
                    VStack(spacing: 12) {
                        Text(course.title)
                            .font(.bloomH1)
                            .foregroundColor(.bloomTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        if let description = course.description {
                            Text(description)
                                .font(.bloomBody)
                                .foregroundColor(.bloomTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Collaborators
                    if let collaborators = course.collaborators, !collaborators.isEmpty {
                        VStack(spacing: 8) {
                            Text("Made in collaboration with")
                                .font(.bloomSmall)
                                .foregroundColor(.bloomTextSecondary)
                            
                            HStack(spacing: 16) {
                                ForEach(collaborators, id: \.self) { collaborator in
                                    HStack(spacing: 6) {
                                        Image(systemName: "building.2")
                                            .font(.system(size: 14))
                                        Text(collaborator)
                                            .font(.bloomSmallMedium)
                                    }
                                    .foregroundColor(.bloomTextPrimary)
                                }
                            }
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                Text("\(course.lessonCount)")
                                    .font(.bloomBodyMedium)
                            }
                            .foregroundColor(.bloomTextPrimary)
                            
                            Text("Lessons")
                                .font(.bloomCaption)
                                .foregroundColor(.bloomTextSecondary)
                        }
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "puzzlepiece.fill")
                                    .font(.system(size: 16))
                                Text("\(course.exerciseCount)")
                                    .font(.bloomBodyMedium)
                            }
                            .foregroundColor(.bloomTextPrimary)
                            
                            Text("Exercises")
                                .font(.bloomCaption)
                                .foregroundColor(.bloomTextSecondary)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Levels breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Course Content")
                            .font(.bloomH3)
                            .foregroundColor(.bloomTextPrimary)
                        
                        ForEach(Array(course.levels.enumerated()), id: \.element.id) { index, level in
                            HStack {
                                Text("Level \(index + 1)")
                                    .font(.bloomSmallMedium)
                                    .foregroundColor(course.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(course.color.opacity(0.1))
                                    )
                                
                                Text(level.title)
                                    .font(.bloomBody)
                                    .foregroundColor(.bloomTextPrimary)
                                
                                Spacer()
                                
                                Text("\(level.lessons.count) lessons")
                                    .font(.bloomSmall)
                                    .foregroundColor(.bloomTextSecondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 100)
            }
            .background(Color.bloomBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
        }
    }
}
