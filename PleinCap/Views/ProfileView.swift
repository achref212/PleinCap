import SwiftUI

struct ProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    var onLogout: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(spacing: 16))
        : AnyLayout(VStackLayout(spacing: 12))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 🔹 Avatar
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)

                    if let user = authVM.userProfile {
                        // 🔹 Nom complet
                        Text("\(user.prenom) \(user.nom)")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        // 🔹 Champs principaux
                        layout {
                            profileItem("Email", value: user.email)
                            profileItem("Sexe", value: user.sexe)
                        }

                        // 🔹 Champs supplémentaires si disponibles
                        if let niveau = user.niveauScolaire {
                            profileItem("Niveau scolaire", value: niveau)
                        }
                        if let voie = user.voie {
                            profileItem("Voie", value: voie)
                        }
                        if let bac = user.specialites, !bac.isEmpty {
                            profileItem("Spécialités", value: bac.joined(separator: ", "))
                        }
                        if let filiere = user.filiere, !filiere.isEmpty {
                           
                        }
                        if let region = user.location?.adresse {
                            profileItem("Adresse", value: region)
                        }
                        if let academie = user.location?.academie {
                            profileItem("Académie", value: academie)
                        }

                        // 🔹 Paramètres
                        NavigationLink(destination: ThemePickerView()) {
                            Label("Paramètres", systemImage: "gearshape.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)

                        // 🔹 Déconnexion
                        Button(action: {
                            authVM.logout()
                            onLogout()
                        }) {
                            Text("Se déconnecter")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
                    } else {
                        // 🔄 Chargement
                        ProgressView("Chargement…")
                            .padding(.top, 40)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Mon profil")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // 🔸 Élément affichant un champ du profil
    @ViewBuilder
    func profileItem(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

#Preview {
    let vm = AuthViewModel()
    vm.userProfile = .preview
    return ProfileView(authVM: vm, onLogout: {})
}
