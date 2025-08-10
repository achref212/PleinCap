import SwiftUI

struct SelectObjectiveView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel1

    @State private var selectedObjective: String? = nil
    @State private var progress: Double = 0.0
    @State private var goToNext = false
    @State private var goToOrientationChoices = false

    private let objectives: [String] = [
        "Je ne sais pas quoi faire après le bac et je veux trouver des idées !",
        "J’ai quelques idées de ce que je voudrais faire après le bac"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress
                ProgressBarView(progress: $progress)
                    .padding(.top)

                ImageWithCaptionView(imageName: "ThinkingStudent", caption: "Objectif")

                titleSection
                cardsSection

                PrimaryGradientButton(title: "Suivant", enabled: selectedObjective != nil) {
                    guard let selected = selectedObjective else { return }

                    authVM.updateUserFields(["objectif": selected]) { result in
                        switch result {
                        case .success:
                            authVM.objectif = selected
                            withAnimation { progress = max(progress, 0.2) }

                            withAnimation {
                                if selected == "J’ai quelques idées de ce que je voudrais faire après le bac" {
                                    goToOrientationChoices = true
                                } else {
                                    goToNext = true
                                }
                            }

                        case .failure(let error):
                            authVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(error.localizedDescription)")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)

                // 👉 To classic flow
                NavigationLink(
                    destination: SelectLevelView(progress: $progress)
                        .onAppear { withAnimation { progress = max(progress, 0.3) } },
                    isActive: $goToNext
                ) { EmptyView() }
                .hidden()

                // 👉 To orientation choices (the page before IdeaClarifyView)
                NavigationLink(
                    destination: OrientationChoicesView()
                        .environmentObject(authVM)
                        .onAppear { withAnimation { progress = max(progress, 0.3) } },
                    isActive: $goToOrientationChoices
                ) { EmptyView() }
                .hidden()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedObjective = nil
            progress = 0.0
            goToNext = false
            goToOrientationChoices = false
        }
        .alert(item: $authVM.errorMessage) { error in
            Alert(title: Text("Erreur"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }

    private var titleSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Définir ton objectif")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Où en es-tu pour le moment ?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var cardsSection: some View {
        VStack(spacing: 15) {
            ForEach(objectives, id: \.self) { option in
                SelectableCardView(
                    title: option,
                    isSelected: selectedObjective == option
                )
                .onTapGesture {
                    withAnimation {
                        if selectedObjective == nil {
                            progress = min(progress + 0.1, 1.0)
                        }
                        selectedObjective = option
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SelectObjectiveView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                SelectObjectiveView()
                    .environmentObject(AuthViewModel1())
                    .preferredColorScheme(.light)
                    .environment(\.dynamicTypeSize, .medium)
            }
            NavigationStack {
                SelectObjectiveView()
                    .environmentObject(AuthViewModel1())
                    .preferredColorScheme(.dark)
                    .environment(\.dynamicTypeSize, .accessibility3)
            }
        }
    }
}
