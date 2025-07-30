//
//  SelectableCheckboxList.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//

import SwiftUI

struct SelectableCheckboxList: View {
    let options: [String]
    @Binding var selectedOptions: Set<String>

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme

    var borderColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.7) : Color.blue.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    toggleSelection(option)
                }) {
                    HStack {
                        ZStack {
                            Circle()
                                .strokeBorder(borderColor, lineWidth: 1.8)
                                .background(
                                    Circle()
                                        .fill(selectedOptions.contains(option) ? Color.accentColor : Color.clear)
                                )
                                .frame(width: 28, height: 28)

                            if selectedOptions.contains(option) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 8)

                        Text(option)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }

    private func toggleSelection(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

struct SelectableCheckboxList_Previews: PreviewProvider {
    @State static var selected: Set<String> = ["J’ai choisi ma filière"]

    static var previews: some View {
        Group {
            SelectableCheckboxList(
                options: [
                    "J’ai choisi ma filière",
                    "Mes parents et/ou mon professeur m’ont recommandé de choisir cette filière",
                    "Quelqu’un d’autre a décidé pour moi (parents, prof, etc.)",
                    "Autre raison"
                ],
                selectedOptions: $selected
            )
            .preferredColorScheme(.light)

            SelectableCheckboxList(
                options: [
                    "J’ai choisi ma filière",
                    "Mes parents et/ou mon professeur m’ont recommandé de choisir cette filière",
                    "Quelqu’un d’autre a décidé pour moi (parents, prof, etc.)",
                    "Autre raison"
                ],
                selectedOptions: $selected
            )
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility3)
        }
        .previewLayout(.sizeThatFits)
    }
}
