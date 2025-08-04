import SwiftUICore
struct DividerLabel: View {
    var label: String

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)

                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.gray)
                    .fixedSize() // 🔥 empêche tout retour ou coupure
                    .layoutPriority(1)

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
        }
        .frame(height: 20)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
