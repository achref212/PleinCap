import SwiftUI

struct SelectVoieView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var progress: Double
    let niveau: String

    @State private var selectedVoie: String? = nil
    @State private var goToNext = false

    let filieres = ["Générale", "Technologique", "Professionnelle"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressBarView(progress: $progress)
                        .padding(.top)

                    ImageWithCaptionView(imageName: "GTPro", caption: "Voie")

                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4)
                            .cornerRadius(2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quelle est ta filière actuelle ?")
                                .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    voieSelectionSection
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 24)
            }

            PrimaryGradientButton(title: "Suivant", enabled: selectedVoie != nil) {
                if let voie = selectedVoie {
                    authVM.updateUserFields(["voie": voie]) {
                        goToNext = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedVoie = nil
        }
        .navigationDestination(isPresented: $goToNext) {
            if selectedVoie == "Générale" {
                SelectSpecialitesView(progress: $progress, niveau: niveau, voie:"Générale",                     filiere: nil) { _ in }
            } else if selectedVoie == "Technologique" {
                SelectFiliereView(progress: $progress, niveau: niveau)
            } else {
                EmptyView()
            }
        }
    }

    private var voieSelectionSection: some View {
        VStack(spacing: 16) {
            ForEach(filieres, id: \.self) { filiere in
                voieCard(for: filiere)
            }
        }
        .padding(.horizontal)
    }

    private func voieCard(for filiere: String) -> some View {
        VStack(spacing: 4) {
            let isDisabled = filiere == "Professionnelle"
            SelectableCardV2View(
                title: filiere,
                isSelected: selectedVoie == filiere,
                disabled: isDisabled
            )
            .opacity(isDisabled ? 0.5 : 1.0)
            .onTapGesture {
                guard !isDisabled else { return }
                if selectedVoie == nil {
                    progress = min(progress + 0.1, 1.0)
                }
                selectedVoie = filiere
            }

            if isDisabled {
                Text("Bientôt disponible")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
        }
    }
}

struct SelectVoieView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.3
        @StateObject var authVM = AuthViewModel()

        var body: some View {
            NavigationStack {
                SelectVoieView(progress: $progress, niveau: "Terminale")
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            Wrapper().preferredColorScheme(.light)
            Wrapper().preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
