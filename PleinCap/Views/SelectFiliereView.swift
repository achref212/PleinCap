import SwiftUI

struct SelectFiliereView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    @State private var selectedFiliere: String? = nil
    @State private var goToSpecialites = false
    @State private var goToEtablissement = false
    @State private var isSaving = false

    let niveau: String

    // Liste des filières technologiques
    private let filieresTechnos = [
        "STMG", "STI2D", "S2TMD", "ST2S", "STAV", "STD2A", "STHR", "STL"
    ]

    // Celles qui demanderont un écran de spécialités ensuite
    private let filieresAvecChoix: Set<String> = ["STMG", "STI2D", "S2TMD", "STAV", "STL"]

    // Spécialités par défaut (si besoin d’initialiser côté UI)
    private var defaultSpecialites: [String] {
        guard let filiere = selectedFiliere else { return [] }
        switch filiere.uppercased() {
        case "STMG":
            return niveau.lowercased() == "première"
                ? ["Droit et économie", "Management", "Sciences de gestion et du numérique"]
                : ["Droit et économie"]
        case "ST2S":
            return niveau.lowercased() == "première"
                ? ["Physique chimie pour la santé", "Biologie et physiopathologie humaines", "Sciences et techniques sanitaires et sociales"]
                : ["Sciences et techniques sanitaires et sociales", "Chimie, biologie et physiopathologie humaines"]
        case "STHR":
            return ["Économie et gestion hôtelière", "Sciences et technologies culinaires"]
        case "STD2A":
            return niveau.lowercased() == "première"
                ? ["Physique-chimie", "Outils et langages numériques", "Design et métiers d’art"]
                : ["Analyse et méthodes en design", "Conception et création en design et métiers d’art"]
        case "STAV":
            return niveau.lowercased() == "première"
                ? ["Gestion des ressources et de l'alimentation", "Territoires et sociétés"]
                : ["Gestion des ressources et de l'alimentation"]
        case "S2TMD":
            return ["Économie, droit et environnement du spectacle vivant"]
        case "STL":
            return ["Biotechnologies", "Sciences physiques et chimiques en laboratoire"]
        default:
            return []
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        ProgressBarView(progress: $progress)
                            .padding(.top)

                        ImageWithCaptionView(imageName: "filiere", caption: "Filière")

                        header

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                            ForEach(filieresTechnos, id: \.self) { filiere in
                                SelectableCardGridView(
                                    title: filiere,
                                    isSelected: selectedFiliere == filiere,
                                    onTap: {
                                        withAnimation {
                                            if selectedFiliere == nil {
                                                progress = min(progress + 0.1, 1.0)
                                            }
                                            selectedFiliere = filiere
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }

                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : "Suivant",
                    enabled: selectedFiliere != nil && !isSaving
                ) {
                    saveAndNavigate()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }

            // Navigation
            NavigationLink(
                destination: SelectSpecialitesView(
                    progress: $progress,
                    niveau: niveau,
                    voie: "Technologique",
                    filiere: selectedFiliere
                ) { _ in }
                .environmentObject(authVM),
                isActive: $goToSpecialites
            ) { EmptyView() }
            .hidden()

            NavigationLink(
                destination: SelectAcademieView(progress: $progress)
                    .environmentObject(authVM),
                isActive: $goToEtablissement
            ) { EmptyView() }
            .hidden()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Filière technologique")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { preloadState() }
        .alert(item: $authVM.errorMessage) { error in
            Alert(title: Text("Erreur"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choisis ta filière technologique")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Une seule filière possible.")
                    .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func preloadState() {
        // Si déjà défini côté backend, on re-sélectionne pour une UX fluide
        if let existing = authVM.filiere, !existing.isEmpty {
            selectedFiliere = existing
            progress = max(progress, 0.5)
        } else {
            progress = max(progress, 0.45)
        }
        goToSpecialites = false
        goToEtablissement = false
    }

    private func saveAndNavigate() {
        guard let filiere = selectedFiliere else { return }
        let specialitesList = defaultSpecialites
        isSaving = true

        // MàJ du profil avec filière (+ spécialités par défaut si vous souhaitez préremplir)
        authVM.updateUserFields([
            "filiere": filiere,
            "specialites": specialitesList
        ]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.filiere = filiere
                authVM.specialites = specialitesList
                withAnimation {
                    progress = max(progress, 0.55)
                    if filieresAvecChoix.contains(filiere.uppercased()) {
                        goToSpecialites = true
                    } else {
                        goToEtablissement = true
                    }
                }
            case .failure(let error):
                authVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview

struct SelectFiliereView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.5
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            NavigationStack {
                SelectFiliereView(progress: $progress, niveau: "Terminale")
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            Wrapper().preferredColorScheme(.light)
            Wrapper().preferredColorScheme(.dark)
        }
    }
}
