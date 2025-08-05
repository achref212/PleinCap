import SwiftUI

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
struct FormationsView: View {
    @StateObject private var viewModel = FormationViewModel()
    
    private var groupedFormations: [String: [Formation]] {
        Dictionary(grouping: viewModel.formations, by: { $0.typeFormation ?? "Unknown" })
    }
    
    // Predefined set of 10 random images
    private let randomImages = [
        "image1", "image2", "image3", "image4", "image5",
        "image6", "image7", "image8", "image9", "image10"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F4F6F8").ignoresSafeArea()
                CircleBackgroundBottomView()
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommandations pour Vous")
                            .font(.title2.bold())
                            .foregroundColor(Color(hex: "#00B8D9"))
                        
                        Text("Basées sur ton profil et tes centres d'intérêt")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            ForEach(groupedFormations.sorted(by: { $0.key < $1.key }), id: \.key) { typeFormation, items in
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(typeFormation)
                                        .font(.title3.bold())
                                        .foregroundColor(Color(hex: "#2C4364"))
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 20) {
                                            ForEach(Array(items.enumerated()), id: \.1.id) { index, formation in
                                                NavigationLink(destination: FormationDetailsView(formationId: formation.id)) {
                                                    FormationCardView(
                                                        image: Image(randomImages[index % randomImages.count]), // Random image
                                                        title: formation.titre,
                                                        university: formation.etablissement,
                                                        description: formation.resumeProgramme ?? "No description available",
                                                        location: formation.lieu?.ville ?? "Unknown location",
                                                        price: formation.prixAnnuel.map { String(format: "%.2f €", $0) } ?? "N/A",
                                                        duration: formation.duree ?? "N/A",
                                                        isPublic: formation.formationControleeParEtat
                                                    )
                                                    .frame(width: UIScreen.main.bounds.width * 0.75)
                                                    .padding(.leading, index == 0 ? 16 : 0)
                                                }
                                            }
                                        }
                                        .padding(.trailing, 20)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitle("Formations", displayMode: .inline)
        }
        .onAppear {
            viewModel.fetchFormations()
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    FormationsView()
}
