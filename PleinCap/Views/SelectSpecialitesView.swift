import SwiftUI

struct SelectSpecialitesView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    @State private var selectedSpecialites: Set<String> = []
    @State private var goToNext = false
    @State private var isSaving = false

    let niveau: String           // "Première" | "Terminale"
    let voie: String             // "Générale" | "Technologique"
    let filiere: String?         // e.g. "STMG", "STI2D", ... or nil for "Générale"
    let onSpecialitesSelected: ([String]) -> Void

    private var isTerminale: Bool {
        niveau.lowercased() == "terminale"
    }

    // Max per-section allowed (Première: 3, Terminale: 2)
    private var maxSelectionDefault: Int {
        isTerminale ? 2 : 3
    }

    // MARK: - Specialités par filière / voie
    private var groupedSpecialites: [String: [String]] {
        if voie.localizedCaseInsensitiveCompare("Générale") == .orderedSame {
            // Spécialités voie générale
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
                    "Langues, littératures et cultures étrangères", "Langues anciennes", "Sciences économiques et sociales"
                ]
            ]
        }

        switch filiere?.uppercased() {
        case "STMG":
            if isTerminale {
                return ["Spécialité STMG Terminale": [
                    "Gestion et finances",
                    "Mercatique",
                    "Ressources humaines et communication",
                    "Systèmes d’information de gestion"
                ]]
            } else { // Première
                return ["Spécialité STMG Première": [
                    "Droit et économie",
                    "Management",
                    "Sciences de gestion et du numérique"
                ]]
            }

        case "STAV":
            if isTerminale {
                return ["Territoires et technologie (Terminale)": [
                    "Aménagement", "Production", "Agroéquipement", "Services", "Transformation"
                ]]
            } else {
                return ["Technologie STAV (Première)": [
                    "Aménagement", "Production", "Agroéquipement", "Services", "Transformation"
                ]]
            }

        case "STI2D":
            if isTerminale {
                return ["Spécialité STI2D": [
                    "PC + Maths & Innovation technologique et éco-conception",
                    "PC + Maths & Systèmes d'information et numériques",
                    "PC + Maths & Énergies et environnement",
                    "PC + Maths & Architecture et construction"
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
                    "Culture et sciences théâtrales"
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
                "Sciences sanitaires et sociales & Physiologie humaine"
            ]]

        case "STHR":
            return ["Spécialités STHR": [
                "Économie et gestion hôtelière",
                "Sciences et technologies culinaires"
            ]]

        case "STD2A":
            return ["Spécialités STD2A": [
                "Création design & Analyse design"
            ]]

        default:
            return [:]
        }
    }

    /// Exigence de sélection par groupe: au moins 1, au plus `maxSelectionFor(section)`
    private var maxSelectionPerSection: [String: Int] {
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

    private func isValidSelection() -> Bool {
        for (section, max) in maxSelectionPerSection {
            let options = groupedSpecialites[section] ?? []
            let selectedInSection = options.filter { selectedSpecialites.contains($0) }
            // Au moins 1 par groupe, et pas plus que le max
            if selectedInSection.count < 1 || selectedInSection.count > max {
                return false
            }
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

                    // Sections d’options
                    VStack(spacing: 16) {
                        ForEach(Array(groupedSpecialites.keys).sorted(), id: \.self) { category in
                            if let options = groupedSpecialites[category] {
                                AccordionCheckboxSectionView(
                                    title: category,
                                    options: options,
                                    maxSelection: maxSelectionPerSection[category] ?? maxSelectionDefault,
                                    selectedItems: $selectedSpecialites
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 120)
            }

            // Footer
            VStack {
                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : "Suivant",
                    enabled: isValidSelection() && !isSaving
                ) {
                    saveAndNavigate()
                }
                .padding(.horizontal)

                NavigationLink(
                    destination:  SelectAcademieView(progress: $progress)
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
            // Pré-remplir depuis le backend si dispo
            selectedSpecialites = Set(authVM.specialites ?? [])
            progress = max(progress, 0.6)
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
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choisis tes spécialités")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Fais au moins un choix par groupe (jusqu’à \(maxSelectionDefault) pour certains).")
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
        let combined = Array(selectedSpecialites).sorted()

        authVM.updateUserFields(["specialites": combined]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.specialites = combined
                onSpecialitesSelected(combined)
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

// MARK: - Preview

struct SelectSpecialitesView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.6
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            NavigationStack {
                SelectSpecialitesView(
                    progress: $progress,
                    niveau: "Terminale",
                    voie: "Générale",
                    filiere: nil
                ) { _ in }
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
