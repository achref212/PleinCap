//
//  VerifyCodeView.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//

import SwiftUI

struct VerifyCodeView: View {
    @ObservedObject var authVM: AuthViewModel
    let email: String

    @State private var codeDigits = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    private var isComplete: Bool {
        codeDigits.allSatisfy { $0.count == 1 }
    }

    var body: some View {
        ZStack {
            CircleBackgroundView()

            VStack(spacing: 20) {
                // 🔷 Partie haute : logo et texte
                Image("PLogo 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.top, 40)

                Text("Vérifie ton compte")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("On vient de t’envoyer un code de vérification par e-mail.\nVérifie ta boîte de réception ou tes spams.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                Spacer()

                // 🔽 AuthCard en bas qui prend la moitié de l’écran
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Code de vérification")
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                TextField("", text: $codeDigits[index])
                                    .keyboardType(.numberPad)
                                    .textContentType(.oneTimeCode)
                                    .multilineTextAlignment(.center)
                                    .font(.title2.weight(.semibold))
                                    .frame(width: 50, height: 55)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                                    )
                                    .focused($focusedIndex, equals: index)
                                    .onChange(of: codeDigits[index]) { newValue in
                                        if newValue.count > 1 {
                                            codeDigits[index] = String(newValue.prefix(1))
                                        }
                                        if newValue.count == 1 && index < 5 {
                                            focusedIndex = index + 1
                                        } else if newValue.isEmpty && index > 0 {
                                            focusedIndex = index - 1
                                        }
                                    }
                            }
                        }
                    }

                    AuthButton(title: "Vérifier", disabled: !isComplete) {
                        let code = codeDigits.joined()
                        authVM.email = email
                        authVM.verifyCode(code: code) { success in
                            if !success {
                                authVM.errorMessage = "Code invalide ou expiré"
                            }
                        }
                    }

                    if let err = authVM.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
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
        .onAppear { focusedIndex = 0 }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
struct VerifyCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyCodeView(authVM: AuthViewModel(), email: "john@example.com")
                .preferredColorScheme(.light)

            VerifyCodeView(authVM: AuthViewModel(), email: "john@example.com")
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
