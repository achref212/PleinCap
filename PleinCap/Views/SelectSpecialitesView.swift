import SwiftUI

struct SelectSpecialitesView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    @State private var selectedSpecialites: Set<String> = []   // DISPLAY strings
    @State private var goToNext = false
    @State private var isSaving = false

    let niveau: String           // "Première" | "Terminale"
    let voie: String             // "Générale" | "Technologique"
    let filiere: String          // e.g. "STMG", "STI2D", ... or "" for Générale
    let preselectedDefaults: [String]   // DISPLAY defaults from previous step

    private var isTerminale: Bool {
        niveau.folding(options: [.diacriticInsensitive], locale: .init(identifier: "fr_FR"))
            .lowercased() == "terminale"
    }

    // Allowed per section (Première: 3, Terminale: 2) unless a section is 1-by-design
    private var maxSelectionDefault: Int { isTerminale ? 2 : 3 }

    // MARK: - Grouped options (DISPLAY)
    private var groupedSpecialites: [String: [String]] {
        if voie.localizedCaseInsensitiveCompare("Générale") == .orderedSame {
            return [
                "Arts (au choix)": [
                    "Histoire des arts", "Théâtre", "Arts plastiques",
                    "Arts du cirque", "Cinéma-audiovisuel", "Danse", "Musique"
                ],
                "Scientifiques": [
                    "Mathématiques", "Physique-chimie", "Sciences de la vie et de la Terre",
                    "Sciences de l’ingénieur", "Numérique et informatique"
                ],
                "Lettres / Sciences humaines": [
                    "Histoire-géo, géopolitique", "Humanités, littérature et philosophie",
                    "Langues, littératures et cultures étrangères", "Langues anciennes",
                    "Sciences économiques et sociales"
                ]
            ]
        }

        switch filiere.uppercased() {
        case "STMG":
            if isTerminale {
                return ["Spécialité STMG Terminale": [
                    "Gestion et finances",
                    "Mercatique",
                    "Ressources humaines et communication",
                    "Systèmes d’information de gestion",
                    "Droit et économie"
                ]]
            } else {
                return ["Spécialité STMG Première": [
                    "Droit et économie",
                    "Management",
                    "Sciences de gestion et du numérique"
                ]]
            }

        case "STAV":
            let items = [
                "Aménagement", "Production", "Agroéquipement", "Services", "Transformation",
                "Gestion des ressources et de l'alimentation", "Territoires et sociétés"
            ]
            return [isTerminale ? "Territoires et technologie (Terminale)" : "Technologie STAV (Première)": items]

        case "STI2D":
            if isTerminale {
                return ["Spécialité STI2D": [
                    "PC + Maths & Innovation technologique et éco-conception",
                    "PC + Maths & Systèmes d'information et numériques",
                    "PC + Maths & Énergies et environnement",
                    "PC + Maths & Architecture et construction",
                    "Innovation technologique", "Ingénierie et développement durable"
                ]]
            } else {
                return ["Technologie STI2D (Première)": [
                    "Innovation technologique", "Ingénierie et développement durable"
                ]]
            }

        case "S2TMD":
            return [
                "Culture et sciences": [
                    "Culture et sciences chorégraphiques",
                    "Culture et sciences musicales",
                    "Culture et sciences théâtrales",
                    "Économie, droit et environnement du spectacle vivant"
                ],
                "Pratique artistique": [
                    "Pratique chorégraphique",
                    "Pratique musicale",
                    "Pratique théâtrale"
                ]
            ]

        case "STL":
            return ["Spécialités STL": [
                "Biotechnologies",
                "Sciences physiques et chimiques en laboratoire"
            ]]

        case "ST2S":
            return ["Spécialités ST2S": [
                "Sciences sanitaires et sociales & Physiologie humaine",
                "Physique chimie pour la santé",
                "Biologie et physiopathologie humaines",
                "Sciences et techniques sanitaires et sociales",
                "Chimie, biologie et physiopathologie humaines"
            ]]

        case "STHR":
            return ["Spécialités STHR": [
                "Économie et gestion hôtelière",
                "Sciences et technologies culinaires"
            ]]

        case "STD2A":
            return ["Spécialités STD2A": [
                "Physique-chimie","Outils et langages numériques","Design et métiers d’art",
                "Analyse et méthodes en design","Conception et création en design et métiers d’art"
            ]]

        default:
            return [:]
        }
    }

    /// Per-section maximum
    private var maxSelectionPerSection: [String: Int] {
        var config: [String: Int] = [:]
        for key in groupedSpecialites.keys {
            switch key {
            case "Culture et sciences", "Pratique artistique",
                 "Spécialité STMG Terminale",
                 "Spécialité STMG Première",
                 "Spécialité STI2D",
                 "Technologie STAV (Première)",
                 "Territoires et technologie (Terminale)",
                 "Spécialités STL":
                config[key] = 1
            default:
                config[key] = maxSelectionDefault
            }
        }
        return config
    }

    /// Valid if each section has 1…max selections
    private func isValidSelection() -> Bool {
        for (section, options) in groupedSpecialites {
            let maxAllowed = maxSelectionPerSection[section] ?? maxSelectionDefault
            let picks = selectedSpecialites.intersection(Set(options))
            if picks.count < 1 || picks.count > maxAllowed { return false }
        }
        return true
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressBarView(progress: $progress).padding(.top)
                    ImageWithCaptionView(imageName: "Specialite", caption: "Spécialités")
                    header

                    VStack(spacing: 16) {
                        ForEach(groupedSpecialites.keys.sorted(), id: \.self) { section in
                            let options = groupedSpecialites[section] ?? []
                            AccordionCheckboxSectionView(
                                title: section,
                                options: options,
                                maxSelection: maxSelectionPerSection[section] ?? maxSelectionDefault,
                                selectedItems: $selectedSpecialites
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 120)
            }

            VStack {
                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : "Suivant",
                    enabled: isValidSelection() && !isSaving
                ) { saveAndNavigate() }
                .padding(.horizontal)

                NavigationLink(
                    destination: SelectAcademieView(progress: $progress).environmentObject(authVM),
                    isActive: $goToNext
                ) { EmptyView() }.hidden()
            }
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Choix des spécialités")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Start with defaults pre-selected
            var start = Set(preselectedDefaults)

            // Merge with any already saved (convert sanitized -> DISPLAY if present in our lists)
            let savedSanitized = Set((authVM.specialites ?? []).map { $0.sanitizedFR })
            let allDisplay = groupedSpecialites.values.flatMap { $0 }
            let savedDisplay = allDisplay.filter { savedSanitized.contains($0.sanitizedFR) }
            start.formUnion(savedDisplay)

            selectedSpecialites = start

            progress = max(progress, 0.6)
        }
        .alert(item: $authVM.errorMessage) { err in
            Alert(title: Text("Erreur"), message: Text(err.message), dismissButton: .default(Text("OK")))
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle().fill(Color.orange).frame(width: 4).cornerRadius(2)
            VStack(alignment: .leading, spacing: 4) {
                Text("Choisis/valide tes spécialités")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))
                Text("Les spécialités par défaut sont pré-cochées. Tu peux les modifier dans la limite autorisée par groupe.")
                    .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Save

    private func saveAndNavigate() {
        isSaving = true
        let sanitized = selectedSpecialites.map { $0.sanitizedFR }.sorted()

        authVM.updateUserFields(["specialites": sanitized]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.specialites = sanitized
                withAnimation {
                    progress = max(progress, 0.7)
                    goToNext = true
                }
            case .failure(let error):
                authVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Previews

struct SelectSpecialitesView_Previews: PreviewProvider {
    struct Demo: View {
        @State private var progress: Double = 0.6
        @StateObject var authVM = AuthViewModel1()

        let niveau: String
        let voie: String
        let filiere: String
        let seedDefaults: [String]

        var body: some View {
            NavigationStack {
                SelectSpecialitesView(
                    progress: $progress,
                    niveau: niveau,
                    voie: voie,
                    filiere: filiere,
                    preselectedDefaults: seedDefaults
                )
                .environmentObject(authVM)
                .onAppear {
                    // Simulate that backend already stores sanitized values
                    authVM.specialites = seedDefaults.map { $0.sanitizedFR }
                }
            }
        }
    }

    static var previews: some View {
        Group {
            // Tech — STMG — Première (3 defaults)
            Demo(
                niveau: "Première",
                voie: "Technologique",
                filiere: "STMG",
                seedDefaults: ["Droit et économie", "Management", "Sciences de gestion et du numérique"]
            )
            .previewDisplayName("STMG — Première")

            // Tech — STMG — Terminale (1 default)
            Demo(
                niveau: "Terminale",
                voie: "Technologique",
                filiere: "STMG",
                seedDefaults: ["Droit et économie"]
            )
            .previewDisplayName("STMG — Terminale")

            // Tech — STI2D — Terminale
            Demo(
                niveau: "Terminale",
                voie: "Technologique",
                filiere: "STI2D",
                seedDefaults: ["Innovation technologique", "Ingénierie et développement durable"]
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("STI2D — Terminale (Dark)")

            // Générale — Terminale (use empty filière string)
            Demo(
                niveau: "Terminale",
                voie: "Générale",
                filiere: "",
                seedDefaults: ["Mathématiques", "Physique-chimie"]
            )
            .previewDisplayName("Générale — Terminale")
        }
    }
}
