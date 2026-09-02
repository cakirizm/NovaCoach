import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Ana Sayfa", systemImage: "house.fill") }
            PlanView().tabItem { Label("Planım", systemImage: "calendar") }
            ProgressViewScreen().tabItem { Label("İlerleme", systemImage: "chart.bar.fill") }
            CoachView().tabItem { Label("Koç", systemImage: "bubble.left.and.bubble.right.fill") }
            ProfileView().tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
    }
}
