import SwiftUI
import Charts

// MARK: - Radar Chart View
struct RadarChartView: View {
    let rawScores: [String: Int]
    let normalizedScores: [String: Int]

    let letters = ["R", "I", "A", "S", "E", "C"]
    let poleNames = [
        "R": "Réaliste",
        "I": "Investigateur",
        "A": "Artistique",
        "S": "Social",
        "E": "Entreprenant",
        "C": "Conventionnel"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Rectangle().fill(Color.orange).frame(width: 4)
                Text("Radar RIASEC")
                    .font(.title3.bold())
            }.padding(.horizontal)

            Text("Sources bruts vs étalonnées")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Chart {
                ForEach(letters, id: \.self) { key in
                    if let pole = poleNames[key] {
                        LineMark(
                            x: .value("Pôle", pole),
                            y: .value("Score brut", rawScores[key] ?? 0)
                        )
                        .foregroundStyle(Color.orange)
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Pôle", pole),
                            y: .value("Score étalonné", normalizedScores[key] ?? 0)
                        )
                        .foregroundStyle(Color.cyan)
                        .interpolationMethod(.catmullRom)
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 280)
            .padding(.horizontal)
        }
    }
}

// MARK: - Horizontal Bar Chart View
struct HorizontalBarChartView: View {
    let rawScores: [String: Int]
    let normalizedScores: [String: Int]

    let letters = ["R", "I", "A", "S", "E", "C"]
    let poleNames = [
        "R": "Réaliste",
        "I": "Investigateur",
        "A": "Artistique",
        "S": "Social",
        "E": "Entreprenant",
        "C": "Conventionnel"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Diagramme en barres RIASEC")
                .font(.title3.bold())
                .padding(.horizontal)

            Chart {
                ForEach(letters, id: \.self) { key in
                    if let pole = poleNames[key] {
                        BarMark(
                            x: .value("Brut", rawScores[key] ?? 0),
                            y: .value("Catégorie", pole)
                        )
                        .foregroundStyle(Color.orange)

                        BarMark(
                            x: .value("Étalonné", normalizedScores[key] ?? 0),
                            y: .value("Catégorie", pole)
                        )
                        .foregroundStyle(Color.cyan)
                    }
                }
            }
            .frame(height: 320)
            .padding(.horizontal)
        }
    }
}

// MARK: - RIASEC Profile Summary
struct RiasecProfileSummary: View {
    let scores: [String: Int]

    let poleNames = [
        "R": "Réaliste",
        "I": "Investigateur",
        "A": "Artistique",
        "S": "Social",
        "E": "Entreprenant",
        "C": "Conventionnel"
    ]

    let poleColors: [String: Color] = [
        "R": .orange,
        "I": .green,
        "A": .red,
        "S": .purple,
        "E": .blue,
        "C": .yellow
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Pôles les plus marqués:")
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            let sorted = scores.sorted(by: { $0.value > $1.value })
            let percentages = scores.mapValues { Double($0) / 33.0 * 100 }

            let max = sorted.first?.value ?? 1
            let min = sorted.last?.value ?? 1
            let topLetters = sorted.prefix(3).map { $0.key }
            let bottomLetters = sorted.suffix(2).map { $0.key }

            let values = sorted.map { $0.value }
            let d1 = Double(values[safe: 0] ?? 0)
            let d2 = Double(values[safe: 1] ?? 0)
            let d3 = Double(values[safe: 2] ?? 0)
            let d4 = Double(values[safe: 3] ?? 0)
            let d5 = Double(values[safe: 4] ?? 0)

            let differentiation = Int((d1 - ((d2 + d3) / 2.0)) + (d3 - ((d4 + d5) / 2.0)))
            let convergence = differentiation >= 6 ? "FORTE" : (differentiation >= 3 ? "MOYENNE" : "FAIBLE")

            ForEach(sorted, id: \.key) { (key, value) in
                let percentage = (Double(value) / 33.0) * 100
                HStack(spacing: 12) {
                    Circle()
                        .fill(poleColors[key.uppercased()] ?? .gray)
                        .frame(width: 36, height: 36)
                        .overlay(Text(String(key.prefix(1))).font(.headline).foregroundColor(.white))

                    Text("\(poleNames[key.uppercased()] ?? key):")
                        .fontWeight(.semibold)

                    Spacer()

                    Text(String(format: "%.1f%%", percentage))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("• pôles moins marqués : \(bottomLetters.map { poleNames[$0] ?? $0 }.joined(separator: " et ").uppercased())")
                Text("• valeur de différenciation de profil: \(differentiation)")
                Text("• Valeur de convergence de profil : \(convergence)")
            }
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.horizontal)
        }
    }
}

// Safe array index extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
