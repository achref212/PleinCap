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
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

struct HomeView: View {
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var flow: AuthFlowStep = .login
    @State private var selectedTab = 0
    @State private var progress: Double = 0.0
    @State private var navigationPath = NavigationPath() // Added for NavigationStack path management

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView()
                        .navigationDestination(isPresented: .constant(!hasSeenOnboarding)) {
                            appFlow
                        }
                } else {
                    appFlow
                }
            }
            .environmentObject(authVM)
            .animation(.easeInOut, value: [authVM.isAuthenticated, hasSeenOnboarding]) // Consolidated animation triggers
        }
    }

    @ViewBuilder
    private var appFlow: some View {
        if authVM.isAuthenticated {
            if authVM.objectif == nil {
                SelectObjectiveView()
                    .environmentObject(authVM)
                    .navigationDestination(isPresented: .constant(authVM.objectif != nil)) {
                        nextView
                    }
            } else {
                nextView
            }
        } else {
            AuthContainer(flow: $flow, authVM: authVM)
        }
    }

    @ViewBuilder
    private var nextView: some View {
        if authVM.niveauScolaire == nil {
            SelectLevelView(progress: $progress)
                .environmentObject(authVM)

        } else if authVM.voie == nil {
            SelectVoieView(
                progress: $progress,
                niveau: authVM.niveauScolaire ?? "Terminale"
            )
            .environmentObject(authVM)

        } else if authVM.voie == "Générale" && (authVM.specialites?.isEmpty ?? true) {
            SelectSpecialitesView(
                progress: $progress,
                niveau: authVM.niveauScolaire ?? "Terminale",
                voie: "Générale",
                filiere: nil
            ) { _ in }
            .environmentObject(authVM)

        } else if authVM.voie == "Technologique" && (authVM.filiere?.isEmpty ?? true) {
            SelectFiliereView(
                progress: $progress,
                niveau: authVM.niveauScolaire ?? "Terminale"
            )
            .environmentObject(authVM)

        } else if authVM.voie == "Technologique" && (authVM.specialites?.isEmpty ?? true) {
            SelectSpecialitesView(
                progress: $progress,
                niveau: authVM.niveauScolaire ?? "Terminale",
                voie: "Technologique",
                filiere: authVM.filiere // ✅ correction ici
            ) { _ in }
            .environmentObject(authVM)

        } else if authVM.locationData?.etablissement == nil {
            SelectEtablissementView(progress: $progress)
                .environmentObject(authVM)

        } else if authVM.locationData?.academie == nil {
            SelectAcademieView(progress: $progress)
                .environmentObject(authVM)

        } else if authVM.locationData?.adresse?.isEmpty ?? true {
            LocationPreferenceView(initialProgress: progress)
                .environmentObject(authVM)

        } else {
            MainTabView(
                selectedTab: $selectedTab,
                authVM: authVM,
                onLogout: {
                    flow = .login
                    authVM.logout()
                    navigationPath = NavigationPath()
                }
            )
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
