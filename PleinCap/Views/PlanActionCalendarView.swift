//
//  PlanActionCalendarView.swift
//  PleinCap
//
//  Created by chaabani achref on 4/8/2025.
//

import SwiftUI

struct Steps: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let color: Color
}

struct TimelineCalendarView: View {
    let steps: [Steps]

    private var groupedSteps: [(String, [Steps])] {
        let grouped = Dictionary(grouping: steps) { step in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: step.date).capitalized
        }
        return grouped.sorted(by: { $0.key < $1.key })
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 32) {
                ForEach(groupedSteps, id: \.0) { month, stepsInMonth in
                    VStack(alignment: .leading, spacing: 16) {
                        Text(month)
                            .font(.title3.bold())
                            .foregroundColor(.cyan)

                        ForEach(stepsInMonth) { step in
                            TimelineStepView(step: step)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct TimelineStepView: View {
    let step: Steps

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Circle()
                    .fill(step.color)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                Rectangle()
                    .fill(step.color.opacity(0.3))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(step.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(step.color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(step.color, lineWidth: 1)
                        )
                )

                
            }
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: step.date)
    }
}

// MARK: - Preview
struct TimelineCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSteps: [Steps] = [
            Steps(title: "Mieux me connaître", description: "Autoévaluation, forces/faiblesses", date: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 21))!, color: .green),
            Steps(title: "10 pistes pour trouver ma voie", description: "Liste initiale des domaines", date: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 13))!, color: .green),
            Steps(title: "Explorer mes premières formations", description: "Visiter les plateformes d'orientation", date: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 26))!, color: .orange),
            Steps(title: "Commencer ma liste de voeux", description: "Débuter la sélection des formations", date: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 14))!, color: .blue),
            Steps(title: "Inscription Parcoursup", description: "Création du dossier", date: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 16))!, color: .gray)
        ]

        TimelineCalendarView(steps: sampleSteps)
    }
}
