//
//  SelectableCardGridView.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//
import SwiftUI

struct SelectableCardGridView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.body.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, minHeight: 60)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.accentColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SelectableCardGridList: View {
        let options: [String]
        @Binding var selectedOption: String?
        var onOptionTap: (String) -> Void

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(options, id: \.self) { option in
                    SelectableCardGridView(
                        title: option,
                        isSelected: selectedOption == option,
                        onTap: {
                            onOptionTap(option)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }


struct SelectableCardGridList_Previews: PreviewProvider {
    struct WrapperView: View {
        @State private var selectedOption: String? = "STMG"

        var body: some View {
            SelectableCardGridList(
                options: ["Générale", "STMG", "STI2D", "S2TMD", "ST2S", "Littéraire","jjjjj","kkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhh"],
                selectedOption: $selectedOption
            ) { option in
                selectedOption = option
            }
        }
    }

    static var previews: some View {
        Group {
            WrapperView()
                .preferredColorScheme(.light)

            WrapperView()
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
