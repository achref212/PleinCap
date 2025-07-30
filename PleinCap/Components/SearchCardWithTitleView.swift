//
//  SearchCardWithTitleView.swift
//  PFE_APP
//
//  Created by chaabani achref on 29/7/2025.
//
import SwiftUI

struct SearchCardWithTitleView<Content: View>: View {
    let title: String
    var description: String? = nil
    @Binding var searchText: String
    let placeholder: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 🔸 Titre + Description
            HStack(alignment: .center, spacing: 8) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 4, height: description == nil ? 20 : 40) // hauteur adaptée
                    .cornerRadius(2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1F3552"))

                    if let description = description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // 🔍 Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField(placeholder, text: $searchText)
            }
            .padding()
            .background(Color(hex: "#EFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: 40))

            // 🔹 Contenu dynamique
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

struct SearchCardWithTitleView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var query = ""

        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    SearchCardWithTitleView(
                        title: "Sélectionne ton établissement",
                        description: nil,
                        searchText: $query,
                        placeholder: "Adresse"
                    ) {
                        Text("Résultats ici...")
                    }

                    SearchCardWithTitleView(
                        title: "Ton académie",
                        description: "À quelle académie appartiens-tu ?",
                        searchText: $query,
                        placeholder: "Sélectionner ton établissement"
                    ) {
                        Image("carte_france")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .padding()
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.light)

        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
