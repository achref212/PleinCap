import SwiftUI

struct SetNewPasswordView: View {
    @ObservedObject var authVM: AuthViewModel1
    let email: String
    let code: String

    @State private var password = ""
    @State private var confirmPassword = ""

    var goToLogin: () -> Void

    private var isValid: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var body: some View {
        ZStack {
            CircleBackgroundView()

            VStack(spacing: 24) {
                // Header
                Image("PLogo 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.top, 40)

                Text("Définir un nouveau mot de passe")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Saisis un nouveau mot de passe sécurisé pour ton compte.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                Spacer()

                // Card
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mot de passe")
                            .font(.footnote)
                            .foregroundColor(.primary)

                        LabeledField(
                            sfIcon: "lock",
                            label: "",
                            prompt: "Nouveau mot de passe",
                            text: $password,
                            secure: true,
                            error: nil
                        )
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirmer le mot de passe")
                            .font(.footnote)
                            .foregroundColor(.primary)

                        LabeledField(
                            sfIcon: "lock.rotation",
                            label: "",
                            prompt: "Confirmation",
                            text: $confirmPassword,
                            secure: true,
                            error: password != confirmPassword && !confirmPassword.isEmpty ? "Les mots de passe ne correspondent pas." : nil
                        )
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    }

                    AuthButton(
                        title: "Valider",
                        disabled: !isValid
                    ) {
                        authVM.resetPassword(email: email, code: code, newPassword: password) { success in
                            if success {
                                goToLogin()
                            }
                        }
                    }

                    if let err = authVM.errorMessage {
                        Text(err.message)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .ignoresSafeArea(.container, edges: .bottom)
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct SetNewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SetNewPasswordView(authVM: AuthViewModel1(), email: "user@mail.com", code: "123456", goToLogin: {})
                .preferredColorScheme(.light)

            SetNewPasswordView(authVM: AuthViewModel1(), email: "user@mail.com", code: "123456", goToLogin: {})
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
