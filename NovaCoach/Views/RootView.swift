import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        Group {
            if !store.isLoggedIn { LoginView() }
            else if !store.onboardingCompleted { OnboardingView() }
            else { MainTabView() }
        }
        .animation(.easeInOut, value: store.isLoggedIn)
        .animation(.easeInOut, value: store.onboardingCompleted)
    }
}
