import SwiftUI

struct SelectFiliereView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var progress: Double
    @State private var selectedFiliere: String? = nil
    @State private var goToSpecialites = false
    let niveau: String

    let filieresTechnos = [
        "STMG", "STI2D", "S2TMD", "ST2S", "STAV", "STD2A", "STHR", "STL"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressBarView(progress: $progress)
                        .padding(.top)

                    ImageWithCaptionView(imageName: "filiere", caption: "Filière")

                    // 🔹 Titre
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

                    // 🧩 Grille de sélection
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

            // 🔘 Bouton suivant
            VStack {
                PrimaryGradientButton(title: "Suivant", enabled: selectedFiliere != nil) {
                    if let filiere = selectedFiliere {
                        authVM.updateUserFields(["filiere": filiere]) {
                            goToSpecialites = true
                        }
                    }
                }

                NavigationLink(
                    destination: SelectSpecialitesView(
                        progress: $progress,
                        niveau: niveau, voie: "Technologique",filiere: selectedFiliere
                    ) { _ in },
                    isActive: $goToSpecialites,
                    label: { EmptyView() }
                )
            }
            .padding(.bottom, 16)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
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
