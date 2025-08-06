import SwiftUI

struct SelectEtablissementView: View {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var viewModelF = FormationViewModel()
    @Binding var progress: Double

    @State private var searchText: String = ""
    @State private var selectedEtablissement: String? = nil
    @State private var goToNext = false
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            searchSection
            contentSection
            Spacer()
            navigationLink
            buttonSection
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEtablissements()
        }
        .alert(item: $viewModelF.errorMessage) { error in
            Alert(title: Text("Erreur"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Sub-sections

    private var headerSection: some View {
        Text("Établissement")
            .font(.title.bold())
            .foregroundColor(Color(hex: "#1F3552"))
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var searchSection: some View {
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
                TextField("Rechercher un établissement", text: $searchText)
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
    }

    @ViewBuilder
    private var contentSection: some View {
        if viewModelF.isLoading || isLoading {
            ProgressView("Chargement des établissements...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModelF.errorMessage?.message {
            Text("Erreur : \(errorMessage)")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                establishmentList
            }
        }
    }

    private var establishmentList: some View {
        VStack(spacing: 16) {
            ForEach(viewModelF.uniqueEtablissements.filter {
                searchText.isEmpty || $0.lowercased().contains(searchText.lowercased())
            }, id: \.self) { etab in
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

    private var navigationLink: some View {
        NavigationLink(destination: SelectAcademieView(progress: $progress), isActive: $goToNext) {
            EmptyView()
        }
    }

    private var buttonSection: some View {
        PrimaryGradientButton(title: "Appliquer", enabled: selectedEtablissement != nil) {
            if let etab = selectedEtablissement {
                // Find the first formation with the selected establishment
                if let formation = viewModelF.formations.first(where: { $0.etablissement == etab }) {
                    let coordinates = formation.lieu?.gpsCoordinates!.split(separator: ",") ?? ["0", "0"]
                    let latitude = Double(coordinates[0].trimmingCharacters(in: .whitespaces)) ?? 0.0
                    let longitude = Double(coordinates[1].trimmingCharacters(in: .whitespaces)) ?? 0.0
                    let location = LocationData(
                        adresse: formation.lieu?.ville ?? etab, latitude: latitude, longitude: longitude, etablissement: etab,
                        academie: formation.lieu?.academy ?? "Unknown"
                    )
                    viewModel.updateLocation(location) {
                        DispatchQueue.main.async {
                            progress += 0.1
                            goToNext = true
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Methods

    private func loadEtablissements() async {
        isLoading = true
        errorMessage = nil
        do {
            try await withCheckedThrowingContinuation { continuation in
                viewModelF.fetchFormations { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            // Error is already set in viewModelF.errorMessage
        }
    }
}

struct EtablissementRow: View {
    let etablissement: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color(hex: "#2EC1C1"))
                .frame(width: 3)
                .cornerRadius(2)

            Text(etablissement)
                .foregroundColor(Color(hex: "#1F3552"))
                .font(.headline)

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
                .environmentObject(FormationViewModel())
        }
    }
}
