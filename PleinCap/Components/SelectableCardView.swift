//
//  SelectableCardView.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//

import SwiftUI

struct SelectableCardView: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.cyan, lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isSelected {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.top, subtitle == nil ? 6 : 2)

            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 4) {
                Text(title)
                    .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .body.weight(.semibold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(dynamicTypeSize.isAccessibilitySize ? .title3 : .subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cyan, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
    }
}

struct SelectableCardView_Previews: PreviewProvider {
    @State static var selected = "Validation"

    static var previews: some View {
        VStack(spacing: 20) {
            SelectableCardView(
                title: "Je cherche des idées pour après le bac fffffffff",
                
                isSelected: selected == "Idées"
            )
            SelectableCardView(
                title: "Je veux vérifier ou valider mes idées",
               
                isSelected: selected == "Validation"
            )
            SelectableCardView(
                title: "Autre",
               
                isSelected: selected == "Autre"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
