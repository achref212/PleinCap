import SwiftUI
import GoogleSignInSwift

struct RegisterView: View {
    @ObservedObject var authVM: AuthViewModel
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
                        .padding(.bottom, 70)

                    AuthCard {
                        VStack(spacing: 22) {
                            // Champs classiques
                            labeledField("Nom", icon: "person", text: $authVM.nom, prompt: "Ex : Dupont")
                            labeledField("Prénom", icon: "person", text: $authVM.prenom, prompt: "Ex : Achref")

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
                                                authVM.sexe = String(label.prefix(1))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Date de naissance").font(.body.weight(.semibold))
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd"
                                            return formatter.date(from: authVM.dateNaissance) ?? Date()
                                        },
                                        set: { newDate in
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyy-MM-dd"
                                            authVM.dateNaissance = formatter.string(from: newDate)
                                        }
                                    ),
                                    in: ...Date(),
                                    displayedComponents: [.date]
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider().padding(.vertical, 4)

                            labeledField("Adresse email", icon: "envelope", text: $authVM.email, prompt: "exemple@email.com", error: authVM.emailError)
                            labeledField("Mot de passe", icon: "lock", text: $authVM.password, prompt: "Mot de passe", isSecure: true, error: authVM.passwordError)
                            labeledField("Confirmer le mot de passe", icon: "lock.rotation", text: $authVM.confirmPassword, prompt: "Confirmation", isSecure: true, error: authVM.confirmPasswordError)

                            // 🔐 Créer un compte
                            AuthButton(
                                title: "Créer un compte",
                                disabled: authVM.email.isEmpty || authVM.password.isEmpty || authVM.confirmPassword != authVM.password
                            ) {
                                authVM.startRegister { ok in
                                    if ok { goToVerify(authVM.email) }
                                }
                            }

                            // 🌐 Section "Connecter avec"
                            VStack(spacing: 12) {
                                Text("Connecter avec")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 32) {
                                    // 🍎 Apple button (désactivé)
                                    Button(action: {}, label: {
                                        Image(systemName: "applelogo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                                    })
                                    .disabled(true)

                                    // 🔵 Google button
                                    Button(action: {
                                        if let topController = UIApplication.shared.windows.first?.rootViewController {
                                            authVM.signInWithGoogle(presenting: topController) { success in
                                                // Redirection automatique via .isAuthenticated dans NavigationStack
                                            }
                                        }
                                    }, label: {
                                        Image("googleLogo") // ajoute dans Assets.xcassets
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)
                                            .padding()
                                            .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                                    })
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
                            title: status == .success ? "Inscription réussie" : "Erreur",
                            message: status == .success ? "Bienvenue !" : (authVM.errorMessage ?? "Une erreur est survenue."),
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

            // ✅ Navigation automatique si Google SSO OK
            .navigationDestination(isPresented: Binding(
                get: { authVM.isAuthenticated },
                set: { _ in }
            )) {
                SelectObjectiveView()
            }
        }
    }

    // MARK: - Helper Field View
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisterView(authVM: AuthViewModel(), goToVerify: { _ in }, goToLogin: {})
                .preferredColorScheme(.light)

            RegisterView(authVM: AuthViewModel(), goToVerify: { _ in }, goToLogin: {})
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
