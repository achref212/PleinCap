//
//  ForgotPasswordView.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//

import SwiftUI

struct ForgotPasswordEmailView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var email = ""
    var goToCode: (_ email: String) -> Void
    var goToLogin: () -> Void

    var body: some View {
        ZStack {
            CircleBackgroundView()

            VStack(spacing: 24) {
                // 🔷 En-tête avec logo et texte
                Image("PLogo 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.top, 40)

                Text("Mot de passe oublié ?")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Renseigne ton e-mail ci-dessous et suis les prochaines étapes.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                Spacer()

                // 🔽 Carte blanche en bas
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Entrez votre adresse Email")
                            .font(.footnote)
                            .foregroundColor(.primary)

                        LabeledField(
                            sfIcon: "envelope",
                            label: "",
                            prompt: "exemple@email.com",
                            text: $email,
                            secure: false,
                            error: nil
                        )
                    }

                    AuthButton(title: "Envoyer le code", disabled: email.trimmingCharacters(in: .whitespaces).isEmpty) {
                        let trimmed = email.trimmingCharacters(in: .whitespaces)
                        authVM.forgotPassword(email: trimmed) { ok in
                            if ok { goToCode(trimmed) }
                        }
                    }

                    if let err = authVM.errorMessage {
                        Text(err)
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


struct ForgotPasswordEmailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForgotPasswordEmailView(authVM: AuthViewModel(), goToCode: { _ in }, goToLogin: {})
                .preferredColorScheme(.light)

            ForgotPasswordEmailView(authVM: AuthViewModel(), goToCode: { _ in }, goToLogin: {})
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility2)
        }
    }
}
