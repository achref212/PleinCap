//
//  DashboardView.swift
//  PleinCap
//
//  Created by chaabani achref on 12/8/2025.
//

//
//  DashboardView.swift
//  PleinCap
//
//  Created by chaabani achref on 12/8/2025.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dyn
    @EnvironmentObject var authVM: AuthViewModel1

    @State var progress: Double = 0.35
    @State private var goToFormations = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Top progress
                HStack {
                    Text("Mon projet")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "#1F3552"))
                    Spacer()
                    ProgressBarView(progress: $progress)
                        .frame(width: 160, height: 16)
                }
                .padding(.horizontal)

                // GIF hero
                HeroGIFCard(
                    title: "Mon projet",
                    gifName: "tree_loop",     // <- put your GIF in the bundle as tree_loop.gif
                    cornerRadius: 28
                )
                .padding(.horizontal)

                // Step
                StepCard(
                    icon: "star.circle.fill",
                    title: "Découvrir mon champ d’exploration",
                    subtitle: "Affiner mes domaines d’intérêt"
                ) {
                    // Navigate to your domain/specialty screen
                }
                .padding(.horizontal)

                // Recommendations CTA
                PrimaryCTA(
                    title: "Voir mes recommandations",
                    subtitle: "Formations adaptées à mon profil"
                ) {
                    goToFormations = true
                }
                .padding(.horizontal)
                .padding(.top, 4)

                // Info rows
                VStack(spacing: 12) {
                    SmallInfoRow(
                        systemImage: "calendar",
                        title: "Prochaine étape",
                        caption: "Évaluer mes préférences"
                    )
                    SmallInfoRow(
                        systemImage: "checkmark.seal",
                        title: "Profil complété",
                        caption: "\(Int(progress * 100))%"
                    )
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                )
                .padding(.horizontal)

                Spacer(minLength: 12)
            }
            .padding(.vertical, 16)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.systemGroupedBackground)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        )
        // Programmatic nav
        .background(
            NavigationLink(isActive: $goToFormations) {
                FormationsView()
                    .environmentObject(authVM)
            } label: { EmptyView() }
            .hidden()
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hero GIF Card

private struct HeroGIFCard: View {
    let title: String
    let gifName: String
    let cornerRadius: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(hex: "#EFFFFF")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.07), radius: 10, y: 6)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#2C4364"))

                GIFPlayerView(name: gifName, cornerRadius: 16)
                    .frame(height: 220)
                    .accessibilityHidden(true)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
    }
}

// MARK: - Components (unchanged)

private struct StepCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color(hex: "#EFFFFF"))
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "#6E56CF"))
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#2C4364"))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.white, Color.white.opacity(0.96)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct PrimaryCTA: View {
    let title: String
    let subtitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                LinearGradient(colors: [Color(hex: "#17C1C1"), Color(hex: "#6E56CF")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SmallInfoRow: View {
    let systemImage: String
    let title: String
    let caption: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(Color(hex: "#17C1C1"))
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundColor(Color(hex: "#2C4364")).font(.subheadline.bold())
                Text(caption).foregroundColor(.secondary).font(.footnote)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            DashboardView(progress: 0.7)
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.dark)
    }
}
