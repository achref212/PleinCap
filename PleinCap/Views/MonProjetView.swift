//
//  PlanDashboardView.swift
//  PleinCap
//
//  Created by chaabani achref on 14/8/2025.
//

import SwiftUI

// MARK: - Helpers



private func sanitizedKey(_ text: String) -> String {
    text
        .folding(options: [.diacriticInsensitive], locale: .init(identifier: "fr_FR"))
        .replacingOccurrences(of: "’", with: "")
        .replacingOccurrences(of: "'", with: "")
        .replacingOccurrences(of: "[^A-Za-z0-9]+", with: "_", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        .lowercased()
}

// Titles → routes
enum StepRoute: String, Identifiable {
    var id: String { rawValue }
    case mes_infos_de_base
    case definir_mes_preferences
    case commencer_l_exploration_de_formations
    case identifier_mes_interets_professionnels
    case explorer_mes_formations_2_2
    case commencer_ma_liste_de_formations_favorites

    static func fromTitle(_ titre: String) -> StepRoute? {
        .init(rawValue: sanitizedKey(titre))
    }
}

// MARK: - Render models from your responses

struct PlanStepItem: Identifiable {
    let id: Int
    let ordre: Int
    let titre: String
    let description: String?
    let startDate: String?
    let endDate: String?
    let route: StepRoute?
    var isDone: Bool
    var isLocked: Bool
}

struct TrophyCard: Identifiable {
    enum Icon { case system(String), emoji(String) }
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: Icon
    let unlocked: Bool
}

// MARK: - ViewModel (feed it with your data)

final class MonProjetVM: ObservableObject {
    @Published var items: [PlanStepItem] = []
    @Published var unlockPreview = false
    @Published var loading = false
    @Published var error: String?

    // Keep raw to recompute lock state
    private var rawSteps: [PlanStepResponse] = []
    private var rawProgress: [UserStepProgressResponse] = []

    func configure(steps: [PlanStepResponse], progress: [UserStepProgressResponse]) {
        rawSteps = steps.sorted(by: { $0.ordre < $1.ordre })
        rawProgress = progress
        rebuild()
    }

    func togglePreview() { unlockPreview.toggle(); rebuild() }

    private func rebuild() {
        let done = Set(rawProgress.filter { $0.is_done }.map { $0.step_id })
        var built: [PlanStepItem] = []

        for s in rawSteps {
            let unfinishedBefore = built.contains(where: { $0.ordre < s.ordre && !$0.isDone })
            built.append(
                PlanStepItem(
                    id: s.id,
                    ordre: s.ordre,
                    titre: s.titre,
                    description: s.description,
                    startDate: s.start_date,
                    endDate: s.end_date,
                    route: StepRoute.fromTitle(s.titre),
                    isDone: done.contains(s.id),
                    isLocked: unfinishedBefore && !unlockPreview
                )
            )
        }
        items = built
    }

    var completion: Double {
        guard !items.isEmpty else { return 0 }
        let done = items.filter(\.isDone).count
        return Double(done) / Double(items.count)
    }

    // Trophies demo (tweak rules if you want)
    var trophies: [TrophyCard] {
        let doneCount = items.filter(\.isDone).count
        let baseDone  = items.first(where: { $0.route == .mes_infos_de_base })?.isDone ?? false
        let explore   = items.first(where: { $0.route == .commencer_l_exploration_de_formations })?.isDone ?? false
        return [
            .init(title: "Infos de base complètes",
                  subtitle: "Profil de base renseigné",
                  icon: .system("checkmark.seal.fill"),
                  unlocked: baseDone),
            .init(title: "1ère étape franchie !",
                  subtitle: "Première étape terminée avec succès",
                  icon: .system("lock.open.fill"),
                  unlocked: doneCount >= 1),
            .init(title: "Ton projet prend forme",
                  subtitle: "Le parcours d’orientation est lancé",
                  icon: .system("leaf.fill"),
                  unlocked: explore || doneCount >= 2)
        ]
    }
    var trophiesCount: Int { trophies.filter(\.unlocked).count }
}

// MARK: - Main View

struct MonProjetView: View {
    @EnvironmentObject var authVM: AuthViewModel1
    @StateObject var vm: MonProjetVM

    @State private var route: StepRoute?
    @State private var flowProgress: Double = 0.30

    init(viewModel: MonProjetVM) { _vm = StateObject(wrappedValue: viewModel) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    TrophiesView(trophies: vm.trophies,
                                 unlocked: vm.trophiesCount,
                                 total: vm.trophies.count)
                    .padding(.horizontal)

                    stepsTimeline
                }
                .padding(.vertical, 12)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Mon projet")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $route) { stepRoute in destination(for: stepRoute) }
            .alert(isPresented: .constant(vm.error != nil)) {
                Alert(title: Text("Erreur"),
                      message: Text(vm.error ?? ""),
                      dismissButton: .default(Text("OK")) { vm.error = nil })
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Précision des recommandations")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                Text("\(Int(vm.completion * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
            }
            ProgressView(value: vm.completion).tint(Color(hex: "#17C1C1"))

            HStack(spacing: 10) {
                Button { /* push to profile completion if needed */ } label: {
                    Label("Augmenter la précision", systemImage: "sparkles")
                        .font(.subheadline.bold())
                        .padding(.vertical, 10).padding(.horizontal, 14)
                        .background(Color(hex: "#EFFFFF"))
                        .clipShape(Capsule())
                }
                Button { /* help */ } label: {
                    Text("Comment ça marche ?")
                        .font(.subheadline.bold())
                        .padding(.vertical, 10).padding(.horizontal, 14)
                        .overlay(Capsule().stroke(Color(.systemGray4)))
                }
                Spacer()
            }.buttonStyle(.plain)

            HStack(spacing: 8) {
                Label("Aperçu :", systemImage: "eye")
                    .font(.footnote).foregroundColor(.secondary)
                Toggle(isOn: Binding(get: { vm.unlockPreview },
                                     set: { _ in vm.togglePreview() })) {
                    Text(vm.unlockPreview ? "déverrouillé" : "verrouillé")
                        .font(.footnote).foregroundColor(.secondary)
                }
                .labelsHidden()
                Spacer()
                Text("\(vm.items.filter(\.isDone).count)/\(vm.items.count) étapes complétées")
                    .font(.footnote).foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        )
        .padding(.horizontal)
    }

    // MARK: - All steps timeline (always shows ALL)

    private var stepsTimeline: some View {
        VStack(spacing: 8) {
            HStack {
                Label("Toutes les étapes", systemImage: "list.bullet.rectangle")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
            }
            .padding(.horizontal)

            if vm.loading {
                ProgressView("Chargement…").padding()
            } else if vm.items.isEmpty {
                Text("Aucune étape").foregroundColor(.secondary).padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.items.enumerated()), id: \.element.id) { (idx, it) in
                        StepRow(index: idx + 1,
                                isFirst: idx == 0,
                                isLast: idx == vm.items.count - 1,
                                item: it,
                                onTap: { handleTap(it) })
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func handleTap(_ item: PlanStepItem) {
        guard !item.isLocked, let r = item.route else { return }
        route = r
    }

    // MARK: - Destinations (swap with your real flows if names differ)

    @ViewBuilder
    private func destination(for route: StepRoute) -> some View {
        switch route {
        case .mes_infos_de_base:
            SelectFiliereView(progress: $flowProgress, niveau: "Première")
                .environmentObject(authVM)
        case .definir_mes_preferences:
            PreferenceQuestionsView(progress: $flowProgress)
                .environmentObject(authVM)
        case .commencer_l_exploration_de_formations:
            OrientationChoicesView().environmentObject(authVM)
        case .identifier_mes_interets_professionnels:
            RiasecTestView().environmentObject(authVM)
        case .explorer_mes_formations_2_2:
            FormationsView().environmentObject(authVM)
        case .commencer_ma_liste_de_formations_favorites:
            FavoritesView().environmentObject(authVM)
        }
    }
}

// MARK: - Step timeline row

private struct StepRow: View {
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let item: PlanStepItem
    var onTap: () -> Void

    private var statusColor: Color {
        if item.isDone { return Color(hex: "#2EC1C1") }
        if item.isLocked { return .secondary }
        return Color(hex: "#6E56CF")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Rail
            VStack(spacing: 0) {
                Rectangle().fill(Color(.systemGray4)).frame(width: 2).opacity(isFirst ? 0 : 1).frame(maxHeight: 10)
                ZStack {
                    Circle().stroke(Color(.systemGray4), lineWidth: 2).frame(width: 22, height: 22)
                    Circle().fill(statusColor).frame(width: 12, height: 12)
                }
                Rectangle().fill(Color(.systemGray4)).frame(width: 2).opacity(isLast ? 0 : 1).frame(maxHeight: .infinity)
            }
            .frame(width: 22)

            // Card
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#EFFFFF"))
                        Text("\(index)").font(.subheadline.bold()).foregroundColor(Color(hex: "#1F3552"))
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.titre)
                            .font(.headline)
                            .foregroundColor(item.isLocked ? .secondary : Color(hex: "#1F3552"))
                            .lineLimit(2)
                        if let d = item.description, !d.isEmpty {
                            Text(d).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
                        }
                        HStack(spacing: 8) {
                            if let sd = item.startDate {
                                Label(sd, systemImage: "calendar")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            if item.isDone {
                                Text("Complet").font(.caption.bold()).foregroundColor(Color(hex: "#2EC1C1"))
                            } else if item.isLocked {
                                Text("Verrouillé").font(.caption.bold()).foregroundColor(.secondary)
                            } else {
                                Text("À faire").font(.caption.bold()).foregroundColor(Color(hex: "#6E56CF"))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: item.isLocked ? "lock.fill" : "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                )
            }
            .buttonStyle(.plain)
            .disabled(item.isLocked)
            .opacity(item.isLocked ? 0.75 : 1)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Trophies

private struct TrophiesView: View {
    let trophies: [TrophyCard]
    let unlocked: Int
    let total: Int

    private var grid: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("Trophées débloqués", systemImage: "trophy.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
                Text("\(unlocked)/\(total)")
                    .font(.footnote.bold())
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.6)))
            }

            LazyVGrid(columns: grid, spacing: 12) {
                ForEach(trophies) { t in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            switch t.icon {
                            case .system(let name): Image(systemName: name)
                                    .foregroundColor(t.unlocked ? Color(hex: "#2EC1C1") : .secondary)
                            case .emoji(let e): Text(e)
                            }
                            Text(t.title).font(.subheadline.bold()).foregroundColor(Color(hex: "#1F3552")).lineLimit(2)
                        }
                        Text(t.subtitle).font(.footnote).foregroundColor(.secondary).lineLimit(2)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(t.unlocked ? Color(hex: "#2EC1C1") : Color(.systemGray5), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                    )
                    .opacity(t.unlocked ? 1 : 0.75)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                Text("Continue pour débloquer plus de trophées !")
            }
            .font(.footnote.bold())
            .foregroundColor(Color(hex: "#6E56CF"))
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(Color.white.opacity(0.6)))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "#F1ECFF").opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.5)))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
    }
}

// MARK: - Replace with your real target views (kept minimal so file compiles)



struct FavoritesView: View { var body: some View { Text("Mes favoris").padding() } }

// MARK: - Preview (shows ALL steps)

struct MonProjetView_Previews: PreviewProvider {
    static var previews: some View {
        let steps: [PlanStepResponse] = [
            .init(id: 19, plan_action_id: 4, titre: "Mes infos de base", description: "Complète tes infos personnelles de base.", ordre: 1, start_date: "2025-08-11", end_date: nil),
            .init(id: 20, plan_action_id: 4, titre: "Définir mes préférences", description: "Choisis tes domaines et types de formation préférés.", ordre: 2, start_date: "2025-08-18", end_date: nil),
            .init(id: 21, plan_action_id: 4, titre: "Commencer l’exploration de formations", description: "Parcours des formations pertinentes.", ordre: 3, start_date: "2025-08-25", end_date: nil),
            .init(id: 22, plan_action_id: 4, titre: "Identifier mes intérêts professionnels", description: "Fais des tests et clarifie tes intérêts.", ordre: 4, start_date: "2025-09-01", end_date: nil),
            .init(id: 23, plan_action_id: 4, titre: "Explorer mes formations (2/2)", description: "Approfondis les formations repérées.", ordre: 5, start_date: "2025-09-08", end_date: nil),
            .init(id: 24, plan_action_id: 4, titre: "Commencer ma liste de formations favorites", description: "Ajoute tes options favorites.", ordre: 6, start_date: "2025-09-15", end_date: nil)
        ]
        let progress: [UserStepProgressResponse] = [
            .init(id: 1, user_id: 7, step_id: 19, is_done: true, done_at: nil),
            .init(id: 2, user_id: 7, step_id: 21, is_done: true, done_at: nil)
        ]
        let vm = MonProjetVM()
        vm.configure(steps: steps, progress: progress)

        return NavigationStack {
            MonProjetView(viewModel: vm)
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.light)
    }
}
