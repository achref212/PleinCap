import SwiftUI

struct SelectLevelView: View {
    @State private var selectedLevel: String? = nil
    @Binding var progress: Double
    @State private var goToOptions = false

    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // ✅ Seulement "Première" et "Terminale"
    let levels = [
        ("Première", "Tu es en classe de Première."),
        ("Terminale", "Tu es en classe de Terminale.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressSection
                imageSection
                titleSection
                cardsSection
                buttonSection
                navigationSection
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Choix du niveau")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resetState()
        }
    }

    // MARK: - Sub-sections

    private var progressSection: some View {
        ProgressBarView(progress: $progress)
            .padding(.top)
    }

    private var imageSection: some View {
        ImageWithCaptionView(imageName: "Study", caption: "Tu es en :")
    }

    private var titleSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choisis ton niveau")
                    .font(dynamicTypeSize.isAccessibilitySize ? .title2.bold() : .title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Cela nous permettra de mieux t’orienter.")
                    .font(dynamicTypeSize.isAccessibilitySize ? .body : .subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var cardsSection: some View {
        VStack(spacing: 16) {
            ForEach(levels, id: \.0) { level in
                SelectableCardView(
                    title: level.0,
                    subtitle: level.1,
                    isSelected: selectedLevel == level.0
                )
                .onTapGesture {
                    updateSelection(for: level.0)
                }
            }
        }
        .padding(.horizontal)
    }

    private var buttonSection: some View {
        PrimaryGradientButton(title: "Suivant", enabled: selectedLevel != nil) {
            if let level = selectedLevel {
                print("Calling updateUserFields with niveau_scolaire: \(level)") // Debug
                authVM.updateUserFields(["niveau_scolaire": level]) {
                    DispatchQueue.main.async {
                        print("updateUserFields completed") // Debug
                        // Update local state directly on authVM
                      
                        goToOptions = true
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var navigationSection: some View {
        NavigationLink(
            destination: SelectVoieView(progress: $progress, niveau: selectedLevel ?? ""),
            isActive: $goToOptions,
            label: { EmptyView() }
        )
        .disabled(selectedLevel == nil)
    }

    // MARK: - Helper Methods

    private func resetState() {
        selectedLevel = nil
        progress = 0.2
        goToOptions = false
    }

    private func updateSelection(for level: String) {
        if selectedLevel == nil {
            progress = min(progress + 0.1, 1.0)
        }
        selectedLevel = level
    }
}

struct SelectLevelView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var progress: Double = 0.2
        @StateObject private var authVM = AuthViewModel()

        var body: some View {
            NavigationStack {
                SelectLevelView(progress: $progress)
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
