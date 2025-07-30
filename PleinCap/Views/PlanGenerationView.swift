import SwiftUI

struct PlanGenerationView: View {
    @State private var navigateToNext = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F4F6F8").ignoresSafeArea()

                CircleBackgroundBottomView()

                VStack(spacing: 40) {
                    // Illustration
                    Image("planIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .padding(.top, 80)

                    // Loader
                    LoaderWithSubtitle(subtitle: "Génération d’un plan d’action personnalisé…")

                    Spacer()
                }
                .padding(.horizontal)

                // NavigationLink invisible
                NavigationLink(
                    destination: FinalPlanView(),
                    isActive: $navigateToNext,
                    label: { EmptyView() }
                )
            }
            .onAppear {
                // Attente de 3 secondes avant de naviguer
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    navigateToNext = true
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
#Preview {
    PlanGenerationView()
}
