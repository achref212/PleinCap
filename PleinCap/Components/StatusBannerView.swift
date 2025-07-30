import SwiftUI

enum StatusType {
    case loading, success, failure

    var icon: String {
        switch self {
        case .success: return "checkmark"
        case .failure: return "xmark"
        default: return ""
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        case .loading: return Color(hex: "#17C1C1")
        }
    }
}

struct StatusDialogView: View {
    let title: String
    let message: String
    let type: StatusType

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var animate = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                statusIcon

                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
            .frame(maxWidth: 360)
            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(Color.white.opacity(0.95)) // ✅ Couleur visible sur blur
                                    .shadow(color: .black.opacity(0.21), radius: 25, y: 9)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color(hex: "#2DC0C0").opacity(0.45), lineWidth: 1)
                            )
            .padding(.horizontal)
            .offset(y: animate ? 0 : 200)
            .opacity(animate ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: animate)
            .dynamicTypeSize(.medium ... .accessibility4)
        }.padding(.bottom,40)
        .onAppear {
            animate = true
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        if type == .loading {
            CircleLoader(color: type.color)
                .frame(width: 48, height: 48)
        } else {
            Circle()
                .fill(type.color.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: type.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(type.color)
                        .scaleEffect(animate ? 1 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animate)
                )
        }
    }
}

struct CircleLoader: View {
    var color: Color
    @State private var rotation: Angle = .degrees(0)

    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.8)
            .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
            }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        // Applique un effet de flou "ultra fin"
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)

        // Teinte bleue personnalisée semi-transparente
        let tintView = UIView()
        tintView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.24) // 💙 teinte douce
        tintView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(tintView)

        NSLayoutConstraint.activate([
            tintView.topAnchor.constraint(equalTo: blurView.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor)
        ])

        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
// ✅ Preview dynamique
struct StatusDialogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusDialogView(
                title: "Chargement...",
                message: "Veuillez patienter pendant que nous traitons votre demande.",
                type: .loading
            )

            StatusDialogView(
                title: "Succès",
                message: "Votre action a été réalisée avec succès !",
                type: .success
            )

            StatusDialogView(
                title: "Erreur",
                message: "Une erreur est survenue. Veuillez réessayer.",
                type: .failure
            )
        }
        .preferredColorScheme(.light)
        .environment(\.dynamicTypeSize, .medium)
    }
}
