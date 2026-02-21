import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            CoursesView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "square.stack.fill" : "square.stack")
                    Text("Courses")
                }
                .tag(1)
            
            PremiumView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "crown.fill" : "crown")
                    Text("Premium")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("You")
                }
                .tag(3)
        }
        .tint(.bloomTextPrimary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}
