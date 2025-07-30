//
//  AccordionSectionView.swift
//  PFE_APP
//
//  Created by chaabani achref on 29/7/2025.
//
import SwiftUI

struct AccordionCheckboxSectionView: View {
    let title: String
    let options: [String]
    let maxSelection: Int

    @Binding var selectedItems: Set<String>
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Titre cliquable
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color(hex: "#2EC1C1"))

                    Text(title)
                        .foregroundColor(Color(hex: "#1F3552"))
                        .font(.system(size: 17, weight: .semibold))

                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // Contenu déroulé avec cases à cocher
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        HStack(spacing: 12) {
                            Image(systemName: selectedItems.contains(option) ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(hex: "#2EC1C1"))
                                .onTapGesture {
                                    toggleSelection(option)
                                }

                            Text(option)
                                .foregroundColor(.primary)
                                .onTapGesture {
                                    toggleSelection(option)
                                }

                            Spacer()
                        }
                    }
                }
                .padding(.leading, 28)
                .transition(.opacity)
            }

            Divider()
        }
        .padding(.horizontal, 8)
    }

    private func toggleSelection(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else if selectedItems.count < maxSelection {
            selectedItems.insert(item)
        }
    }
}
struct ExampleAccordionCheckbox_Preview: View {
    @State private var selected: Set<String> = []

    var body: some View {
        AccordionCheckboxSectionView(
            title: "Arts (au choix)",
            options: ["Histoire des arts", "Théâtre", "Arts plastiques", "Arts du cirque"],
            maxSelection: 2,
            selectedItems: $selected
        )
    }
}
struct AccordionCheckboxSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            ExampleAccordionCheckbox_Preview()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
