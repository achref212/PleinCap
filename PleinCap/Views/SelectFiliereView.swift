import SwiftUI

extension String {
    /// Remove French diacritics and apostrophes for backend-safe keys.
    var sanitizedFR: String {
        let folded = self.folding(options: [.diacriticInsensitive], locale: Locale(identifier: "fr_FR"))
        return folded
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "'", with: "")
    }
}

struct SelectFiliereView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    @State private var selectedFiliere: String? = nil
    @State private var goToSpecialites = false
    @State private var goToEtablissement = false
    @State private var isSaving = false

    let niveau: String

    private func isPremiere(_ niveau: String) -> Bool {
        niveau.folding(options: [.diacriticInsensitive], locale: .init(identifier: "fr_FR"))
            .lowercased() == "premiere"
    }

    private let filieresTechnos = ["STMG","STI2D","S2TMD","ST2S","STAV","STD2A","STHR","STL"]

    /// Filieres that show the specialties screen next
    private let filieresAvecChoix: Set<String> = ["STMG","STI2D","S2TMD","STAV","STL"]

    // ---- DISPLAY defaults by filière/niveau (accented for UI) ----
    private func defaultSpecialitesDisplay(for filiere: String, niveau: String) -> [String] {
        switch filiere.uppercased() {
        case "STMG":
            return isPremiere(niveau)
                ? ["Droit et économie","Management","Sciences de gestion et du numérique"]
                : ["Droit et économie"]
        case "ST2S":
            return isPremiere(niveau)
                ? ["Physique chimie pour la santé",
                   "Biologie et physiopathologie humaines",
                   "Sciences et techniques sanitaires et sociales"]
                : ["Sciences et techniques sanitaires et sociales",
                   "Chimie, biologie et physiopathologie humaines"]
        case "STHR":
            return ["Économie et gestion hôtelière","Sciences et technologies culinaires"]
        case "STD2A":
            return isPremiere(niveau)
                ? ["Physique-chimie","Outils et langages numériques","Design et métiers d’art"]
                : ["Analyse et méthodes en design","Conception et création en design et métiers d’art"]
        case "STAV":
            return isPremiere(niveau)
                ? ["Gestion des ressources et de l'alimentation","Territoires et sociétés"]
                : ["Gestion des ressources et de l'alimentation"]
        case "S2TMD":
            return ["Économie, droit et environnement du spectacle vivant"]
        case "STL":
            return ["Biotechnologies","Sciences physiques et chimiques en laboratoire"]
        default:
            return []
        }
    }

    // Pre-built destination keeps type-checking fast
    @ViewBuilder
    private var destinationSpecialites: some View {
        if let fil = selectedFiliere {
            let defaultsDisplay = defaultSpecialitesDisplay(for: fil, niveau: niveau)
            SelectSpecialitesView(
                progress: $progress,
                niveau: niveau,
                voie: "Technologique",
                filiere: fil,
                preselectedDefaults: defaultsDisplay   // pass DISPLAY strings
            )
            .environmentObject(authVM)
        } else {
            EmptyView()
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
                                    isSelected: selectedFiliere == filiere
                                ) {
                                    withAnimation {
                                        if selectedFiliere == nil { progress = min(progress + 0.1, 1.0) }
                                        selectedFiliere = filiere
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }

                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : "Suivant",
                    enabled: selectedFiliere != nil && !isSaving
                ) { saveAndNavigate() }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }

            // -> specialties screen when needed
            NavigationLink(destination: destinationSpecialites, isActive: $goToSpecialites) { EmptyView() }
                .hidden()

            // -> else continue the flow
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
            Alert(title: Text("Erreur"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle().fill(Color.orange).frame(width: 4).cornerRadius(2)
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
        let defaultsDisplay = defaultSpecialitesDisplay(for: filiere, niveau: niveau)
        let defaultsSanitized = defaultsDisplay.map { $0.sanitizedFR }
        isSaving = true

        // Save filière + defaults (sanitized) to backend
        authVM.updateUserFields([
            "filiere": filiere,
            "specialites": defaultsSanitized
        ]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.filiere = filiere
                authVM.specialites = defaultsSanitized
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

struct SelectFiliereView_Previews: PreviewProvider {
    struct Demo: View {
        @State private var progress: Double = 0.5
        @StateObject var authVM = AuthViewModel1()
        let niveau: String
        let prefilledFiliere: String?

        var body: some View {
            NavigationStack {
                SelectFiliereView(progress: $progress, niveau: niveau)
                    .environmentObject(authVM)
                    .onAppear {
                        // simulate prefilled filière (optional)
                        authVM.filiere = prefilledFiliere
                    }
            }
        }
    }

    static var previews: some View {
        Group {
            Demo(niveau: "Première",  prefilledFiliere: nil)
                .previewDisplayName("Première — fresh")

            Demo(niveau: "Terminale", prefilledFiliere: nil)
                .previewDisplayName("Terminale — fresh")

            Demo(niveau: "Première",  prefilledFiliere: "STMG")
                .previewDisplayName("Première — prefilled STMG")

            Demo(niveau: "Terminale", prefilledFiliere: "STI2D")
                .preferredColorScheme(.dark)
                .previewDisplayName("Terminale — prefilled STI2D (Dark)")
        }
    }
}
