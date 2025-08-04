//
//  RadarChartView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI
import Charts

struct RadarChartView: View {
    let rawScores: [String: Int]
    let normalizedScores: [String: Int]

    let categories = ["Réaliste", "Investigateur", "Artiste", "Social", "Entreprenant", "Conventionnel"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Radar RIASEC")
                .font(.title3.bold())
                .padding(.horizontal)

            Chart {
                ForEach(categories, id: \..self) { key in
                    LineMark(
                        x: .value("Pôle", key),
                        y: .value("Score brut", rawScores[key] ?? 0)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Pôle", key),
                        y: .value("Score étalonné", normalizedScores[key] ?? 0)
                    )
                    .foregroundStyle(.cyan)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 280)
            .padding(.horizontal)
        }
    }
}

// HorizontalBarChartView.swift

struct HorizontalBarChartView: View {
    let rawScores: [String: Int]
    let normalizedScores: [String: Int]

    let categories = ["Réaliste", "Investigateur", "Artiste", "Social", "Entreprenant", "Conventionnel"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Radar RIASEC")
                .font(.title3.bold())
                .padding(.horizontal)

            Chart {
                ForEach(categories, id: \..self) { cat in
                    BarMark(
                        x: .value("Brut", rawScores[cat] ?? 0),
                        y: .value("Catégorie", cat)
                    )
                    .foregroundStyle(Color.orange)

                    BarMark(
                        x: .value("Étalonné", normalizedScores[cat] ?? 0),
                        y: .value("Catégorie", cat)
                    )
                    .foregroundStyle(Color.cyan)
                }
            }
            .frame(height: 320)
            .padding(.horizontal)
        }
    }
}

// RiasecProfileSummary.swift

struct RiasecProfileSummary: View {
    let scores: [String: Int]

    var body: some View {
        VStack(spacing: 16) {
            Text("Profils les plus marqués")
                .font(.title3.bold())

            let sorted = scores.sorted(by: { $0.value > $1.value })
            let max = sorted.first?.value ?? 1

            ForEach(sorted, id: \..key) { (key, value) in
                HStack(spacing: 12) {
                    Circle()
                        .fill(color(for: key))
                        .frame(width: 36, height: 36)
                        .overlay(Text(String(key.prefix(1))).font(.headline).foregroundColor(.white))

                    Text(poleName(for: key))
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(String(format: "%.1f", Double(value) / Double(max) * 100))%")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    func poleName(for letter: String) -> String {
        switch letter.uppercased() {
        case "R": return "Réaliste"
        case "I": return "Investigateur"
        case "A": return "Artistique"
        case "S": return "Social"
        case "E": return "Entreprenant"
        case "C": return "Conventionnel"
        default: return letter
        }
    }

    func color(for letter: String) -> Color {
        switch letter.uppercased() {
        case "R": return .orange
        case "I": return .green
        case "A": return .red
        case "S": return .purple
        case "E": return .blue
        case "C": return .yellow
        default: return .gray
        }
    }
}
