import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Stats cards
                    statsSection
                    
                    // Settings
                    settingsSection
                    
                    // Logout button
                    logoutButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.bloomBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.bloomOrange.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Text(initials)
                    .font(.bloomH1)
                    .foregroundColor(.bloomOrange)
            }
            
            // Name and email
            VStack(spacing: 4) {
                Text(appState.currentUser?.name ?? "Bloom User")
                    .font(.bloomH2)
                    .foregroundColor(.bloomTextPrimary)
                
                Text(appState.currentUser?.email ?? "")
                    .font(.bloomSmall)
                    .foregroundColor(.bloomTextSecondary)
            }
            
            // Premium badge
            if appState.currentUser?.isPremium == true {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                    Text("Premium")
                        .font(.bloomSmallMedium)
                }
                .foregroundColor(.bloomYellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.bloomYellow.opacity(0.15))
                )
            }
        }
        .padding(.top, 20)
    }
    
    private var initials: String {
        guard let name = appState.currentUser?.name else { return "B" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                value: "\(appState.userStats?.streak?.currentStreak ?? 0)",
                label: "Day Streak",
                icon: "flame.fill",
                color: .bloomOrange
            )
            
            StatCard(
                value: "\(appState.userStats?.completedLessons ?? 0)",
                label: "Lessons",
                icon: "book.fill",
                color: .bloomBlue
            )
            
            StatCard(
                value: "\(appState.userStats?.totalScore ?? 0)",
                label: "XP",
                icon: "star.fill",
                color: .bloomYellow
            )
        }
    }
    
    private var settingsSection: some View {
        BloomCard {
            VStack(spacing: 0) {
                SettingsRow(icon: "bell.fill", title: "Notifications", color: .bloomOrange)
                Divider().padding(.leading, 56)
                SettingsRow(icon: "clock.fill", title: "Daily Goal", color: .bloomBlue)
                Divider().padding(.leading, 56)
                SettingsRow(icon: "globe", title: "Language", color: .bloomGreen)
                Divider().padding(.leading, 56)
                SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .bloomPurple)
                Divider().padding(.leading, 56)
                SettingsRow(icon: "doc.text.fill", title: "Terms & Privacy", color: .gray)
            }
        }
    }
    
    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18))
                Text("Log Out")
                    .font(.bloomBodyMedium)
            }
            .foregroundColor(.bloomError)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.bloomError.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.bloomH2)
                .foregroundColor(.bloomTextPrimary)
            
            Text(label)
                .font(.bloomCaption)
                .foregroundColor(.bloomTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.bloomBody)
                .foregroundColor(.bloomTextPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.bloomTextMuted)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
