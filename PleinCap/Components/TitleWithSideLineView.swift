//
//  TitleWithSideLineView.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//
import SwiftUI

struct TitleWithSideLineView: View {
    let title: String
    let subtitle: String

    @State private var textHeight: CGFloat = 0

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme

    // Couleurs adaptatives
    var textPrimaryColor: Color {
        colorScheme == .dark ? Color.white : Color(red: 47/255, green: 62/255, blue: 82/255)
    }
    var textSecondaryColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray
    }
    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.05) : Color(white: 1.05)
    }
    var accentLineColor: Color {
        Color.orange
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(accentLineColor)
                .frame(width: 6, height: textHeight)
                .padding(.top, 4)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(textPrimaryColor)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(textSecondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .background(GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    self.textHeight = geo.size.height
                }
                return Color.clear
            })
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(cardBackgroundColor)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct TitleWithSideLineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TitleWithSideLineView(
                title: "Identifier tes intérêts",
                subtitle: "Comment t’es-tu dirigé vers ce type de bac ?"
            )
            .preferredColorScheme(.light)
            .environment(\.dynamicTypeSize, .large)

            TitleWithSideLineView(
                title: "Identifier tes intérêts",
                subtitle: "Comment t’es-tu dirigé vers ce type de bac ?"
            )
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility3)
        }
        .previewLayout(.sizeThatFits)
    }
}
