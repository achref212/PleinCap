//
//  PredictionView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/5/2025.
//

import SwiftUI

struct PredictionView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let allFormations = [
        "Informatique", "Médecine", "Droit", "Économie",
        "Lettres", "Gestion", "Philosophie", "Physique",
        "Chimie", "Maths", "Biologie", "Langues"
    ]

    @State private var selected: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choisissez 3 à 10 formations")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                        ForEach(allFormations, id: \.self) { formation in
                            FormationTag(title: formation, isSelected: selected.contains(formation)) {
                                toggleSelection(for: formation)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if selected.count >= 3 {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Taux estimés :")
                                .font(.headline)

                            ForEach(Array(selected), id: \.self) { f in
                                HStack {
                                    Text(f)
                                    Spacer()
                                    Text("\(Int.random(in: 60...98))%")
                                        .bold()
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Prédictions")
            .background(Color(UIColor.systemBackground))
        }
    }

    private func toggleSelection(for formation: String) {
        if selected.contains(formation) {
            selected.remove(formation)
        } else if selected.count < 10 {
            selected.insert(formation)
        }
    }
}

struct FormationTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .contentShape(Rectangle())
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PredictionView()
                .preferredColorScheme(.light)

            PredictionView()
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
