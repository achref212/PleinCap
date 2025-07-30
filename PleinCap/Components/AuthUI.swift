import SwiftUI

// MARK: - Carte commune (scroll local)
import SwiftUI

struct AuthCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            content
                        }
                        .padding(.vertical, 36)
                        .padding(.horizontal, 28)
                    }
                }
                .frame(minHeight: geometry.size.height * 0.65) // s'adapte à la taille dynamique
                .background(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 14, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 46)
                        .stroke(Color(.systemGray5), lineWidth: 0.4)
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .dynamicTypeSize(.medium ... .accessibility5)
    }
}

// MARK: - Bouton animé
struct AuthButton: View {
    let title: String
    var disabled = false
    var action: () -> Void

    @State private var pressed = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let turquoise = Color(hex:"#17C1C1")
    private var gradient: LinearGradient {
        LinearGradient(colors: [turquoise, .blue],
                       startPoint: .leading, endPoint: .trailing)
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                pressed = false
                action()
            }
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .font(dynamicTypeSize >= .accessibility3 ? .body : .headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .scaleEffect(pressed ? 0.96 : 1)
        }
        .background {
            RoundedRectangle(cornerRadius: 40)
                .fill(
                    disabled ?
                        AnyShapeStyle(Color.gray.opacity(0.25)) :
                        AnyShapeStyle(gradient)
                )
        }
        .disabled(disabled)
    }
}

// MARK: - Champ avec icône

struct LabeledField: View {
    let sfIcon: String
    let label: String
    let prompt: String
    @Binding var text: String
    var secure: Bool = false
    var error: String?

    @State private var showPassword = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let turquoise = Color(hex: "#17C1C1")

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.callout.weight(.medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 12) {
                Image(systemName: sfIcon)
                    .foregroundColor(turquoise)
                    .font(.body)

                if secure && !showPassword {
                    SecureField(prompt, text: $text)
                        .textInputAutocapitalization(.never)
                        .font(.body)
                        .dynamicTypeSize(.medium ... .accessibility3)
                } else {
                    TextField(prompt, text: $text)
                        .textInputAutocapitalization(.never)
                        .font(.body)
                        .dynamicTypeSize(.medium ... .accessibility3)
                }

                Spacer(minLength: 4)

                if secure {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showPassword.toggle()
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(Color(hex: "#2C4364"))
                            .transition(.opacity)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        (error != nil ? Color.red : turquoise).opacity(0.55),
                        lineWidth: 1.4
                    )
                    .background(Color(hex: "#F5F7FA")).cornerRadius(40)
            )

            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .dynamicTypeSize(.medium ... .accessibility5)
    }
}

struct SocialCircle: View {
    let imageName: String
    var action: () -> Void

    private let turquoise = Color(hex:"#17C1C1")

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let size: CGFloat = dynamicTypeSize.isAccessibilitySize ? 80 : 68
        let iconSize: CGFloat = dynamicTypeSize.isAccessibilitySize ? 36 : 28

        Button(action: action) {
            Circle()
                .stroke(turquoise, lineWidth: 1.6)
                .frame(width: size, height: size)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                )
        }
        .dynamicTypeSize(.medium ... .accessibility5)
    }
}
