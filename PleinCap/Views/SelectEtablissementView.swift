import SwiftUI

struct Etablissement: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
}

struct SelectEtablissementView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var progress: Double

    @State private var searchText: String = ""
    @State private var selectedEtablissement: Etablissement? = nil
    @State private var goToNext = false

    private let etablissements: [Etablissement] = [
        .init(name: "Lycée Jean Monnet", description: "Établissement public à Montpellier"),
        .init(name: "Lycée Blaise Pascal", description: "Établissement privé à Paris"),
        .init(name: "Lycée Louis Le Grand", description: "Établissement prestigieux à Paris")
    ]

    var filteredEtablissements: [Etablissement] {
        if searchText.isEmpty {
            return etablissements
        } else {
            return etablissements.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

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
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(filteredEtablissements) { etab in
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

            Spacer()

            // 🔄 Navigation vers SelectAcademieView
            NavigationLink(destination: SelectAcademieView(progress: $progress), isActive: $goToNext) {
                EmptyView()
            }

            PrimaryGradientButton(title: "Appliquer", enabled: selectedEtablissement != nil) {
                if let etab = selectedEtablissement {
                    authVM.updateLocationField(["etablissement": etab.name]) {
                        progress += 0.1
                        goToNext = true
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
