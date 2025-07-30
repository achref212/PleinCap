import SwiftUI

struct SelectSpecialitesView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var progress: Double
    @State private var selectedSpecialites: Set<String> = []
    @State private var goToNext = false

    let niveau: String
    let voie: String
    let filiere: String?
    let onSpecialitesSelected: ([String]) -> Void

    var maxSelection: Int {
        niveau.lowercased() == "terminale" ? 2 : 3
    }

    var groupedSpecialites: [String: [String]] {
        if voie.lowercased() == "générale" {
            return [
                "Arts (au choix)": ["Histoire des arts", "Théâtre", "Arts plastiques", "Arts du cirque","Cinéma-audiovisuel", "Danse", "Musique"],
               
                "Scientifiques": [
                    "Biologie, écologie", "Éducation physique", "Histoire-géo / géopolitique",
                    "Humanités / philosophie", "Langues vivantes",
                    "Langues anciennes", "Mathématiques", "Numérique et informatique",
                    "Physique-chimie", "Sciences de la vie et de la Terre", "Sciences de l’ingénieur"
                ]
            ]
        }

        switch filiere?.uppercased() {
        case "STMG":
            return ["Spécialités STMG": [
                "Droit et économie & Gestion et finances",
                "Droit et économie & Mercatique (marketing)",
                "Droit et économie & RH et communication",
                "Droit et économie & SIG"
            ]]
        case "STI2D":
            return ["Spécialités STI2D": [
                "PC + Maths & Innovation technologique",
                "PC + Maths & Systèmes numériques",
                "PC + Maths & Énergies et environnement",
                "PC + Maths & Architecture et construction"
            ]]
        case "STL":
            return ["Spécialités STL": [
                "Biochimie-biologie-biotechnologies",
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
        case "STAV":
            return ["Spécialités STAV": [
                "Ressources & Territoires (production)",
                "Ressources & Territoires (services)",
                "Ressources & Territoires (transformation)",
                "Ressources & Territoires (agroéquipement)"
            ]]
        case "S2TMD":
            return ["Spécialités S2TMD": [
                "Sciences et techniques de la danse",
                "Sciences et techniques du théâtre",
                "Sciences et techniques de la musique"
            ]]
        default:
            return [:]
        }
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

                            Text("Il faut choisir \(maxSelection) spécialités")
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
                                    maxSelection: maxSelection,
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
                PrimaryGradientButton(title: "Suivant", enabled: !selectedSpecialites.isEmpty) {
                    if !selectedSpecialites.isEmpty {
                        authVM.updateUserFields(["specialites": Array(selectedSpecialites)]) {
                            onSpecialitesSelected(Array(selectedSpecialites))
                            goToNext = true
                        }
                    }
                }
                .padding(.horizontal)

                NavigationLink(destination: SelectEtablissementView( progress: $progress), isActive: $goToNext) {
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
                    niveau: "Terminale",
                    voie: "Technologique",
                    filiere: "STI2D"
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
