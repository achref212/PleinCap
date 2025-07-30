//
//  ImageWithCaptionView.swift
//  PFE_APP
//
//  Created by chaabani achref on 30/5/2025.
//
import SwiftUI

struct ImageWithCaptionView: View {
    let imageName: String
    let caption: String

    var body: some View {
        VStack(spacing: 16) {
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

            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 30)
                    .cornerRadius(9)

                Text(caption)
                    .font(.title3.bold())
                    .foregroundColor(.primary) // Couleur adaptative claire/sombre
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
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

struct ImageWithCaptionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImageWithCaptionView(imageName: "Study", caption: "Tu es en :")
                .preferredColorScheme(.light)
                .previewDisplayName("Mode clair")

            ImageWithCaptionView(imageName: "Study", caption: "Tu es en :")
                .preferredColorScheme(.dark)
                .previewDisplayName("Mode sombre")
        }
    }
}
