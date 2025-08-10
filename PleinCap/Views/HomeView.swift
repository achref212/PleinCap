import SwiftUI

enum AuthFlowStep: Equatable {
    case login
    case register
    case verifyCode(email: String)
    case forgotEmail
    case verifyResetCode(email: String)
    case setNewPassword(email: String, code: String)
}

enum Appearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"
    var id: String { rawValue }
}

struct HomeView: View {
    // Legacy VM kept ONLY if some old views still need it (e.g., MainTabView signature).
    @StateObject private var legacyAuthVM = AuthViewModel()

    // ✅ New unified auth/profile VM
    @StateObject private var authVM1 = AuthViewModel1()

    // ✅ DirectoryVM used by academy/etablissement screens
    @StateObject private var directoryVM = DirectoryViewModel()

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var flow: AuthFlowStep = .login
    @State private var selectedTab = 0
    @State private var progress: Double = 0.0
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            appFlow
                .animation(.easeInOut, value: authVM1.isAuthenticated)
                .animation(.easeInOut, value: hasSeenOnboarding)
        }
        // ✅ Onboarding as a full-screen cover (no back button on Login).
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { _ in }
        )) {
            OnboardingView()
                .ignoresSafeArea()
                .onDisappear {
                    // Ensure a clean stack when onboarding completes
                    navigationPath = NavigationPath()
                }
        }
    }

    // MARK: - Root flow
    @ViewBuilder
    private var appFlow: some View {
        if authVM1.isAuthenticated {
            postAuthFlow
        } else {
            // ✅ Auth uses the new VM
            AuthContainer(flow: $flow, authVM: authVM1)
                .navigationBarBackButtonHidden(true)
                .environmentObject(authVM1)
        }
    }

    // MARK: - Post-auth progressive flow (uses AuthViewModel1 everywhere)
    @ViewBuilder
    private var postAuthFlow: some View {
        if authVM1.objectif == nil {
            SelectObjectiveView()
                .environmentObject(authVM1)

        } else if authVM1.niveauScolaire == nil {
            SelectLevelView(progress: $progress)
                .environmentObject(authVM1)

        } else if authVM1.voie == nil {
            SelectVoieView(
                progress: $progress,
                niveau: authVM1.niveauScolaire ?? "Terminale"
            )
            .environmentObject(authVM1)

        } else if authVM1.voie == "Générale" && (authVM1.specialites?.isEmpty ?? true) {
            SelectSpecialitesView(
                progress: $progress,
                niveau: authVM1.niveauScolaire ?? "Terminale",
                voie: "GÉNÉRALE",
                filiere: "GÉNÉRALE"
            ) { _ in }
            .environmentObject(authVM1)

        } else if authVM1.voie == "Technologique" && (authVM1.filiere?.isEmpty ?? true) {
            SelectFiliereView(
                progress: $progress,
                niveau: authVM1.niveauScolaire ?? "Terminale"
            )
            .environmentObject(authVM1)

        } else if authVM1.voie == "Technologique" && (authVM1.specialites?.isEmpty ?? true) {
            SelectSpecialitesView(
                progress: $progress,
                niveau: authVM1.niveauScolaire ?? "Terminale",
                voie: "Technologique",
                filiere: authVM1.filiere
            ) { _ in }
            .environmentObject(authVM1)

        // 🔰 LOCATION FLOW — go to ACADEMY FIRST (that screen pushes to Etablissements)
        } else if (authVM1.userProfile?.academie?.isEmpty ?? true)
                    || (authVM1.userProfile?.etablissement?.isEmpty ?? true) {
            SelectAcademieView(progress: $progress)
                .environmentObject(authVM1)
                .environmentObject(directoryVM)   // used inside SelectAcademieView / SelectEtablissementView

        } else if authVM1.userProfile?.adresse?.isEmpty ?? true {
            LocationPreferenceView(initialProgress: progress)
                .environmentObject(authVM1)

        } else {
            // ⬇️ If MainTabView still expects the legacy VM, we keep passing it here.
            MainTabView(
                selectedTab: $selectedTab,
                authVM: legacyAuthVM,
                onLogout: {
                    flow = .login
                    authVM1.logout()               // logout new VM
                    legacyAuthVM.logout()          // if needed by older views
                    navigationPath = NavigationPath()
                    hasSeenOnboarding = true
                }
            )
            .navigationBarBackButtonHidden(true)
            .environmentObject(authVM1)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
