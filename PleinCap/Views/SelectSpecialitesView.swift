import SwiftUI

struct SelectSpecialitesView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var progress: Double
    @State private var selectedSpecialites: Set<String> = []
    @State private var goToNext = false

    let niveau: String
    let voie: String
    let filiere: String?
    let onSpecialitesSelected: ([String]) -> Void

    var isTerminale: Bool {
        niveau.lowercased() == "terminale"
    }

    var maxSelectionDefault: Int {
        isTerminale ? 2 : 3
    }

    var groupedSpecialites: [String: [String]] {
        switch filiere?.uppercased() {
        case "STMG":
            if isTerminale {
                return ["Spécialité STMG Terminale": [
                    "Gestion et finances",
                    "Mercatique",
                    "Ressources humaines et communication",
                    "Systèmes d’information de gestion"
                ]]
            }
        case "STAV":
            if isTerminale {
                return ["Territoires et technologie": [
                    "Aménagement",
                    "Production",
                    "Agroéquipement",
                    "Services",
                    "Transformation"
                ]]
            } else {
                return ["Technologie STAV": [
                    "Aménagement",
                    "Production",
                    "Agroéquipement",
                    "Services",
                    "Transformation"
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
                "Sciences sanitaires et sociales & Physio humaine"
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
        case "GÉNÉRALE":
            return [
                "Arts (au choix)": ["Histoire des arts", "Théâtre", "Arts plastiques", "Arts du cirque", "Cinéma-audiovisuel", "Danse", "Musique"],
                "Scientifiques": [
                    "Biologie, écologie", "Éducation physique", "Histoire-géo / géopolitique",
                    "Humanités / philosophie", "Langues vivantes",
                    "Langues anciennes", "Mathématiques", "Numérique et informatique",
                    "Physique-chimie", "Sciences de la vie et de la Terre", "Sciences de l’ingénieur"
                ]
            ]
        default:
            return [:]
        }
        return [:]
    }

    var maxSelectionPerSection: [String: Int] {
        var config: [String: Int] = [:]
        for key in groupedSpecialites.keys {
            switch key {
            case "Culture et sciences", "Pratique artistique":
                config[key] = 1
            case "Spécialité STMG Terminale",
                 "Spécialité STI2D",
                 "Spécialités STL",
                 "Technologie STAV",
                 "Territoires et technologie":
                config[key] = 1
            default:
                config[key] = maxSelectionDefault
            }
        }
        return config
    }

    func isValidSelection() -> Bool {
        for (section, max) in maxSelectionPerSection {
            let selectedInSection = groupedSpecialites[section]?.filter { selectedSpecialites.contains($0) } ?? []
            if selectedInSection.count != max {
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

                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4)
                            .cornerRadius(2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Choisis tes spécialités")
                                .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title3.bold())
                                .foregroundColor(Color(hex: "#2C4364"))

                            Text("Tu dois faire une sélection dans chaque groupe")
                                .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

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

            VStack {
                PrimaryGradientButton(
                    title: "Suivant",
                    enabled: isValidSelection()
                ) {
                    let defaultSpecialties = authVM.specialites ?? []
                    let combinedSpecialties = Array(Set(defaultSpecialties + Array(selectedSpecialites)))
                    
                    print("✅ Combined specialties: \(combinedSpecialties)")

                    authVM.updateUserFields(["specialites": combinedSpecialties]) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("✅ Données utilisateur mises à jour") // Debug
                            authVM.specialites = combinedSpecialties // Update local state
                            onSpecialitesSelected(combinedSpecialties)

                            withAnimation {
                                goToNext = true
                            }
                        }
                    }
                }
                .padding(.horizontal)

                NavigationLink(destination: SelectEtablissementView(progress: $progress), isActive: $goToNext) {
                    EmptyView()
                }
            }
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSpecialites = []
        }
    }
}

struct SelectSpecialitesView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.5
        @StateObject var authVM = AuthViewModel()

        var body: some View {
            NavigationStack {
                SelectSpecialitesView(
                    progress: $progress,
                    niveau: "premiere",
                    voie: "GÉNÉRALE",
                    filiere: "GÉNÉRALE"
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
