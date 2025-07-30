import SwiftUI

struct LoaderWithSubtitle: View {
    var subtitle: String
    var color: Color = Color(hex: "#17C1C1")
    
    @State private var rotation: Angle = .degrees(0)
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .trim(from: 0.0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 48, height: 48)
                .rotationEffect(rotation)
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = .degrees(360)
                    }
                }

            Text(subtitle)
                .font(.body)
                .foregroundColor(Color(hex: "#2C4364"))
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.medium ... .accessibility4)
        }
        .padding()
    }
}
#Preview {
    LoaderWithSubtitle(subtitle: "Génération d’un plan d’action personnalisé…")
}
