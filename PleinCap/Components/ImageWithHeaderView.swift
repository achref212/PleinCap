//
//  ImageWithHeaderView.swift
//  PFE_APP
//
//  Created by chaabani achref on 25/6/2025.
//
import SwiftUI

struct ImageWithHeaderView: View {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String?

    @State private var textHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            // Illustration principale
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(height: 190)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                )
                .padding(.horizontal)

            // Bloc ligne orange + texte
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 6, height: textHeight)
                    .cornerRadius(9)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))

                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.gray)

                    if let description {
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .background( // Mesure dynamique de la hauteur du texte
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: TextHeightKey.self, value: geo.size.height)
                    }
                )
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onPreferenceChange(TextHeightKey.self) { newHeight in
            self.textHeight = newHeight
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

private struct TextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
#Preview {
    VStack {
        ImageWithHeaderView(
            imageName: "Study",
            title: "Localisation",
            subtitle: "Quelle est ta localisation préférée ?",
            description: "(vous pouvez choisir plusieurs localisations)"
        )
    }
}
