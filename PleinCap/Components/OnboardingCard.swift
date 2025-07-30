//
//  OnboardingCard.swift
//  PFE_APP
//
//  Created by chaabani achref on 10/6/2025.
//
import SwiftUI

struct OnboardingCard: View {
    let title: String
    let message: String
    let total: Int
    let index: Int          // page courante (0-based)

    var body: some View {
        ZStack(alignment: .top) {

            // Card principale
            RoundedRectangle(cornerRadius: 36)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)

            VStack(spacing: 24) {
                // Bulles indicatrices
                HStack(spacing: 8) {
                    ForEach(0..<total, id: \.self) { i in
                        Capsule()
                            .fill(i == index ? Color.accentColor : Color.gray.opacity(0.25))
                            .frame(width: i == index ? 35 : 10, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: index)
                    }
                }
                .padding(.top, 26)

                // Titre & message
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 18)
                }
                .padding(.bottom, 34)
            }
            .padding(.top, 8)
        }
        .frame(height: 280)
        .padding(.horizontal)
    }
}
