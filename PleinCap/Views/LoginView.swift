import SwiftUI

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    var goToRegister: () -> Void
    var goToForgot: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
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
                    VStack(spacing: 23) {
                        Group {
                            LabeledField(
                                sfIcon: "envelope",
                                label: "Entrez votre adresse Email",
                                prompt: "exemple@email.com",
                                text: $authVM.email,
                                secure: false,
                            )

                            LabeledField(
                                sfIcon: "lock",
                                label: "Entrez votre mot de passe",
                                prompt: "Password",
                                text: $authVM.password,
                                secure: true,
                                error: authVM.passwordError
                            )

                            HStack {
                                Spacer()
                                Button("Mot de passe oublié ?", action: goToForgot)
                                    .font(.footnote)
                                    .foregroundColor(.accentColor)
                            }

                            AuthButton(
                                title: "Login",
                                disabled: authVM.email.isEmpty || authVM.password.isEmpty
                            ) {
                                authVM.login()
                            }
                        }

                        VStack(spacing: 14) {
                            Text("Connecter avec")
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            HStack(spacing: 24) {
                                SocialCircle(imageName: "appleLogo") { print("Apple") }
                                SocialCircle(imageName: "googleLogo") {
                                    handleGoogleLogin()
                                }
                            }
                        }

                        HStack(spacing: 6) {
                            Text("Pas encore de compte ?")
                                .font(.footnote)
                                .foregroundColor(.primary)

                            Button("Rejoignez-nous", action: goToRegister)
                                .font(.footnote.bold())
                                .foregroundColor(Color(hex: "#17C1C1"))
                        }
                    }
                }
            }

            // ✅ Status overlay avec blur
            if let status = authVM.loginStatus {
                ZStack {
                    VisualEffectBlur()
                        .ignoresSafeArea()

                    StatusDialogView(
                        title: status == .success ? "Connexion réussie" : "Erreur",
                        message: status == .success ? "Bienvenue sur PleinCap !" : (authVM.errorMessage ?? "Une erreur est survenue."),
                        type: status
                    )
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(10)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: authVM.loginStatus)
    }
}
extension LoginView {
    func handleGoogleLogin() {
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
                print("❌ RootViewController introuvable")
                return
            }

        authVM.signInWithGoogle(presenting: presentingVC) { success in
            if success {
                print("✅ Connexion Google réussie")

                // ⚠️ Pas besoin de dismiss ici si LoginView est une vue dans un NavigationStack (pas une sheet)
                // L'état authVM.isAuthenticated = true déclenche la redirection dans HomeView

            } else {
                print("❌ Erreur Google : \(authVM.errorMessage ?? "Inconnue")")
            }
        }
    }
}
#Preview {
    LoginView(authVM: AuthViewModel(), goToRegister: {}, goToForgot: {})
}
