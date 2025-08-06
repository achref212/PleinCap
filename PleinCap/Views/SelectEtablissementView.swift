import SwiftUI



swiftimport SwiftUI

struct Etablissement: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let academie: String
    let gpsCoordinates: String
}

struct LocationData {
    let etablissement: String
    let adresse: String
    let latitude: Double
    let longitude: Double
    let academie: String
}

struct SelectEtablissementView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Binding var progress: Double

    @State private var searchText: String = ""
    @State private var selectedEtablissement: Etablissement? = nil
    @State private var goToNext = false
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text("Établissement")
                .font(.title.bold())
                .foregroundColor(Color(hex: "#1F3552"))
                .frame(maxWidth: .infinity, alignment: .center)

            // 🔹 Carte de recherche
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 8) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 3, height: 20)
                        .cornerRadius(1.5)

                    Text("Sélectionne ton établissement")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1F3552"))

                    Spacer()
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Adresse", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color(hex: "#EFFFFF"))
                .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)

            // 🔸 Liste scrollable
            if isLoading {
                ProgressView("Chargement des établissements...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text("Erreur : \(errorMessage)")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.etablissements.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) }) { etab in
                            EtablissementRow(etablissement: etab, isSelected: selectedEtablissement == etab)
                                .onTapGesture {
                                    selectedEtablissement = etab
                                }
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }

            Spacer()

            // 🔄 Navigation vers SelectAcademieView
            NavigationLink(destination: SelectAcademieView(progress: $progress), isActive: $goToNext) {
                EmptyView()
            }

            PrimaryGradientButton(title: "Appliquer", enabled: selectedEtablissement != nil) {
                if let etab = selectedEtablissement {
                    let coordinates = etab.gpsCoordinates.split(separator: ",")
                    let latitude = Double(coordinates[0].trimmingCharacters(in: .whitespaces)) ?? 0.0
                    let longitude = Double(coordinates[1].trimmingCharacters(in: .whitespaces)) ?? 0.0
                    let location = LocationData(
                        etablissement: etab.name,
                        adresse: etab.description, // Using description as a proxy for address
                        latitude: latitude,
                        longitude: longitude,
                        academie: etab.academie
                    )
                    viewModel.updateLocation(location) {
                        DispatchQueue.main.async {
                            progress += 0.1
                            goToNext = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEtablissements()
        }
    }

    private func loadEtablissements() async {
        isLoading = true
        errorMessage = nil
        do {
            try await viewModel.fetchFormations()
            isLoading = false
        } catch {
            errorMessage = "Erreur lors du chargement : \(error.localizedDescription)"
            isLoading = false
        }
    }
}

struct EtablissementRow: View {
    let etablissement: Etablissement
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color(hex: "#2EC1C1"))
                .frame(width: 3)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text(etablissement.name)
                    .foregroundColor(Color(hex: "#1F3552"))
                    .font(.headline)

                Text(etablissement.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isSelected ? Color(hex: "#E0FBFB") : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#2EC1C1"), lineWidth: 1)
                )
        )
    }
}

struct SelectEtablissementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectEtablissementView(progress: .constant(0.4))
                .environmentObject(AuthViewModel())
        }
    }
}
