import SwiftUI

struct Academie1: Identifiable, Equatable {
    let id = UUID()
    let nom: String
    let description: String
}

struct SelectAcademieView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var progress: Double

    @State private var selectedAcademie1: Academie1? = nil
    @State private var searchText: String = ""
    @State private var goToNext = false

    let academies: [Academie1] = [
        .init(nom: "Occitanie", description: "Académie de Toulouse et Montpellier"),
        .init(nom: "Île-de-France", description: "Académies de Paris, Créteil et Versailles"),
        .init(nom: "Auvergne-Rhône-Alpes", description: "Académies de Lyon, Clermont-Ferrand, Grenoble"),
        .init(nom: "Provence-Alpes-Côte d’Azur", description: "Académies de Nice, Aix-Marseille"),
        .init(nom: "Nouvelle-Aquitaine", description: "Académies de Bordeaux, Limoges, Poitiers"),
        .init(nom: "Grand Est", description: "Académies de Reims, Nancy-Metz, Strasbourg"),
        .init(nom: "Normandie", description: "Académies de Rouen, Caen"),
        .init(nom: "Bretagne", description: "Académie de Rennes"),
        .init(nom: "Centre-Val de Loire", description: "Académie d'Orléans-Tours"),
        .init(nom: "Pays de la Loire", description: "Académie de Nantes"),
        .init(nom: "Hauts-de-France", description: "Académies de Lille, Amiens"),
        .init(nom: "Corse", description: "Académie de Corse"),
        .init(nom: "Outre-mer", description: "Guadeloupe, Martinique, La Réunion, Guyane, Mayotte")
    ]

    var filteredAcademie1s: [Academie1] {
        if searchText.isEmpty {
            return academies
        } else {
            return academies.filter {
                $0.nom.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // 🔹 Carte : Carte de France + recherche
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4)
                            .cornerRadius(2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ton académie")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#1F3552"))

                            Text("À quelle académie appartiens-tu ?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Rechercher une académie ou ville", text: $searchText)
                    }
                    .padding()
                    .background(Color(hex: "#EFFFFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 40))

                    Image("carte_france")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)

                // 🔸 Carte : Liste scrollable
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4)
                            .cornerRadius(2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Liste des académies")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#1F3552"))

                            Text("Choisis ton académie dans la liste ci-dessous")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredAcademie1s) { academie in
                                Button {
                                    selectedAcademie1 = academie
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(academie.nom)
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "#1F3552"))

                                        Text(academie.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedAcademie1 == academie ? Color(hex: "#E0FBFB") : .white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color(hex: "#2EC1C1"), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .frame(maxHeight: 300)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)

                // 🔁 Navigation vers LocationPreferenceView
                NavigationLink(destination: LocationPreferenceView(initialProgress: progress), isActive: $goToNext) {
                    EmptyView()
                }

                // ✅ Bouton Appliquer
                PrimaryGradientButton(title: "Appliquer", enabled: selectedAcademie1 != nil) {
                    if let acad = selectedAcademie1 {
                        let newLocation = LocationData(academie: acad.nom)
                        authVM.updateLocation(newLocation) {
                            progress += 0.1
                            goToNext = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Localisation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SelectAcademieView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectAcademieView(progress: .constant(0.6))
                .environmentObject(AuthViewModel())
        }
    }
}
