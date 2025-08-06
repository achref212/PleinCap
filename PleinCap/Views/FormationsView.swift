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
                    headerSection
                    contentSection
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
    
    // MARK: - Sub-sections
    
    private var headerSection: some View {
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
    }
    
    private var contentSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(groupedFormations.sorted(by: { $0.key < $1.key }), id: \.key) { typeFormation, items in
                    formationGroupSection(typeFormation: typeFormation, items: items)
                }
            }
            .padding(.bottom, 32)
        }
    }
    
    private func formationGroupSection(typeFormation: String, items: [Formation]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(typeFormation)
                .font(.title3.bold())
                .foregroundColor(Color(hex: "#2C4364"))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(Array(items.enumerated()), id: \.1.id) { index, formation in
                        navigationLinkForFormation(index: index, formation: formation)
                    }
                }
                .padding(.trailing, 20)
            }
        }
    }
    
    private func navigationLinkForFormation(index: Int, formation: Formation) -> some View {
        NavigationLink(destination: FormationDetailsView(formationId: formation.id)) {
            formationCardView(index: index, formation: formation)
        }
    }
    
    private func formationCardView(index: Int, formation: Formation) -> some View {
        let imageName = randomImages[index % randomImages.count]
        let image = Image(imageName)
        let university = formation.etablissement
        let description = formation.resumeProgramme ?? "No description available"
        let location = formation.lieu?.ville ?? "Unknown location"
        let price = formation.prixAnnuel!
        let duration = formation.duree ?? "N/A"
        let isPublic = formation.formationControleeParEtat ?? false
        
        return FormationCardView(
            image: image,
            title: formation.titre,
            university: university,
            description: description,
            location: location,
            price: price,
            duration: duration,
            isPublic: isPublic
        )
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .padding(.leading, index == 0 ? 16 : 0)
    }
}

#Preview {
    FormationsView()
}
