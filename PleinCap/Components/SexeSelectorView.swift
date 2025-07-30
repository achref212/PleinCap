//
//  SexeSelectorView.swift
//  PFE_APP
//
//  Created by chaabani achref on 9/7/2025.
//

import SwiftUI

struct SexeSelectorView: View {
    @Binding var selectedSexe: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let options: [(label: String, tag: String)] = [
        ("Homme", "H"),
        ("Femme", "F"),
        ("Autre", "Autre")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sexe")
                .font(dynamicTypeSize >= .accessibility2 ? .title2.bold() : .headline.bold())
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(options, id: \.tag) { option in
                    HStack(spacing: 12) {
                        Image(systemName: selectedSexe == option.tag ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.accentColor)
                            .font(.title3)

                        Text(option.label)
                            .font(dynamicTypeSize >= .accessibility3 ? .title3 : .body)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedSexe = option.tag
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
