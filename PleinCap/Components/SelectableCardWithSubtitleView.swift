//
//  SelectableCardWithSubtitleView.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//

import SwiftUI

struct SelectableCardWithSubtitleGridView: View {
    let title: String
    let options: [(title: String, subtitle: String)]
    @Binding var selectedOption: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Layout dynamique : liste verticale en accessibilité, grille 2 colonnes sinon
    var dynamicLayout: some View {
        if dynamicTypeSize.isAccessibilitySize {
            return AnyView(
                VStack(spacing: 16) {
                    ForEach(options, id: \.title) { option in
                        cardView(option: option)
                    }
                }
            )
        } else {
            return AnyView(
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(options, id: \.title) { option in
                        cardView(option: option)
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func cardView(option: (title: String, subtitle: String)) -> some View {
        Button(action: {
            selectedOption = option.title
        }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(option.title)
                    .font(.body.bold())
                    .foregroundColor(selectedOption == option.title ? .white : .primary)

                Text(option.subtitle)
                    .font(.subheadline)
                    .foregroundColor(selectedOption == option.title ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                    .background(
                        selectedOption == option.title ? Color.accentColor : Color.clear
                    )
                    .cornerRadius(14)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline.bold())
                .padding(.horizontal)
                .foregroundColor(.primary)

            dynamicLayout
                .padding(.horizontal)
        }
    }
}

struct SelectableCardWithSubtitleGridView_Previews: PreviewProvider {
    @State static var selected: String? = "1 semaine"

    static var previews: some View {
        Group {
            SelectableCardWithSubtitleGridView(
                title: "Durée de la formation",
                options: [
                    (title: "1 semaine", subtitle: "20 min/jour"),
                    (title: "10 jours", subtitle: "15 min/jour"),
                    (title: "2 semaines", subtitle: "10 min/jour"),
                    (title: "1 mois", subtitle: "5 min/jour")
                ],
                selectedOption: $selected
            )
            .preferredColorScheme(.light)

            SelectableCardWithSubtitleGridView(
                title: "Durée de la formation",
                options: [
                    (title: "1 semaine", subtitle: "20 min/jour"),
                    (title: "10 jours", subtitle: "15 min/jour"),
                    (title: "2 semaines", subtitle: "10 min/jour"),
                    (title: "1 mois", subtitle: "5 min/jour")
                ],
                selectedOption: $selected
            )
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility3)
        }
        .previewLayout(.sizeThatFits)
    }
}
