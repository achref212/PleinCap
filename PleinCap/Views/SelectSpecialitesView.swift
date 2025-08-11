import SwiftUI

struct SelectSpecialitesView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    @State private var selectedSpecialites: Set<String> = []   // DISPLAY strings (accented)
    @State private var goToNext = false
    @State private var isSaving = false

    let niveau: String           // "Première" | "Terminale"
    let voie: String             // "Générale" | "Technologique"
    let filiere: String          // e.g. "STMG", "STI2D", ... or "" when voie = Générale
    let preselectedDefaults: [String]   // defaults from previous step (sanitized or not)

    private var isTerminale: Bool { niveau.folding(options: [.diacriticInsensitive], locale: .init(identifier: "fr_FR")).lowercased() == "terminale" }

    // Max per-section allowed (Première: 3, Terminale: 2)
    private var maxSelectionDefault: Int { isTerminale ? 2 : 3 }

    // Normalize the defaults once
    private var defaultSetSanitized: Set<String> {
        Set(preselectedDefaults.map { $0.sanitizedFR })
    }

    // MARK: - Specialités par filière / voie (groupées, DISPLAY version)
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
            if isTerminale {
                return ["Territoires et technologie (Terminale)": [
                    "Aménagement", "Production", "Agroéquipement", "Services", "Transformation",
                    "Gestion des ressources et de l'alimentation", "Territoires et sociétés"
                ]]
            } else {
                return ["Technologie STAV (Première)": [
                    "Aménagement", "Production", "Agroéquipement", "Services", "Transformation",
                    "Gestion des ressources et de l'alimentation", "Territoires et sociétés"
                ]]
            }

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
                "Physique-chimie", "Outils et langages numériques", "Design et métiers d’art",
                "Analyse et méthodes en design", "Conception et création en design et métiers d’art"
            ]]

        default:
            return [:]
        }
    }

    // Helper: is a DISPLAY option one of the defaults (by sanitized comparison)?
    private func isDefault(_ optionDisplay: String) -> Bool {
        defaultSetSanitized.contains(optionDisplay.sanitizedFR)
    }

    // Max per-section before defaults
    private var maxSelectionPerSectionBase: [String: Int] {
        var config: [String: Int] = [:]
        for key in groupedSpecialites.keys {
            switch key {
            case "Culture et sciences", "Pratique artistique":
                config[key] = 1
            case "Spécialité STMG Terminale",
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

    // Effective max once defaults are counted
    private func effectiveMax(for section: String) -> Int {
        let base = maxSelectionPerSectionBase[section] ?? maxSelectionDefault
        let defaultsCount = (groupedSpecialites[section] ?? []).filter { isDefault($0) }.count
        return max(0, base - defaultsCount)
    }

    // Sections to show (defaults removed)
    private var visibleSections: [(title: String, options: [String], max: Int)] {
        Array(groupedSpecialites.keys)
            .sorted()
            .compactMap { key in
                let all = groupedSpecialites[key] ?? []
                let remaining = all.filter { !isDefault($0) }
                let limit = effectiveMax(for: key)
                return (remaining.isEmpty || limit == 0) ? nil : (key, remaining, limit)
            }
    }

    // Validation counting defaults + picks in each section
    private func isValidSelection() -> Bool {
        for (section, options, _) in visibleSections {
            let baseMax = maxSelectionPerSectionBase[section] ?? maxSelectionDefault
            let defaultsCount = (groupedSpecialites[section] ?? []).filter { isDefault($0) }.count
            let picksCount = options.filter { selectedSpecialites.contains($0) }.count
            let combined = defaultsCount + picksCount
            if combined < 1 || combined > baseMax { return false }
        }
        return true
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressBarView(progress: $progress)
                        .padding(.top)

                    ImageWithCaptionView(imageName: "Specialite", caption: "Spécialités")

                    header

                    VStack(spacing: 16) {
                        ForEach(visibleSections, id: \.title) { section in
                            AccordionCheckboxSectionView(
                                title: section.title,
                                options: section.options,
                                maxSelection: section.max,
                                selectedItems: $selectedSpecialites
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 120)
            }

            // Footer
            VStack {
                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : (visibleSections.isEmpty ? "Continuer" : "Suivant"),
                    enabled: (visibleSections.isEmpty || isValidSelection()) && !isSaving
                ) {
                    saveAndNavigate()
                }
                .padding(.horizontal)

                NavigationLink(
                    destination: SelectAcademieView(progress: $progress)
                        .environmentObject(authVM),
                    isActive: $goToNext
                ) { EmptyView() }
                .hidden()
            }
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Choix des spécialités")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Convert any saved sanitized values back to DISPLAY strings when possible,
            // then remove defaults from initial selection.
            let savedSanitized = Set((authVM.specialites ?? []).map { $0.sanitizedFR })
            let allDisplay = groupedSpecialites.values.flatMap { $0 }
            let savedDisplay = allDisplay.filter { savedSanitized.contains($0.sanitizedFR) }
            selectedSpecialites = Set(savedDisplay.filter { !isDefault($0) })

            progress = max(progress, 0.6)

            if visibleSections.isEmpty {
                DispatchQueue.main.async {
                    withAnimation {
                        progress = max(progress, 0.7)
                        goToNext = true
                    }
                }
            }
        }
        .alert(item: $authVM.errorMessage) { err in
            Alert(title: Text("Erreur"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle().fill(Color.orange).frame(width: 4).cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choisis tes spécialités")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text(visibleSections.isEmpty
                     ? "Tes spécialités par défaut couvrent déjà ce qu’il faut."
                     : "Fais au moins un choix par groupe (jusqu’à \(maxSelectionDefault) pour certains).")
                    .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func saveAndNavigate() {
        isSaving = true
        // Persist sanitized defaults + sanitized picks
        let combinedSanitized = Array(
            defaultSetSanitized.union(selectedSpecialites.map { $0.sanitizedFR })
        ).sorted()

        authVM.updateUserFields(["specialites": combinedSanitized]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.specialites = combinedSanitized
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
