//
//  AdjectiveCardView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

struct AdjectiveCardView: View {
    let adjective: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(adjective)
                        .font(.headline)
                        .foregroundColor(.primary)

                   
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

// Preview example
struct AdjectiveCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AdjectiveCardView(adjective: "adroit", isSelected: false, onTap: {})
            AdjectiveCardView(adjective: "compréhensif",  isSelected: true, onTap: {})
        }
    }
}
