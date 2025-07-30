//
//  SocialLoginButtonsView.swift
//  PFE_APP
//
//  Created by chaabani achref on 28/7/2025.
//

import SwiftUI

struct SocialLoginButtonsView: View {
    let onGoogleTap: () -> Void
    let onAppleTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Connecter avec")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 32) {
                // 🔵 Apple Button
                Button(action: onAppleTap) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                        .padding()
                        .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                }

                // 🔴 Google Button
                Button(action: onGoogleTap) {
                    Image("google-icon") // assure-toi d’avoir une image "google-icon" dans Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .padding()
                        .background(Circle().stroke(Color(hex: "#17C1C1"), lineWidth: 2))
                }
            }
        }
    }
}
