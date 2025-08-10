import SwiftUI

struct VerifyResetCodeView: View {
    @ObservedObject var authVM: AuthViewModel1
    let email: String
    var goToSetPassword: (_ email: String, _ code: String) -> Void

    @State private var codeDigits = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isComplete: Bool {
        codeDigits.allSatisfy { $0.count == 1 }
    }

    private var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(spacing: 16))
        : AnyLayout(HStackLayout(spacing: 12))
    }

    var body: some View {
        ZStack {
            CircleBackgroundView()

            VStack(spacing: 20) {
                Spacer(minLength: 40)

                Image("PLogo 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.bottom, 16)

                Text("Vérifie ton code")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Un code de vérification a été envoyé à ton adresse email.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                // Card
                VStack(spacing: 30) {
                    VStack(spacing: 30) {
                        Text("Code de vérification")
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        codeInputField
                    }

                    AuthButton(
                        title: "Valider",
                        disabled: !isComplete
                    ) {
                        let code = codeDigits.joined()
                        goToSetPassword(email, code)
                    }

                    if let err = authVM.errorMessage {
                        Text(err.message)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
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

    // MARK: - Code Input
    private var codeInputField: some View {
        dynamicLayout {
            ForEach(0..<6, id: \.self) { index in
                TextField("", text: $codeDigits[index])
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)
                    .font(.title2.weight(.semibold))
                    .frame(width: 45, height: 60)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                    )
                    .focused($focusedIndex, equals: index)
                    .onChange(of: codeDigits[index]) { newValue in
                        handleCodeInput(newValue, at: index)
                    }
                    .accessibilityLabel("Chiffre \(index + 1) du code")
            }
        }
    }

    private func handleCodeInput(_ newValue: String, at index: Int) {
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

struct VerifyResetCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyResetCodeView(authVM: AuthViewModel1(), email: "demo@mail.com") { _, _ in }
                .preferredColorScheme(.light)

            VerifyResetCodeView(authVM: AuthViewModel1(), email: "demo@mail.com") { _, _ in }
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
