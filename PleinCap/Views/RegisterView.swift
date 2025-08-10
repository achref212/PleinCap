import SwiftUI
import GoogleSignInSwift

struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel1
    var goToVerify: (_ email: String) -> Void
    var goToLogin: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ZStack {
                CircleBackgroundView()

                VStack(spacing: 20) {
                    Spacer()

                    Image("PLogo 2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(.top, 32)
                        .padding(.bottom, 20)

                    AuthCard {
                        VStack(spacing: 24) {
                            // ✅ Connexion rapide
                            quickRegisterSection

                            // ✅ Séparateur
                            HStack(alignment: .center, spacing: 12) {
                                DividerLabel(label: "ou créez un compte avec votre email")
                            }
                            .padding(.vertical, 8)

                            // ✅ Formulaire classique
                            labeledField("Nom", icon: "person", text: $authVM.nom, prompt: "Ex : Dupont")
                            labeledField("Prénom", icon: "person", text: $authVM.prenom, prompt: "Ex : Achref")

                            sexeField
                            birthDateField

                            Divider().padding(.vertical, 4)

                            labeledField("Adresse email", icon: "envelope", text: $authVM.email, prompt: "exemple@email.com", error: authVM.emailError)
                            labeledField("Mot de passe", icon: "lock", text: $authVM.password, prompt: "Mot de passe", isSecure: true, error: authVM.passwordError)
                            labeledField("Confirmer le mot de passe", icon: "lock.rotation", text: $authVM.confirmPassword, prompt: "Confirmation", isSecure: true, error: authVM.confirmPasswordError)

                            AuthButton(
                                title: "Créer un compte",
                                disabled: authVM.email.isEmpty
                                    || authVM.password.isEmpty
                                    || authVM.confirmPassword != authVM.password
                                    || authVM.registerStatus == .loading
                            ) {
                                authVM.startRegister { ok in
                                    if ok { goToVerify(authVM.email) }
                                }
                            }

                            // 🔄 Aller à la connexion
                            HStack(spacing: 6) {
                                Text("Vous avez déjà un compte ?").font(.footnote)
                                Button("Connectez-vous", action: goToLogin)
                                    .font(.footnote.bold())
                                    .foregroundColor(Color(hex: "#17C1C1"))
                            }
                            .padding(.top, 4)
                        }
                    }
                }

                // 💬 Status dialog
                if let status = authVM.registerStatus {
                    ZStack {
                        VisualEffectBlur().ignoresSafeArea()
                        StatusDialogView(
                            title: {
                                switch status {
                                case .loading: return "Création du compte..."
                                case .success: return "Inscription réussie"
                                case .failure: return "Erreur"
                                }
                            }(),
                            message: {
                                switch status {
                                case .loading: return "Veuillez patienter"
                                case .success: return "Bienvenue !"
                                case .failure: return authVM.errorMessage?.message ?? "Une erreur est survenue."
                                }
                            }(),
                            type: status
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(10)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .animation(.easeInOut(duration: 0.3), value: authVM.registerStatus)
            .navigationDestination(isPresented: Binding(
                get: { authVM.isAuthenticated },
                set: { _ in }
            )) {
                SelectObjectiveView()
            }
        }
    }

    // ✅ Bloc Google/Apple Login séparé
    private var quickRegisterSection: some View {
        VStack(spacing: 12) {
            Text("Connexion rapide avec")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 32) {
                Button(action: {}, label: {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                        .padding()
                        .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                }).disabled(true)

                Button(action: handleGoogleRegister, label: {
                    Image("googleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .padding()
                        .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                })
            }
        }
    }

    // ✅ Bloc Sexe séparé
    private var sexeField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sexe").font(.body.weight(.semibold))
            VStack(alignment: .leading, spacing: 10) {
                ForEach(["Homme", "Femme", "Autre"], id: \.self) { label in
                    HStack(spacing: 12) {
                        Image(systemName: authVM.sexe == label.prefix(1) ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.accentColor)
                            .font(dynamicTypeSize >= .accessibility2 ? .title2 : .body)
                        Text(label)
                            .font(dynamicTypeSize >= .accessibility2 ? .title3 : .body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            authVM.sexe = String(label.prefix(1)) // "H", "F", "A"
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // ✅ Bloc Date de Naissance séparé
    private var birthDateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date de naissance").font(.body.weight(.semibold))
            DatePicker(
                "",
                selection: Binding(
                    get: {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        return formatter.date(from: authVM.dateNaissanceString) ?? Date()
                    },
                    set: { newDate in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        authVM.dateNaissanceString = formatter.string(from: newDate)
                    }
                ),
                in: ...Date(),
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // ✅ Champ input classique
    func labeledField(
        _ title: String,
        icon: String,
        text: Binding<String>,
        prompt: String,
        isSecure: Bool = false,
        error: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.body.weight(.semibold))
            LabeledField(
                sfIcon: icon,
                label: "",
                prompt: prompt,
                text: text,
                secure: isSecure,
                error: error
            )
        }
    }
}

// MARK: - Actions
private extension RegisterView {
    func handleGoogleRegister() {
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
                print("❌ RootViewController introuvable")
                return
            }

        authVM.signInWithGoogle(presenting: presentingVC) { _ in }
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisterView(authVM: AuthViewModel1(), goToVerify: { _ in }, goToLogin: {})
                .preferredColorScheme(.light)

            RegisterView(authVM: AuthViewModel1(), goToVerify: { _ in }, goToLogin: {})
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
