import SwiftUI

struct AuthContainer: View {
    @Binding var flow: AuthFlowStep
    @ObservedObject var authVM: AuthViewModel1

    var body: some View {
        switch flow {
        case .login:
            LoginView(
                authVM: authVM,
                goToRegister: { flow = .register },
                goToForgot:   { flow = .forgotEmail }
            )

        case .register:
            RegisterView(
                authVM: authVM,
                goToVerify: { email in flow = .verifyCode(email: email) },
                goToLogin:  { flow = .login }
            )

        case .verifyCode(let email):
            VerifyCodeView(authVM: authVM, email: email)

        case .forgotEmail:
            ForgotPasswordEmailView(
                authVM: authVM,
                goToCode: { email in flow = .verifyResetCode(email: email) },
                goToLogin: { flow = .login }
            )

        case .verifyResetCode(let email):
            VerifyResetCodeView(
                authVM: authVM,
                email: email
            ) { email, code in
                flow = .setNewPassword(email: email, code: code)
            }

        case .setNewPassword(let email, let code):
            SetNewPasswordView(
                authVM: authVM,
                email: email,
                code: code
            ) { flow = .login }
        }
    }
}
