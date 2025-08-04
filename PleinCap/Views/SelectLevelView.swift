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
                ProgressBarView(progress: $progress)
                    .padding(.top)

                ImageWithCaptionView(imageName: "Study", caption: "Tu es en :")

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

                VStack(spacing: 16) {
                    ForEach(levels, id: \.0) { level in
                        SelectableCardView(
                            title: level.0,
                            subtitle: level.1,
                            isSelected: selectedLevel == level.0
                        )
                        .onTapGesture {
                            if selectedLevel == nil {
                                progress = min(progress + 0.1, 1.0)
                            }
                            selectedLevel = level.0
                        }
                    }
                }
                .padding(.horizontal)

                // ✅ Bouton gradient custom
                PrimaryGradientButton(title: "Suivant", enabled: selectedLevel != nil) {
                    if let level = selectedLevel {
                        authVM.updateUserFields(["niveau_scolaire": level]) {
                            goToOptions = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // ✅ Navigation sécurisée
                NavigationLink(
                    destination: destinationView,
                    isActive: $goToOptions,
                    label: { EmptyView() }
                ).disabled(selectedLevel == nil)
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Choix du niveau")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedLevel = nil
            progress = 0.2
            goToOptions = false
        }
    }

    // ✅ Destination extraite pour éviter l'erreur SwiftUI
    @ViewBuilder
    private var destinationView: some View {
        if let level = selectedLevel {
            SelectVoieView(progress: $progress, niveau: level)
        } else {
            EmptyView()
        }
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
