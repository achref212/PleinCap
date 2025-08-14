//
//  PlanActionViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 9/8/2025.
//


import Foundation
import SwiftUI

@MainActor
final class PlanActionViewModel: ObservableObject {

    // MARK: - Dependencies
    weak var auth: AuthViewModel1?
    func attachAuth(_ a: AuthViewModel1) { self.auth = a }

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
    init(auth: AuthViewModel1? = nil) {
        self.auth = auth
    }

    // MARK: - Quick access
    private var token: String? { auth?.accessToken }
    private var userId: Int? { auth?.userProfile?.id }

    // MARK: - Public API

    func refresh() {
        Task {
            await fetchPlan()
            await fetchProgress()
            self.lastRefreshedAt = Date()
        }
    }

    func fetchPlan() async {
        guard let token = token else {
            self.errorMessage = "Token manquant"
            return
        }
        isLoadingPlan = true; defer { isLoadingPlan = false }

        do {
            let p = try await NetworkManager.shared.fetchUserPlan(token: token)
            self.plan = p
            if var u = auth?.userProfile {
                u.planActionId = p.id
                auth?.userProfile = u
            }
        } catch {
            self.errorMessage = "Erreur chargement plan: \(error.localizedDescription)"
        }
    }

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

    func toggleStep(_ step: PlanStepResponse) { setStep(step, isDone: !(progressByStepId[step.id]?.is_done ?? false)) }
    func markStepDone(_ step: PlanStepResponse) { setStep(step, isDone: true) }
    func markStepUndone(_ step: PlanStepResponse) { setStep(step, isDone: false) }

    // MARK: - Derived data

    var stepsSorted: [PlanStepResponse] {
        (plan?.steps ?? []).sorted { $0.ordre == $1.ordre ? $0.id < $1.id : $0.ordre < $1.ordre }
    }
    var totalSteps: Int { stepsSorted.count }
    var completedCount: Int { stepsSorted.reduce(0) { $0 + ((progressByStepId[$1.id]?.is_done ?? false) ? 1 : 0) } }
    var completionRatio: Double { totalSteps == 0 ? 0 : Double(completedCount) / Double(totalSteps) }
    var completionPercentText: String { "\(Int((completionRatio * 100.0).rounded()))%" }
    var doneSteps: [PlanStepResponse] { stepsSorted.filter { progressByStepId[$0.id]?.is_done ?? false } }
    var pendingSteps: [PlanStepResponse] { stepsSorted.filter { !(progressByStepId[$0.id]?.is_done ?? false) } }

    // MARK: - Private

    private func setStep(_ step: PlanStepResponse, isDone: Bool) {
        guard let token = token, let uid = userId else {
            self.errorMessage = "Utilisateur non authentifié"
            return
        }
        isMutatingStep = true
        Task {
            defer { isMutatingStep = false }
            do {
                let updated = try await NetworkManager.shared.updateStepCompletion(
                    userId: uid, stepId: step.id, isDone: isDone, token: token
                )
                progressByStepId[step.id] = updated
            } catch {
                self.errorMessage = "Échec mise à jour étape: \(error.localizedDescription)"
            }
        }
    }
}
