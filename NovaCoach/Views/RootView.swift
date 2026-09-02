import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        Group {
            if !store.isLoggedIn { LoginView() }
            else if !store.onboardingCompleted { OnboardingView() }
            else { MainTabView() }
        }
        .tint(Color.accentColor)
        .animation(.easeInOut(duration: 0.25), value: store.isLoggedIn)
        .animation(.easeInOut(duration: 0.25), value: store.onboardingCompleted)
    }
}
