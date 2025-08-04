import SwiftUI

struct SelectFiliereView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var progress: Double
    @State private var selectedFiliere: String? = nil
    @State private var goToSpecialites = false
    @State private var goToEtablissement = false
    let niveau: String

    let filieresTechnos = [
        "STMG", "STI2D", "S2TMD", "ST2S", "STAV", "STD2A", "STHR", "STL"
    ]

    let filieresAvecChoix: Set<String> = ["STMG", "STI2D", "S2TMD", "STAV", "STL"]

    var defaultSpecialites: [String] {
        guard let filiere = selectedFiliere else { return [] }

        switch filiere.uppercased() {
        case "STMG":
            return niveau.lowercased() == "première" ?
                ["Droit et économie", "Management", "Sciences de gestion et du numérique"] :
                ["Droit et économie"]

        case "ST2S":
            return niveau.lowercased() == "première" ?
                ["Physique chimie pour la santé", "Biologie et physiopathologie humaines", "Sciences et techniques sanitaires et sociales"] :
                ["Sciences et techniques sanitaires et sociales", "Chimie, biologie et physiopathologie humaines"]

        case "STHR":
            return ["Économie et gestion hôtelière", "Sciences et technologies culinaires"]

        case "STD2A":
            return niveau.lowercased() == "première" ?
                ["Physique-chimie", "Outils et langages numériques", "Design et métiers d’art"] :
                ["Analyse et méthodes en design", "Conception et création en design et métiers d’art"]

        case "STAV":
            return niveau.lowercased() == "première" ?
                ["Gestion des ressources et de l'alimentation", "Territoires et sociétés"] :
                ["Gestion des ressources et de l'alimentation"]

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

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 16)], spacing: 16) {
                            ForEach(filieresTechnos, id: \.self) { filiere in
                                SelectableCardGridView(
                                    title: filiere,
                                    isSelected: selectedFiliere == filiere,
                                    onTap: {
                                        if selectedFiliere == nil {
                                            progress = min(progress + 0.1, 1.0)
                                        }
                                        selectedFiliere = filiere
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }

                PrimaryGradientButton(title: "Suivant", enabled: selectedFiliere != nil) {
                    guard let filiere = selectedFiliere else { return }

                    print("✅ Filière sélectionnée : \(filiere)")

                    let specialitesList = defaultSpecialites

                    // 1️⃣ Stockage pour l'utilisateur
                    authVM.updateUserFields([
                        "filiere": filiere,
                        "specialites": specialitesList
                    ]) {
                        print("✅ Données utilisateur mises à jour")

                        // 2️⃣ Stockage pour la moyenne
                        authVM.specialty = specialitesList
                        authVM.submitMoyenne {
                            print("✅ Données moyenne mises à jour")

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if filieresAvecChoix.contains(filiere.uppercased()) {
                                    goToSpecialites = true
                                } else {
                                    goToEtablissement = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }

            // 🔁 Navigation
            NavigationLink(
                destination: SelectSpecialitesView(
                    progress: $progress,
                    niveau: niveau,
                    voie: "Technologique",
                    filiere: selectedFiliere
                ) { _ in },
                isActive: $goToSpecialites
            ) { EmptyView() }
            .hidden()

            NavigationLink(
                destination: SelectEtablissementView(progress: $progress),
                isActive: $goToEtablissement
            ) { EmptyView() }
            .hidden()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("📍 SelectFiliereView chargée")
            selectedFiliere = nil
        }
    }
}

struct SelectFiliereView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.4
        @StateObject var authVM = AuthViewModel()

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
