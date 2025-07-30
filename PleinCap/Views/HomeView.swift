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

    var id: String { self.rawValue }
}

struct HomeView: View {
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var flow: AuthFlowStep = .login
    @State private var selectedTab = 0
    @State private var progress: Double = 0.0
    @State private var showSelectLevel = false

    var body: some View {
        NavigationStack {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView()
                } else {
                    appFlow
                }
            }
            .navigationDestination(isPresented: $showSelectLevel) {
                SelectLevelView(progress: $progress)
                    .environmentObject(authVM)
            }
        }
        .environmentObject(authVM)
        .animation(.easeInOut, value: authVM.isAuthenticated)
    }

    @ViewBuilder
    private var appFlow: some View {
        if authVM.isAuthenticated {
            if authVM.userObjectif == nil {
                SelectObjectiveView()
                    .environmentObject(authVM)
            } else if authVM.niveauScolaire == nil {
                SelectLevelView(progress: $progress)
                    .environmentObject(authVM)
            } else if authVM.voie == nil {
                SelectVoieView(progress: $progress, niveau: authVM.niveauScolaire ?? "")
                    .environmentObject(authVM)
            } else if authVM.voie == "Générale" && ((authVM.specialites?.isEmpty) != nil) {
                SelectSpecialitesView(
                    progress: $progress,
                    niveau: authVM.niveauScolaire ?? "",
                    voie: "Générale",
                    filiere: nil
                ) { _ in }
                .environmentObject(authVM)
            } else if authVM.voie == "Technologique" && authVM.filiere == nil {
                SelectFiliereView(progress: $progress, niveau: authVM.niveauScolaire ?? "")
                    .environmentObject(authVM)
            } else if authVM.voie == "Technologique" && authVM.specialites!.isEmpty {
                SelectSpecialitesView(
                    progress: $progress,
                    niveau: authVM.niveauScolaire ?? "",
                    voie: "Technologique",
                    filiere: authVM.filiere?.first
                ) { _ in }
                .environmentObject(authVM)
            } else if $authVM.etablissement == nil {
                SelectEtablissementView(progress: $progress)
                    .environmentObject(authVM)
            } else if authVM.academie == nil {
                SelectAcademieView(progress: $progress)
                    .environmentObject(authVM)
            } else if authVM.adresse!.isEmpty {
                LocationPreferenceView(initialProgress: progress)
                    .environmentObject(authVM)
            } else if (authVM.moyenneGenerale ?? 0) == 0 {
                SchoolGradeEntryView(progress: $progress)
                    .environmentObject(authVM)
            } else {
                MainTabView(
                    selectedTab: $selectedTab,
                    authVM: authVM,
                    onLogout: {
                        flow = .login
                        authVM.logout()
                    }
                )
            }
        } else {
            AuthContainer(flow: $flow, authVM: authVM)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
