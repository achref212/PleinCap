//
//  SwipeRecommendationsView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

struct SwipeRecommendationsView: View {
    @State private var formations: [Formation] = [
        Formation(
            title: "Licence en Droit",
            university: "Université Paris 1 Panthéon-Sorbonne",
            description: "Formation pluridisciplinaire intégrant droit, économie et relations internationales.",
            location: "Paris, France",
            price: "175 € /année",
            duration: "3 ans",
            isPublic: true,
            domain: "Droit",
            imageName: "Etablissement_France1"
        ),
        Formation(
            title: "Licence en Informatique",
            university: "Université de Lyon",
            description: "Approche pratique des systèmes, programmation et architecture logicielle.",
            location: "Lyon, France",
            price: "220 € /année",
            duration: "3 ans",
            isPublic: true,
            domain: "Informatique",
            imageName: "Etablissement_France1"
        ),
        Formation(
            title: "Bachelor en Marketing",
            university: "ESG Business School",
            description: "Métiers du marketing digital et stratégie commerciale.",
            location: "Marseille, France",
            price: "6500 € /an",
            duration: "3 ans",
            isPublic: false,
            domain: "Marketing",
            imageName: "Etablissement_France1"
        ),
        Formation(
            title: "BTS Design Graphique",
            university: "École de Design de Nantes",
            description: "Design visuel, création graphique et outils professionnels.",
            location: "Nantes, France",
            price: "4500 € /an",
            duration: "2 ans",
            isPublic: false,
            domain: "Design",
            imageName: "Etablissement_France1"
        )
    ]

    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            ForEach(formations.indices.reversed(), id: \.self) { index in
                if index >= currentIndex {
                    FormationSwipeCardView(
                        formation: formations[index],
                        onRemove: {
                            withAnimation {
                                currentIndex += 1
                            }
                        }
                    )
                    .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct FormationSwipeCardView: View {
    let formation: Formation
    let onRemove: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(formation.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 520)
                .cornerRadius(24)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    .cornerRadius(24)
                )
                .shadow(radius: 5)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(formation.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(formation.university)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    InfoTag(text: formation.location)
                    InfoTag(text: formation.price)
                    InfoTag(text: formation.duration)
                }
                .padding(.top, 12)
                .padding(.horizontal)
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(formation.isPublic ? "Public" : "Privé")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.cyan.opacity(0.9))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.cyan, lineWidth: 2)
                        )
                        .shadow(radius: 2)
                        .padding()
                }
            }
        }
        .frame(height: 520)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 100 {
                        onRemove()
                    } else {
                        self.offset = .zero
                    }
                }
        )
    }
}

struct InfoTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.orange, lineWidth: 1)
            )
    }
}

// MARK: - Preview

struct SwipeRecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeRecommendationsView()
            .preferredColorScheme(.light)
            .previewDevice("iPhone 14 Pro")
            .previewDisplayName("Recommandations Swipe")
    }
}
