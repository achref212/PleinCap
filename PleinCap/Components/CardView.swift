//
//  CardView.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI


struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
                .frame(maxHeight: .infinity, alignment: .topLeading) // 👈 force contenu en haut
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(width: 360) // 👈 fixe la même hauteur pour toutes les cartes
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
