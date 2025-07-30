//
//  MoyenneFieldView.swift
//  PFE_APP
//
//  Created by chaabani achref on 10/7/2025.
//

import SwiftUI

struct VerticalLabeledTextField: View {
    var label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
