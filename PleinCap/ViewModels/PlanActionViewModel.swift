//
//  PlanActionViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 9/8/2025.
//



import Foundation
import SwiftUI
import Combine

@MainActor
final class PlanActionViewModel: ObservableObject {

    // MARK: - Dependencies
    private weak var auth: AuthViewModel1?

    // MARK: - Server data
    @Published var plan: PlanActionResponse? = nil
    @Published var progressByStepId: [Int: UserStepProgressResponse] = [:]

    // MARK: - UI state
    @Published var isLoadingPlan = false
    @Published var isLoadingProgress = false
    @Published var isMutatingStep = false
    @Published var errorMessage: String? = nil
    @Published var lastRefreshedAt: Date? = nil

    // MARK: - Init
    init(auth: AuthViewModel1?) {
        self.auth = auth
    }

    // MARK: - Quick access
    private var token: String? { auth?.accessToken }
    private var userId: Int? { auth?.userProfile?.id }

    // MARK: - Public API

    /// Pulls plan and progress in one go (safe to call onAppear)
    func refresh() {
        Task {
            await fetchPlan()
            await fetchProgress()
            self.lastRefreshedAt = Date()
        }
    }

    /// Fetch only the plan
    func fetchPlan() async {
        guard let token = token else {
            self.errorMessage = "Token manquant"
            return
        }
        isLoadingPlan = true; defer { isLoadingPlan = false }

        do {
            let p = try await NetworkManager.shared.fetchUserPlan(token: token)
            self.plan = p

            // Optionally mirror plan id back to auth.userProfile (handy for other screens)
            if var u = auth?.userProfile {
                u.planActionId = p.id
                auth?.userProfile = u
            }
        } catch {
            self.errorMessage = "Erreur chargement plan: \(error.localizedDescription)"
        }
    }

    /// Fetch only the user progress
    func fetchProgress() async {
        guard let token = token, let uid = userId else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }
        isLoadingProgress = true; defer { isLoadingProgress = false }

        do {
            let progress = try await NetworkManager.shared.fetchUserProgress(userId: uid, token: token)
            self.progressByStepId = Dictionary(uniqueKeysWithValues: progress.map { ($0.step_id, $0) })
        } catch {
            self.errorMessage = "Erreur chargement progression: \(error.localizedDescription)"
        }
    }

    /// Toggle step completion state (done/undone)
    func toggleStep(_ step: PlanStepResponse) {
        let currentlyDone = progressByStepId[step.id]?.is_done ?? false
        setStep(step, isDone: !currentlyDone)
    }

    /// Mark a step as done
    func markStepDone(_ step: PlanStepResponse) {
        setStep(step, isDone: true)
    }

    /// Mark a step as not done
    func markStepUndone(_ step: PlanStepResponse) {
        setStep(step, isDone: false)
    }

    // MARK: - Derived data for UI

    var stepsSorted: [PlanStepResponse] {
        (plan?.steps ?? []).sorted { lhs, rhs in
            if lhs.ordre != rhs.ordre { return lhs.ordre < rhs.ordre }
            return lhs.id < rhs.id
        }
    }

    var totalSteps: Int { stepsSorted.count }

    var completedCount: Int {
        stepsSorted.reduce(0) { acc, step in
            acc + ((progressByStepId[step.id]?.is_done ?? false) ? 1 : 0)
        }
    }

    var completionRatio: Double {
        guard totalSteps > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalSteps)
    }

    var completionPercentText: String {
        let pct = Int((completionRatio * 100.0).rounded())
        return "\(pct)%"
    }

    /// Steps grouped for convenience
    var doneSteps: [PlanStepResponse] {
        stepsSorted.filter { progressByStepId[$0.id]?.is_done ?? false }
    }

    var pendingSteps: [PlanStepResponse] {
        stepsSorted.filter { !(progressByStepId[$0.id]?.is_done ?? false) }
    }

    var overdueSteps: [PlanStepResponse] {
        let now = Date()
        return stepsSorted.filter {
            guard !(progressByStepId[$0.id]?.is_done ?? false),
                  let end = parseDate($0.end_date) else { return false }
            return end < now
        }
    }

    // MARK: - Private helpers

    private func setStep(_ step: PlanStepResponse, isDone: Bool) {
        guard let token = token, let uid = userId else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }
        isMutatingStep = true

        Task {
            defer { isMutatingStep = false }
            do {
                // If your API supports both PATCH and POST /done, prefer PATCH for toggling
                let updated = try await NetworkManager.shared.updateStepCompletion(
                    userId: uid,
                    stepId: step.id,
                    isDone: isDone,
                    token: token
                )
                // Update local cache
                progressByStepId[step.id] = updated
            } catch {
                self.errorMessage = "Échec mise à jour étape: \(error.localizedDescription)"
            }
        }
    }

    private func parseDate(_ s: String?) -> Date? {
        guard let s = s else { return nil }
        return DateParsers.parseTimestamp(s)
    }
}
