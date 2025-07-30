//
//  FormationsView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/7/2025.
//

import SwiftUI

import SwiftUI

struct FormationsView: View {
    // Exemple de données de formations (à remplacer par ton modèle réel)
    struct Formation: Identifiable {
        let id = UUID()
        let titre: String
        let etablissement: String
        let ville: String
    }

    @State private var formations: [Formation] = [
        Formation(titre: "BUT Informatique", etablissement: "IUT de Paris", ville: "Paris"),
        Formation(titre: "Licence Sciences de la vie", etablissement: "Université de Lyon", ville: "Lyon"),
        Formation(titre: "BTS Commerce International", etablissement: "Lycée Jean Mermoz", ville: "Montpellier")
    ]

    var body: some View {
        ZStack {
            Color(hex: "#F4F6F8").ignoresSafeArea()
            CircleBackgroundBottomView()

            VStack(alignment: .leading, spacing: 16) {
                Text("Formations recommandées")
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "#2C4364"))
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(formations) { formation in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(formation.titre)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#2C4364"))

                                Text(formation.etablissement)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text(formation.ville)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.top)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    FormationsView()
}
