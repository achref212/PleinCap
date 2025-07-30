//
//  SelectableCardV2View.swift
//  PFE_APP
//
//  Created by chaabani achref on 28/7/2025.
//

import SwiftUI

struct SelectableCardV2View: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    var disabled: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(disabled ? Color.gray : Color.cyan, lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(disabled ? Color.gray : Color.cyan)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.top, subtitle == nil ? 6 : 2)

            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 4) {
                Text(title)
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .body.weight(.semibold))
                    .foregroundColor(disabled ? .gray : .primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(dynamicTypeSize.isAccessibilitySize ? .title3 : .subheadline)
                        .foregroundColor(disabled ? .gray : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(disabled ? Color.gray.opacity(0.4) : Color.cyan, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .opacity(disabled ? 0.5 : 1.0)
        .allowsHitTesting(!disabled) // ❌ bloque les interactions si désactivé
    }
}

struct SelectableCardViewV2_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SelectableCardV2View(
                title: "Option Active",
                subtitle: "Ceci est activé",
                isSelected: true,
                disabled: false
            )
            SelectableCardV2View(
                title: "Option Désactivée",
                subtitle: "Bientôt disponible",
                isSelected: false,
                disabled: true
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
