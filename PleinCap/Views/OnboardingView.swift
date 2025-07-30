import SwiftUI

private struct Step {
    let img, title, text: String
}

struct OnboardingView: View {
    @State private var page = 0
    @AppStorage("hasSeenOnboarding") private var hasSeen = false
    @Environment(\.dismiss) private var dismiss

    private let steps: [Step] = [
        .init(img:"onboarding1", title:"Découvre tes passions",
              text:"Identifie tes centres d’intérêt pour choisir la voie qui te ressemble."),
        .init(img:"onboarding2", title:"Explore les formations",
              text:"Accède à 24 000+ formations et trouve celle qui te correspond."),
        .init(img:"onboarding3", title:"Projette-toi",
              text:"Simule tes chances d’admission et prépare ton avenir.")
    ]

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack {
                Spacer(minLength: 40)

                TabView(selection: $page) {
                    ForEach(steps.indices, id: \.self) { i in
                        VStack(spacing: 32) {
                            Image(steps[i].img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 280, maxHeight: 260)
                                .padding(.top, 20)

                            OnboardingCard(title: steps[i].title,
                                           message: steps[i].text,
                                           total: steps.count,
                                           index: page)
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)

                Button {
                    if page < steps.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        hasSeen = true          // terminé
                        dismiss()
                    }
                } label: {
                    Text(page == steps.count - 1 ? "Commencer" : "Suivant")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .padding(.bottom, 36)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView().preferredColorScheme(.light)
            OnboardingView().preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
