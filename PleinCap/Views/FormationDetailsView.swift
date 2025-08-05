import SwiftUI

struct FormationDetailsView: View {
    @EnvironmentObject var viewModel: FormationViewModel
    let formationId: Int
    @State private var formation: Formation? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let formation = viewModel.selectedFormation { // Use selectedFormation from ViewModel
                    // Image et tags
                    ZStack(alignment: .topTrailing) {
                        // Use the random image assigned in FormationsView (passed via viewModel if needed)
                        Image(uiImage: randomImage(for: formationId)) // Placeholder; adjust based on FormationsView
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(20)

                        VStack(alignment: .trailing, spacing: 10) {
                            HStack(spacing: 8) {
                                TagView(text: formation.lieu?.ville ?? "Unknown location")
                                TagView(text: formation.prixAnnuel.map { String(format: "%.2f €", $0) } ?? "N/A")
                                TagView(text: formation.duree ?? "N/A")
                            }

                            HStack(spacing: 8) {
                                TagView(text: "contrôlée par l’État")
                                TagView(text: formation.formationControleeParEtat ? "Public" : "Privé")
                            }
                        }
                        .padding()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        TitleWithSideLineView(
                            title: formation.titre,
                            subtitle: formation.etablissement
                        )

                        Text(formation.resumeProgramme ?? "No description available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Section : Informations Générales
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informations Générales")
                            .font(.title3.bold())
                            .foregroundColor(.accentColor)

                        CardView {
                            TitleWithSideLineView(title: "Durées & Niveau", subtitle: "")

                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Durée formation", value: formation.duree ?? "N/A")
                                InfoRow(title: "Durée totale du cursus", value: "N/A") // Adjust if data exists
                            }
                        }

                        CardView {
                            TitleWithSideLineView(title: "Programme & Débouchés", subtitle: "")

                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Résumé du programme", value: formation.resumeProgramme ?? "N/A")
                                InfoRow(title: "Débouchés pro", value: formation.debouchesMetiers?.map { $0.metier }.joined(separator: ", ") ?? "N/A")
                                InfoRow(title: "Débouchés études", value: formation.poursuiteEtudes ?? "N/A")
                                InfoRow(title: "Débouchés domaines / secteurs", value: formation.debouchesSecteurs?.map { $0.secteur }.joined(separator: ", ") ?? "N/A")
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Section : Informations personnalisées
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informations Personnalisées")
                            .font(.title3.bold())
                            .foregroundColor(.accentColor)

                        CardView {
                            TitleWithSideLineView(title: "Organisation pédagogique", subtitle: "")

                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Taille des groupes", value: "N/A") // Adjust if data exists
                                InfoRow(title: "Degré d'autonomie", value: "N/A")
                                InfoRow(title: "Manuel / Intellect", value: "N/A")
                                InfoRow(title: "Théorique", value: "N/A")
                                InfoRow(title: "Pratique", value: "N/A")
                                InfoRow(title: "Charge de travail", value: "N/A")
                            }
                        }

                        CardView {
                            TitleWithSideLineView(title: "Parcours & accompagnement", subtitle: "")

                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Stage ou immersion pro", value: formation.apprentissage ?? "N/A")
                                InfoRow(title: "Formation en apprentissage", value: formation.apprentissage ?? "N/A")
                                InfoRow(title: "Type de formation", value: formation.typeFormation ?? "N/A")
                                InfoRow(title: "Liberté de choix", value: "N/A")
                            }
                        }

                        CardView {
                            TitleWithSideLineView(title: "Ouverture & compatibilité", subtitle: "")

                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Ouverture internationale", value: "N/A") // Adjust if data exists
                                InfoRow(title: "Caractéristiques RIASEC", value: "N/A")
                                InfoRow(title: "Taux d’insertion pro", value: formation.tauxInsertion ?? "N/A")
                                InfoRow(title: "Correspondance géographique", value: formation.lieu?.ville ?? "N/A")
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Bouton ONISEP
                    if let lienOnisep = formation.lienOnisep {
                        Link(destination: URL(string: lienOnisep)!) {
                            Text("Voir sur ONISEP")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Détails Formation")
        .onAppear {
            viewModel.fetchFormation(id: formationId) // Trigger fetch without trailing closure
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    // Placeholder to simulate random image assignment
    private func randomImage(for id: Int) -> UIImage {
        let imageName = randomImages[id % randomImages.count]
        return UIImage(named: imageName) ?? UIImage()
    }
    
    // Predefined set of 10 random images
    private let randomImages = [
        "image1", "image2", "image3", "image4", "image5",
        "image6", "image7", "image8", "image9", "image10"
    ]
}

// MARK: - Formation Preview
#Preview {
    FormationDetailsView(formationId: 1)
        .environmentObject(FormationViewModel())
}
