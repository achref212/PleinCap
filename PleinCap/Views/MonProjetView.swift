import SwiftUI

// MARK: - Mon Projet

struct MonProjetView: View {
    @EnvironmentObject var authVM: AuthViewModel1

    // Plan VM lives here (so it stays alive while navigating)
    @StateObject private var planVM: PlanActionViewModel

    // Global progress bar (we reuse it across your onboarding)
    @State private var progress: Double = 0.35

    // Navigation target
    @State private var destination: Destination? = nil

    // Simple error presentation (no Identifiable needed)
    @State private var showError = false
    @State private var lastErrorText: String = ""

    init(authVM: AuthViewModel1) {
        _planVM = StateObject(wrappedValue: PlanActionViewModel(auth: authVM))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Header
                HStack(alignment: .center) {
                    Text("Mon projet")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color(hex: "#1F3552"))
                    Spacer()
                    Chip(text: "Synthèse en temps réel", tint: Color(hex: "#F7931E").opacity(0.18), fg: Color(hex: "#F7931E"))
                }
                .padding(.horizontal)

                // Precision card
                PrecisionCard(precision: computedPrecision,
                              onImprove: { goToNextPendingStep() },
                              onHowItWorks: { destination = .explainer })
                .padding(.horizontal)

                // Mes infos de base
                BasicInfoCard(authVM: authVM)
                    .padding(.horizontal)

                // Trophées (uses plan completion + basics)
                TrophiesSectionView(planVM: planVM)
                    .environmentObject(authVM)

                // Steps list
                StepsSectionView(planVM: planVM) { step in
                    navigate(to: step)
                }
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(colors: [Color(.systemGroupedBackground), Color(.systemGroupedBackground)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        // Navigation
        .navigationDestination(item: $destination) { dest in
            switch dest {
            case .preferences:
                PreferenceQuestionsView(progress: $progress)
                    .environmentObject(authVM)
            case .orientation:
                OrientationChoicesView()
                    .environmentObject(authVM)
            case .formations:
                FormationsView()
                    .environmentObject(authVM)
            case .riasec:
                RiasecTestView()
                    .environmentObject(authVM)
            case .explainer:
                HowItWorksSheet()
            }
        }
        // Data loading
        .task {
            planVM.refresh()
        }
        // Error wire-up (avoid .alert(item:))
        .onChange(of: planVM.errorMessage) { msg in
            if let m = msg, !m.isEmpty {
                lastErrorText = m
                showError = true
                planVM.errorMessage = nil
            }
        }
        .alert("Erreur", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(lastErrorText)
        })
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private var computedPrecision: Double {
        // Base 30% like your mock, then grow with plan completion and basics
        let basics = basicsScore // 0...1
        let mix = (planVM.completionRatio * 0.6) + (basics * 0.4)
        return min(0.30 + mix * 0.70, 1.0)
    }

    private var basicsScore: Double {
        var score = 0
        if let s = authVM.specialites, !s.isEmpty { score += 1 }
        if let b = authVM.budget, !b.isEmpty { score += 1 }
        if let ac = authVM.userProfile?.academie, !ac.isEmpty { score += 1 }
        if let loc = authVM.userProfile?.adresse, !loc.isEmpty { score += 1 }
        if let etab = authVM.userProfile?.etablissement, !etab.isEmpty { score += 1 }
        return Double(score) / 5.0
    }

    private func goToNextPendingStep() {
        if let first = planVM.pendingSteps.first {
            navigate(to: first)
        } else {
            // fallback: encourage exploration
            destination = .formations
        }
    }

    private func navigate(to step: PlanStepResponse) {
        let t = step.titre.lowercased()
        if t.contains("préférences") {
            destination = .preferences
        } else if t.contains("exploration") || t.contains("formations") {
            destination = .formations
        } else if t.contains("intérêts") || t.contains("riasec") {
            destination = .riasec
        } else if t.contains("champ d’exploration") || t.contains("orientation") {
            destination = .orientation
        } else {
            // Unknown → formations as friendly default
            destination = .formations
        }
    }

    // MARK: - Routing model

    private enum Destination: Hashable, Identifiable {
        case preferences, orientation, formations, riasec, explainer
        var id: String { String(describing: self) }
    }
}

// MARK: - Precision Card

private struct PrecisionCard: View {
    let precision: Double
    var onImprove: () -> Void
    var onHowItWorks: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Précision des recommandations")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                Text("\(Int(precision * 100))%")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: precision)
                .tint(Color(hex: "#17C1C1"))
                .progressViewStyle(.linear)
                .frame(height: 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))

            HStack(spacing: 10) {
                Button(action: onImprove) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Augmenter la précision")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#17C1C1"))
                    )
                }
                Button(action: onHowItWorks) {
                    Text("Comment ça marche ?")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#1F3552"))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 10, y: 6)
        )
    }
}

// MARK: - Mes infos de base (polished grid)

private struct BasicInfoCard: View {
    @ObservedObject var authVM: AuthViewModel1

    private var basicsComplete: Bool {
        var score = 0
        if let s = authVM.specialites, !s.isEmpty { score += 1 }
        if let b = authVM.budget, !b.isEmpty { score += 1 }
        if let ac = authVM.userProfile?.academie, !ac.isEmpty { score += 1 }
        if let loc = authVM.userProfile?.adresse, !loc.isEmpty { score += 1 }
        if let etab = authVM.userProfile?.etablissement, !etab.isEmpty { score += 1 }
        return score >= 3
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Label("Mes infos de base", systemImage: "person.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                if basicsComplete {
                    Chip(text: "Complet", tint: Color(hex: "#DCF5FF"), fg: Color(hex: "#1F74B7"))
                }
            }

            Text("Ces informations nous aident à poser les bases de ton projet.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Grid tiles
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    InfoTile(title: "Classe", value: authVM.userProfile?.niveauScolaire ?? "—")
                    InfoTile(title: "Voie", value: authVM.userProfile?.voie ?? authVM.filiere ?? "—")
                }
                HStack(spacing: 12) {
                    InfoTile(
                        title: "Spécialités",
                        value: specsDisplay(from: authVM.specialites)
                    )
                    InfoTile(title: "Académie", value: authVM.userProfile?.academie ?? "—")
                }
                HStack(spacing: 12) {
                    InfoTile(title: "Localisation", value: authVM.userProfile?.adresse ?? "—")
                    InfoTile(title: "Budget annuel", value: budgetText(authVM.budget))
                }
            }

            // Pills row
            HStack(spacing: 12) {
                PillButton(title: "Bulletins importés", systemName: "tray.and.arrow.down.fill") { }
                PillButton(title: "Notes saisies", systemName: "square.and.pencil") { }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        )
    }

    private func budgetText(_ s: String?) -> String {
        guard let s, !s.isEmpty else { return "—" }
        return "\(s) €"
    }
}

// MARK: - Steps Section

private struct StepsSectionView: View {
    @ObservedObject var planVM: PlanActionViewModel
    var onTap: (PlanStepResponse) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Plan d’action")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                Chip(text: planVM.completionPercentText,
                     tint: Color(hex: "#EFFFFF"),
                     fg: Color(hex: "#17C1C1"))
            }

            if planVM.stepsSorted.isEmpty {
                EmptyStateView(text: planVM.isLoadingPlan ? "Chargement…" : "Aucune étape disponible.")
            } else {
                VStack(spacing: 10) {
                    ForEach(planVM.stepsSorted) { step in
                        StepRow(step: step,
                                done: planVM.progressByStepId[step.id]?.is_done ?? false,
                                overdue: isOverdue(step),
                                onTap: { onTap(step) },
                                onToggle: { planVM.toggleStep(step) })
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        )
    }

    private func isOverdue(_ step: PlanStepResponse) -> Bool {
        guard !(planVM.progressByStepId[step.id]?.is_done ?? false),
              let end = DateParsers.parseTimestamp(step.end_date ?? "") else { return false }
        return end < Date()
    }
}

private struct StepRow: View {
    let step: PlanStepResponse
    let done: Bool
    let overdue: Bool
    var onTap: () -> Void
    var onToggle: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(done ? Color(hex: "#17C1C1") : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(step.titre)
                        .foregroundColor(Color(hex: "#1F3552"))
                        .font(.headline)
                        .lineLimit(2)
                    if let desc = step.description, !desc.isEmpty {
                        Text(desc).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                    }
                    if overdue {
                        Text("En retard")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Capsule().fill(Color.red))
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Small Components

private struct InfoTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(Color(hex: "#1F3552"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#F7FAFF"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

private struct PillButton: View {
    let title: String
    let systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(Color(hex: "#2C4364"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .overlay(
                        Capsule().stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}

private struct Chip: View {
    let text: String
    let tint: Color
    let fg: Color
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(tint))
    }
}

private struct EmptyStateView: View {
    let text: String
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
            Text(text)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct HowItWorksSheet: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Comment ça marche ?").font(.title2.bold())
                Text("Plus tu complètes ton profil et avances dans les étapes de ton plan d’action, plus nos recommandations s’affinent. Réponds aux questions de préférences, précise tes spécialités, ton budget, et explore des formations : tout cela améliore la précision.")
                Text("Tu peux revenir à tout moment et compléter d’autres sections.")
            }
            .padding()
        }
        .navigationTitle("Comment ça marche ?")
    }
}

// MARK: - Utilities

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        switch self {
        case .some(let s) where s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty: return nil
        default: return self
        }
    }
}

private func specsDisplay(from list: [String]?) -> String {
    let arr: [String] = list ?? []
    let top3: [String] = Array(arr.prefix(3))
    let text = top3
        .map { $0.replacingOccurrences(of: "_", with: " ").capitalized }
        .joined(separator: ", ")
    return text.isEmpty ? "—" : text
}
// MARK: - Preview

struct MonProjetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Wrapper()
                .previewDisplayName("Mon projet — Light")
            Wrapper()
                .preferredColorScheme(.dark)
                .previewDisplayName("Mon projet — Dark")
        }
    }

    // MARK: - Wrapper with seeded data
    private struct Wrapper: View {
        @StateObject private var authVM = AuthViewModel1()
        @StateObject private var planVM: PlanActionViewModel

        init() {
            // Seed Auth first (so plan VM can reference it)
            let a = AuthViewModel1()
            _authVM = StateObject(wrappedValue: a)

            // Build a seeded Plan VM
            let p = PlanActionViewModel(auth: a)
            p.plan = PlanActionResponse(
                id: 4,
                nom: "Mon projet",
                start_date: "2025-08-11",
                end_date: nil,
                is_active: true,
                steps: [
                    PlanStepResponse(id: 19, plan_action_id: 4, titre: "mes infos de base",
                                     description: "Complète tes infos personnelles de base.",
                                     ordre: 1, start_date: "2025-08-11", end_date: nil),
                    PlanStepResponse(id: 20, plan_action_id: 4, titre: "définir mes préférences",
                                     description: "Choisis tes domaines et types de formation préférés.",
                                     ordre: 2, start_date: "2025-08-18", end_date: nil),
                    PlanStepResponse(id: 21, plan_action_id: 4, titre: "commencer l’exploration de formations",
                                     description: "Parcours des formations pertinentes.",
                                     ordre: 3, start_date: "2025-08-25", end_date: nil),
                    PlanStepResponse(id: 22, plan_action_id: 4, titre: "identifier mes intérêts professionnels",
                                     description: "Fais des tests et clarifie tes intérêts.",
                                     ordre: 4, start_date: "2025-09-01", end_date: nil),
                    PlanStepResponse(id: 23, plan_action_id: 4, titre: "explorer mes formations (2/2)",
                                     description: "Approfondis les formations déjà repérées.",
                                     ordre: 5, start_date: "2025-09-08", end_date: nil),
                    PlanStepResponse(id: 24, plan_action_id: 4, titre: "commencer ma liste de formations favorites",
                                     description: "Ajoute tes options favorites à suivre.",
                                     ordre: 6, start_date: "2025-09-15", end_date: nil)
                ]
            )
            // Mark step 1 done in preview
            p.progressByStepId = [
                19: UserStepProgressResponse(id: 1, user_id: 1, step_id: 19, is_done: true, done_at: "2025-08-11T12:00:00Z")
            ]
            _planVM = StateObject(wrappedValue: p)
        }

        var body: some View {
            NavigationStack {
                MonProjetView(authVM: authVM)
                    .environmentObject(authVM)
                    .onAppear(perform: seedAuth)
            }
        }

        // MARK: - Seed base user info for tiles
        private func seedAuth() {
            // If your AuthViewModel1 exposes these, this populates the “Mes infos de base” card
            authVM.specialites = ["maths", "physique_chimie"]
            authVM.budget      = "1500"

            // If userProfile is a struct with these fields, populate them;
            // if not, remove what doesn’t exist in your model.
          
        }
    }
}
