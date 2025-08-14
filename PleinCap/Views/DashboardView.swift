import SwiftUI

// MARK: - Dashboard

struct DashboardView: View {
    @Environment(\.dynamicTypeSize) private var dyn
    @EnvironmentObject var authVM: AuthViewModel1

    // overall completion (0...1). You can replace with a binding from your plan VM.
    @State var progress: Double = 0.35

    // Navigation
    @State private var goToFormations = false
    @State private var goToPreferences = false
    @State private var goToMonProjet = false              // ← NEW
    @State private var preferencesProgress: Double = 0.30

    // Hero logic
    @State private var showHeroGif = false
    private let gifKey = "dashboard_seen_gif_v1"
    private let gifDuration: Double = 2.4

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Top: title + progress
                HStack {
                    Text("Mon projet")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "#1F3552"))
                    Spacer()
                    ProgressBarView(progress: $progress)
                        .frame(width: 160, height: 16)
                        .accessibilityLabel("Progression \(Int(progress*100))%")
                }
                .padding(.horizontal)

                // Hero (tappable -> MonProjet)
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    goToMonProjet = true
                } label: {
                    HeroProgressCard(
                        firstName: firstNameFromProfile(),
                        subtitle: "Votre parcours de développement personnel et professionnel commence ici",
                        showGif: showHeroGif,
                        gifName: "tree_loop",
                        imageName: heroImageName(for: progress)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                // Steps
                StepCard(
                    icon: "sparkles",
                    title: "Définir mes préférences",
                    subtitle: "Questions rapides pour personnaliser"
                ) {
                    goToPreferences = true
                }
                .padding(.horizontal)

                // Recommendations CTA
                PrimaryCTA(
                    title: "Voir mes recommandations",
                    subtitle: "Formations adaptées à mon profil"
                ) { goToFormations = true }
                .padding(.horizontal)
                .padding(.top, 4)

                // Little info
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
        .onAppear(perform: configureHero)
        // Programmatic nav
        .background(
            Group {
                NavigationLink(isActive: $goToFormations) {
                    FormationsView()
                        .environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()

                NavigationLink(isActive: $goToPreferences) {
                    PreferenceQuestionsView(progress: $preferencesProgress)
                        .environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()

                // → Mon Projet
                NavigationLink(isActive: $goToMonProjet) {
                    MonProjetView(authVM: authVM)      // adjust initializer to your app
                        .environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func configureHero() {
        let seen = UserDefaults.standard.bool(forKey: gifKey)
        if !seen {
            showHeroGif = true
            // Play once, then persist
            Task {
                try? await Task.sleep(nanoseconds: UInt64(gifDuration * 1_000_000_000))
                UserDefaults.standard.set(true, forKey: gifKey)
                withAnimation(.easeInOut(duration: 0.25)) { showHeroGif = false }
            }
        } else {
            showHeroGif = false
        }
    }

    private func firstNameFromProfile() -> String {
        // adjust to your model field names
        if let name = authVM.userProfile?.prenom, !name.isEmpty { return name }
        if let full = authVM.userProfile?.nom, !full.isEmpty {
            return full.components(separatedBy: " ").first ?? full
        }
        // friendly fallback
        return "toi"
    }

    private func heroImageName(for progress: Double) -> String {
        let pct = Int((progress * 100).rounded())
        switch pct {
        case ..<25:   return "hero_stage_0"
        case 25..<50: return "hero_stage_25"
        case 50..<75: return "hero_stage_50"
        case 75..<100:return "hero_stage_75"
        default:      return "hero_stage_100"
        }
    }
}

// MARK: - Hero card with GIF or Static

private struct HeroProgressCard: View {
    let firstName: String
    let subtitle: String
    let showGif: Bool
    let gifName: String
    let imageName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(colors: [Color(hex:"#18c1c1"), Color(hex:"#11a7a7")],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hi, \(firstName)!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.95))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    if showGif {
                        GIFPlayerView(name: gifName, cornerRadius: 20)
                    } else {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .frame(width: 150, height: 150)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
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
    struct GifFirstRunWrapper: View {
        @StateObject var authVM = AuthViewModel1()
        var body: some View {
            NavigationStack {
                DashboardView(progress: 0.12)
                    .environmentObject(authVM)
            }
            // Force the GIF to appear in preview once
            .onAppear {
                UserDefaults.standard.removeObject(forKey: "dashboard_seen_gif_v1")
            }
        }
    }

    struct StaticStageWrapper: View {
        @StateObject var authVM = AuthViewModel1()
        var body: some View {
            NavigationStack {
                // Static hero image chosen by progress bucket (here ~75%)
                DashboardView(progress: 0.75)
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            GifFirstRunWrapper()
                .previewDisplayName("First run (GIF)")
                .preferredColorScheme(.light)

            StaticStageWrapper()
                .previewDisplayName("Static hero (75%)")
                .preferredColorScheme(.dark)
        }
    }
}
