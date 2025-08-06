//
//  FormationCardView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

// MARK: - Corner Radius Extension for Specific Corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Main Formation Card
struct FormationCardView: View {
    let image: Image
    let title: String
    let university: String
    let description: String
    let location: String
    let price: Double
    let duration: String
    let isPublic: Bool
    var priceFormatted: String {
        String(format: "%.0f € /année", price)
    }
    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 330,height: 160)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(24, corners: [.topLeft, .topRight])

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .top, spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: 4, height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(university)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
            }
            .overlay(alignment: .topTrailing) {
                if isPublic {
                    Text("Public")
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.cyan.opacity(0.6)))
                        .padding(10)
                }
            }
            .overlay(alignment: .topLeading) {
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .white)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(10)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.top, 4)

                HStack(spacing: 10) {
                    InfoTagView(icon: "mappin.and.ellipse", text: location)
                    InfoTagView(icon: "eurosign.circle",  text: priceFormatted)
                    InfoTagView(icon: "clock", text: duration)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            }
            .padding(.horizontal)
            .padding(.top, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .frame(width: 340, height: 340)
        .padding(.horizontal, 21)
    }
}

// MARK: - Preview
struct FormationCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 20) {
                FormationCardView(
                    image: Image("Etablissement_France1"),
                    title: "Licence en Droit",
                    university: "Université Paris 1 Panthéon-Sorbonne",
                    description: "Formation d'excellence en droit avec une approche pluridisciplinaire.",
                    location: "Paris, France",
                    price: 175,
                    duration: "3 ans",
                    isPublic: true
                )

                FormationCardView(
                    image: Image("Etablissement_France2"),
                    title: "Sciences Humaines et Sociales",
                    university: "Sciences Po Paris",
                    description: "Formation pluridisciplinaire intégrant droit, économie et relations internationales.",
                    location: "Paris, France",
                    price: 175 ,
                    duration: "3 ans",
                    isPublic: true
                )
            }
            .padding()
        }
    }
}
