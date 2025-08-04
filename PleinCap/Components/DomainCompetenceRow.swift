//
//  DomainCompetenceRow.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

struct DomainCompetenceRow: View {
    let domain: String
    let leftQuestion: String
    let rightQuestion: String
    let isLeftSelected: Bool
    let isRightSelected: Bool
    let onLeftTap: () -> Void
    let onRightTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(leftQuestion)
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(rightQuestion)
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)

            ForEach(0..<1) { _ in
                HStack {
                    Button(action: onLeftTap) {
                        Circle()
                            .fill(isLeftSelected ? Color.blue : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.cyan, lineWidth: 2)
                            )
                    }

                    Text(domain)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)

                    Button(action: onRightTap) {
                        Circle()
                            .fill(isRightSelected ? Color.blue : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.cyan, lineWidth: 2)
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                )
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preview
struct DomainCompetenceRow_Previews: PreviewProvider {
    static var previews: some View {
        DomainCompetenceRow(
            domain: "commerce",
            leftQuestion: "Je me sens le moins compétent",
            rightQuestion: "Je me sens le plus capable",
            isLeftSelected: false,
            isRightSelected: true,
            onLeftTap: {},
            onRightTap: {}
        )
        .previewLayout(.sizeThatFits)
    }
}

