//
//  SwipeRecommendationsView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.

import SwiftUI

struct SwipeRecommendationsView: View {
    @StateObject private var viewModel = FormationViewModel()
    @State private var currentIndex: Int = 0
    @State private var randomImages: [String] = [
        "image1", "image2", "image3", "image4", "image5",
        "image6", "image7", "image8", "image9", "image10"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation {
                        if currentIndex > 0 {
                            currentIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 4) {
                Text("Recommandations pour Vous")
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "#00B0B1"))
                Text("Basées sur ton profil et tes centres d'intérêt")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)

            ZStack {
                ForEach(viewModel.formations.indices.reversed(), id: \.self) { index in
                    if index >= currentIndex && index < viewModel.formations.count {
                        let formation = viewModel.formations[index]
                        let randomImageIndex = index % randomImages.count
                        FormationSwipeCardView(
                            formation: formation,
                            imageName: randomImages[randomImageIndex],
                            onRemove: { direction in
                                withAnimation {
                                    currentIndex += 1
                                    // Optional: Handle like/dislike logic (e.g., save preference)
                                    if direction == .like {
                                        print("Liked formation: \(formation.titre)")
                                    } else {
                                        print("Disliked formation: \(formation.titre)")
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 8)
            .background(
                CircleBackgroundBottomView()
                    .frame(maxHeight: .infinity, alignment: .bottom)
            )
        }
        .padding(.top)
        .onAppear {
            viewModel.fetchFormations()
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct FormationSwipeCardView: View {
    let formation: Formation
    let imageName: String
    let onRemove: (_ direction: SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @State private var like: Bool? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottom) {
                        Image(imageName) // Use the passed imageName
                            .resizable()
                            .scaledToFill()
                            .frame(width: 360, height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(20)

                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 90)
                        .cornerRadius(20)
                    }

                    Text(formation.formationControleeParEtat ?? false ? "Public" : "Privé")
                        .font(.subheadline.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.cyan.opacity(0.7))
                        .clipShape(Capsule())
                        .padding()
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        InfoTag(text: formation.lieu?.ville ?? "Unknown location")
                        InfoTag(text: formation.prixAnnuel.map { String(format: "%.2f €", $0) } ?? "N/A")
                        InfoTag(text: formation.duree ?? "N/A")
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 4, height: 24)
                                .cornerRadius(2)

                            Text(formation.titre)
                                .font(.title3.bold())
                                .foregroundColor(Color(hex: "#1D2B4F"))
                        }

                        Text(formation.etablissement)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(formation.resumeProgramme ?? "No description available")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 4)
            )
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.translation
                        self.like = gesture.translation.width > 0 ? true : false
                    }
                    .onEnded { gesture in
                        if abs(gesture.translation.width) > 120 {
                            onRemove(like == true ? .like : .dislike)
                        } else {
                            self.offset = .zero
                            self.like = nil
                        }
                    }
            )

            if let like = like {
                HStack {
                    if like {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                            .padding()
                        Spacer()
                    } else {
                        Spacer()
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical)
    }
}

enum SwipeDirection {
    case like, dislike
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

#Preview {
    SwipeRecommendationsView()
        .environmentObject(FormationViewModel())
}
