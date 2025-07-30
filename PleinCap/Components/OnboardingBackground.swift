//
//  OnboardingBackground.swift
//  PFE_APP
//
//  Created by chaabani achref on 10/6/2025.
//

import SwiftUI

struct OnboardingBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#F4F6F8").ignoresSafeArea()

            // Cercle principal top droite
            Circle()
                .fill(Color(hex: "#CEF1FB"))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: -300)
                .opacity(0.9)
            
            // Cercle secondaire plus petit
            Circle()
                .stroke(Color(hex: "#D5E6F7").opacity(0.9), lineWidth: 5)
                .frame(width: 250, height: 250)
                .offset(x: 100, y: -250)
                .opacity(0.5)
        }
    }
}
struct OnboardingBackground_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBackground()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}
