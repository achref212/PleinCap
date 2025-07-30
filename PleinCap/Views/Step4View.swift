//
//  Step4View.swift
//  PFE_APP
//
//  Created by chaabani achref on 23/7/2025.
//

import SwiftUI

struct Step4View: View {
    var onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#F4F6F8").ignoresSafeArea()
            CircleBackgroundBottomView()

            VStack(spacing: 24) {
                TitleWithSideLineView(
                    title: "Du 19 avril :",
                    subtitle: "Commencer à élaborer ta liste de vœux stratégique"
                )
                .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    Text("📌 Objectif :")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#2C4364"))

                    Text("Définir des choix de formations cohérents avec tes objectifs, intérêts et ton profil Parcoursup.")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#2C4364"))

                    Text("✅ Critères à considérer :")
                        .font(.headline)
                        .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Ton profil (bulletins, spécialités, zone géographique)")
                        Text("• Tes préférences (type de formation, débouchés)")
                        Text("• Les critères de sélection de chaque formation")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#2C4364"))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    onComplete()
                    dismiss()
                }) {
                    Text("Suivant")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#17C1C1"))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Step4View{
        print("✅ Étape 4 complétée → retour vers FinalPlanView")
    }
}
