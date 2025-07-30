import SwiftUICore
import SwiftUI
struct RadioBoxView: View {
    var isSelected: Bool
    var label: String
    var subLabel: String? = nil
    var trailingIcon: String? = nil
    var onTap: () -> Void
    var onEdit: (() -> Void)? = nil  // facultatif

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: "#17C1C1") : Color.white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }

                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 4, height: 30)
                    .cornerRadius(2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let subLabel {
                        Text(subLabel)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if let icon = trailingIcon {
                    Button {
                        onEdit?()
                    } label: {
                        Image(systemName: icon)
                            .foregroundColor(Color(hex: "#17C1C1"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#17C1C1").opacity(0.2), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
