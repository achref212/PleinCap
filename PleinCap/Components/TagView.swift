//
//  TagView.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.cyan.opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
            )
    }
}
