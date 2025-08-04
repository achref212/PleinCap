//
//  InfoTagView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//


import SwiftUI

struct InfoTagView: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))

            Text(text)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 15)
        .background(
            Capsule()
                .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                .background(Capsule().fill(Color.orange.opacity(0.08)))
        )
        .foregroundColor(Color(red: 29/255, green: 45/255, blue: 74/255)) // #1D2D4A
    }
}

#Preview {
    HStack(spacing: 12) {
        InfoTagView(icon: "mappin.and.ellipse", text: "Paris, France")
        InfoTagView(icon: "eurosign.circle", text: "175 € /année")
        InfoTagView(icon: "clock", text: "3 ans")
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
