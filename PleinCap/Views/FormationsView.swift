import SwiftUI

struct Formation: Identifiable {
    let id = UUID()
    let title: String
    let university: String
    let description: String
    let location: String
    let price: String
    let duration: String
    let isPublic: Bool
    let domain: String
    let imageName: String
}

struct FormationsView: View {
    private let formations: [Formation] = [
        Formation(
            title: "Licence en Droit",
            university: "Université Paris 1 Panthéon-Sorbonne",
            description: "Formation d'excellence en droit avec une approche pluridisciplinaire.",
            location: "Paris, France",
            price: "175 € /année",
            duration: "3 ans",
            isPublic: true,
            domain: "Droits",
            imageName: "Etablissement_France1"
        ),
        Formation(
            title: "Sciences Humaines et Sociales",
            university: "Sciences Po Paris",
            description: "Formation pluridisciplinaire intégrant droit, économie et relations internationales.",
            location: "Paris, France",
            price: "175 € /année",
            duration: "3 ans",
            isPublic: true,
            domain: "Sciences Politiques",
            imageName: "Etablissement_France2"
        )
    ]

    private var groupedFormations: [String: [Formation]] {
        Dictionary(grouping: formations, by: { $0.domain })
    }

    var body: some View {
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
                        ForEach(groupedFormations.sorted(by: { $0.key < $1.key }), id: \ .key) { domain, items in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(domain)
                                    .font(.title3.bold())
                                    .foregroundColor(Color(hex: "#2C4364"))
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 20) {
                                        ForEach(Array(items.enumerated()), id: \.1.id) { index, formation in
                                            FormationCardView(
                                                image: Image(formation.imageName),
                                                title: formation.title,
                                                university: formation.university,
                                                description: formation.description,
                                                location: formation.location,
                                                price: formation.price,
                                                duration: formation.duration,
                                                isPublic: formation.isPublic
                                            )
                                            .frame(width: UIScreen.main.bounds.width * 0.75)
                                            .padding(.leading, index == 0 ? 16 : 0) // ➕ Marge à gauche uniquement pour le premier
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
        .navigationBarHidden(true)
    }
}

#Preview {
    FormationsView()
}
