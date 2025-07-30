//
//  BrandColors.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//

import SwiftUI

enum BrandColors {
    static let primary = Color("Primary")   // ajoute « Primary » (bleu) dans Assets
    static let accent  = Color("Accent")    // ajoute « Accent » (vert/turquoise)
    static let danger  = Color.red
    static let fieldBg = Color(.secondarySystemBackground)
}

struct BrandColors_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            Color.clear.frame(width: 60, height: 60).background(BrandColors.primary).cornerRadius(8)
            Color.clear.frame(width: 60, height: 60).background(BrandColors.accent).cornerRadius(8)
            Color.clear.frame(width: 60, height: 60).background(BrandColors.danger).cornerRadius(8)
        }
        .previewLayout(.sizeThatFits)
    }
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
