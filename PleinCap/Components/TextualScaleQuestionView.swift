//
//  TextualScaleQuestionView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

struct TextualScaleQuestionView: View {
    let questionText: String
    let options: [String]
    let onSelect: (Int) -> Void

    @State private var selectedIndex: Int? = nil

    var columns: [GridItem] {
        options.count > 2 ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(questionText)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(options.indices, id: \..self) { index in
                    Button(action: {
                        selectedIndex = index
                        onSelect(index)
                    }) {
                        Text(options[index])
                            .multilineTextAlignment(.center)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedIndex == index ? Color.blue.opacity(0.1) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedIndex == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    TextualScaleQuestionView(
        questionText: "J'ai tendance à être distrait",
        options: ["Maria Montessori (Enseignante et auteur de la pédagogie Montessori)",
                  "Daniel Baal (dirigeant de banque)",
                  "Dominique Chapatte (expert en mécanique automobile - turbo)",
                  "Xavier Niel (Business man dans la French Tech)",
                  "Marie Curie (chercheuse scientifique)",
                  "André Michelin (inventeur du pneu radial)",
                  "Antoine de St Exupery (écrivain, peintre)",
                  "Michel-Edouard Leclerc (Dirigeant, Président des supermarchés Leclerc)",
                  "Banksy (Street artiste mondialement reconnu)",
                  "Christine Lagarde (Banquière – elle incarne la rigueur et l’organisation)",
                  "Michel Cymes (médecin)",
                  "Cédric Villani (Prix Nobel de Mathématique)"]
    ) { selectedIndex in
        print("Selected: \(selectedIndex)")
    }
}
