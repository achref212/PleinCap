import SwiftUI

struct SelectVoieView: View {
    @Binding var progress: Double
    let niveau: String

    @EnvironmentObject var authVM: AuthViewModel1
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedVoie: String? = nil
    @State private var goToSpecialitesGeneral = false
    @State private var goToFiliereTech = false
    @State private var isSaving = false

    private let voies: [(title: String, subtitle: String)] = [
        ("Générale", "Baccalauréat général avec choix de spécialités."),
        ("Technologique", "Baccalauréat technologique avec choix d’une filière.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress
                ProgressBarView(progress: $progress)
                    .padding(.top)

                ImageWithCaptionView(imageName: "GTPro", caption: "Ta voie")

                header
                cardsSection
                buttonSection

                // Navigation branches (hidden links)
                NavigationLink(
                    destination: SelectSpecialitesView(
                        progress: $progress,
                        niveau: niveau,
                        voie: "Générale",
                        filiere: nil
                    ) { _ in }
                    .environmentObject(authVM),
                    isActive: $goToSpecialitesGeneral,
                    label: { EmptyView() }
                )
                .hidden()

                NavigationLink(
                    destination: SelectFiliereView(
                        progress: $progress,
                        niveau: niveau
                    ).environmentObject(authVM),
                    isActive: $goToFiliereTech,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Choix de la voie")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { preloadSelection() }
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
                Text("Choisis ta voie")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title2.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Cela déterminera la suite des choix (filière ou spécialités).")
                    .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var cardsSection: some View {
        VStack(spacing: 16) {
            ForEach(voies, id: \.title) { voie in
                SelectableCardView(
                    title: voie.title,
                    subtitle: voie.subtitle,
                    isSelected: selectedVoie == voie.title
                )
                .onTapGesture {
                    withAnimation {
                        if selectedVoie == nil { progress = min(progress + 0.1, 1.0) }
                        selectedVoie = voie.title
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var buttonSection: some View {
        PrimaryGradientButton(
            title: isSaving ? "Enregistrement..." : "Suivant",
            enabled: selectedVoie != nil && !isSaving
        ) {
            saveAndNavigate()
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    // MARK: - Actions

    private func preloadSelection() {
        // Pré-sélectionne si déjà enregistré (UX sympa)
        if let existing = authVM.voie, !existing.isEmpty {
            selectedVoie = existing
            progress = max(progress, 0.4)
        } else {
            progress = max(progress, 0.3)
        }
        goToSpecialitesGeneral = false
        goToFiliereTech = false
    }

    private func saveAndNavigate() {
        guard let choice = selectedVoie else { return }
        isSaving = true

        authVM.updateUserFields(["voie": choice]) { result in
            isSaving = false
            switch result {
            case .success:
                authVM.voie = choice
                withAnimation {
                    progress = max(progress, 0.45)
                    if choice == "Générale" {
                        goToSpecialitesGeneral = true
                    } else { // Technologique
                        goToFiliereTech = true
                    }
                }
            case .failure(let error):
                authVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview

struct SelectVoieView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var progress: Double = 0.35
        @StateObject private var authVM = AuthViewModel1()

        var body: some View {
            NavigationStack {
                SelectVoieView(progress: $progress, niveau: "Terminale")
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            PreviewWrapper()
                .preferredColorScheme(.light)

            PreviewWrapper()
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
