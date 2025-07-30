import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double  // valeur entre 0 et 1

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var backgroundCapsuleColor: Color {
        Color(UIColor.systemGray5)
    }

    var shadowColor: Color {
        Color.primary.opacity(0.15)
    }

    var progressGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // Layout dynamique : vertical si taille d’accessibilité élevée, horizontal sinon
    var dynamicLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ?
        AnyLayout(VStackLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 12))
    }

    var body: some View {
        dynamicLayout {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(backgroundCapsuleColor)
                        .frame(height: 8)

                    Capsule()
                        .fill(progressGradient)
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)

            Text("\(Int(progress * 100))%")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
                .frame(minWidth: 40, alignment: .trailing)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: shadowColor, radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    @State static var progress = 0.3

    static var previews: some View {
        Group {
            ProgressBarView(progress: $progress)
                .preferredColorScheme(.light)

            ProgressBarView(progress: $progress)
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
        .previewLayout(.sizeThatFits)
    }
}
