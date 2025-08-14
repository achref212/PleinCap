//
//  TrophiesSectionView.swift
//  PleinCap
//
//  Created by chaabani achref on 14/8/2025.
//

import SwiftUI

// MARK: - Trophies Section

struct TrophiesSectionView: View {
    @ObservedObject var planVM: PlanActionViewModel
    @EnvironmentObject var authVM: AuthViewModel1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                Text("🏆 🥇  Trophées débloqués")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                CounterChip(unlocked: unlockedCount, total: trophies.count)
            }

            // Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(trophies) { trophy in
                        TrophyCard(trophy: trophy)
                    }
                }
                .padding(.horizontal, 4)
            }

            // CTA
            Button {
                // You can deep-link to the next pending step if you want:
                // if let next = planVM.pendingSteps.first { onTapStep(next) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Continue pour débloquer plus de trophées !")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(hex: "#6E56CF"))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(Color(hex: "#6E56CF").opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#F7F7FB"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .padding(.horizontal)
        .redacted(reason: (planVM.plan == nil && planVM.isLoadingPlan) ? .placeholder : [])
        .animation(.easeInOut(duration: 0.2), value: planVM.completedCount)
    }

    // MARK: Derived trophies

    private var trophies: [Trophy] {
        [
            Trophy(
                icon: "checkmark.seal.fill",
                accent: Color(hex: "#22C55E"),
                title: "Infos de base complètes",
                subtitle: "Profil de base renseigné",
                unlocked: basicsComplete
            ),
            Trophy(
                icon: "lock.open.fill",
                accent: Color(hex: "#F59E0B"),
                title: "1ʳᵉ étape franchie !",
                subtitle: "Première étape terminée avec succès",
                unlocked: planVM.completedCount >= 1
            ),
            Trophy(
                icon: "leaf.fill",
                accent: Color(hex: "#10B981"),
                title: "Ton projet prend forme",
                subtitle: "Le parcours d’orientation est lancé",
                unlocked: projectStarted
            ),
            Trophy(
                icon: "star.fill",
                accent: Color(hex: "#6E56CF"),
                title: "Cap sur l’excellence",
                subtitle: "La moitié des étapes complétées",
                unlocked: planVM.completionRatio >= 0.5
            )
        ]
    }

    private var unlockedCount: Int { trophies.filter(\.unlocked).count }

    // MARK: Signals from your app state

    private var basicsComplete: Bool {
        // Be permissive: any 3 of these signals means “complete”.
        var score = 0
        if let s = authVM.specialites, !s.isEmpty { score += 1 }
        if let b = authVM.budget, !b.isEmpty { score += 1 }
        if let u = authVM.userProfile?.academie, !u.isEmpty { score += 1 }
        if let loc = authVM.userProfile?.adresse, !loc.isEmpty { score += 1 }
        if let etab = authVM.userProfile?.etablissement, !etab.isEmpty { score += 1 }
        return score >= 3
    }

    private var projectStarted: Bool {
        (authVM.userProfile?.preferences != nil) ||
        (authVM.userProfile?.orientationChoices != nil) ||
        planVM.completedCount > 0
    }
}

// MARK: - Models & Cards

private struct Trophy: Identifiable {
    let id = UUID()
    let icon: String
    let accent: Color
    let title: String
    let subtitle: String
    let unlocked: Bool
}

private struct TrophyCard: View {
    let trophy: Trophy

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(trophy.accent.opacity(0.12))
                    Image(systemName: trophy.icon)
                        .foregroundStyle(trophy.accent)
                }
                .frame(width: 34, height: 34)

                Text(trophy.title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(trophy.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // Status pill
            HStack(spacing: 6) {
                Image(systemName: trophy.unlocked ? "checkmark.circle.fill" : "lock.fill")
                    .imageScale(.small)
                Text(trophy.unlocked ? "Débloqué" : "À débloquer")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(trophy.unlocked ? Color(hex: "#22C55E") : Color.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill( (trophy.unlocked ? Color(hex: "#22C55E") : Color.secondary).opacity(0.10) )
            )
        }
        .padding(16)
        .frame(width: 260, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
        .overlay(
            // Subtle lock overlay when locked
            Group {
                if !trophy.unlocked {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.secondary)
                        )
                        .opacity(0.08)
                }
            }
        )
    }
}

private struct CounterChip: View {
    let unlocked: Int
    let total: Int
    var body: some View {
        Text("\(unlocked)/\(total)")
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color(hex: "#1F3552"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            )
    }
}
