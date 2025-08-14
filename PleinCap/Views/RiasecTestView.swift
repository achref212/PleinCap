import SwiftUI

struct RiasecTestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel1
    @StateObject var viewModel = RiasecViewModel()

    // Navigation
    @State private var goToDashboard = false

    // Dialogs
    @State private var showResumePrompt = false
    @State private var showSinglesCheckpoint = false

    // UI
    @Namespace private var topID
    @State private var saving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            // Progress from VM
            ProgressBarView(progress: .constant(viewModel.progress))
                .padding(.top, 6)

            if viewModel.currentIndex < viewModel.questions.count {
                let batch = viewModel.getCurrentBatch()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            Color.clear.frame(height: 0).id(topID)

                            // Section hint
                            if let first = batch.first {
                                switch first.kind {
                                case .single:
                                    InstructionCardView(text: "Pour chacune des propositions suivantes, choisis l’appréciation qui te correspond le mieux.")
                                case .adjective:
                                    InstructionCardView(text: "Voici une liste d’adjectifs. Choisis 2 adjectifs qui te ressemblent le plus (tel(le) que tu es).")
                                case .choice:
                                    InstructionCardView(text: "Indique pour chaque domaine celui où tu te sens le plus capable (droite) et le moins compétent (gauche).")
                                }
                            }

                            // Choice-pair layout (two questions acting together)
                            if batch.first?.kind == .choice, batch.count == 2 {
                                let traits = extractTrait(from: batch[0].text)
                                ForEach(0..<batch[0].options.count, id: \.self) { i in
                                    DomainCompetenceRow(
                                        domain: batch[0].options[i],
                                        leftQuestion: "Je me sens le \(traits.left)",
                                        rightQuestion: "Je me sens le \(traits.right)",
                                        isLeftSelected: viewModel.answers[batch[0].id]?.contains(i) ?? false,
                                        isRightSelected: viewModel.answers[batch[1].id]?.contains(i) ?? false,
                                        onLeftTap:  { viewModel.registerAnswer(for: batch[0].id, indices: [i]) },
                                        onRightTap: { viewModel.registerAnswer(for: batch[1].id, indices: [i]) }
                                    )
                                }
                            } else {
                                // Singles & adjectives
                                ForEach(batch) { q in
                                    QuestionViewDispatcher(question: q, viewModel: viewModel) { selected in
                                        viewModel.registerAnswer(for: q.id, indices: selected)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: viewModel.currentIndex) { _ in
                        withAnimation { proxy.scrollTo(topID, anchor: .top) }
                    }
                }

                // Footer
                let allAnswered = batch.allSatisfy { !(viewModel.answers[$0.id] ?? []).isEmpty }
                PrimaryGradientButton(title: "Suivant", enabled: allAnswered) {
                    // Advance pages (5 singles, 2 choice, 1 adjective)
                    viewModel.advance()

                    // Ask checkpoint only when SINGLE-answered hits 10,20,30...
                    if viewModel.shouldShowSinglesCheckpoint {
                        showSinglesCheckpoint = true
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            } else {
                // Finished — show summary and save
                ResultSummaryBlock(
                    scores: viewModel.scores,
                    onSave: { Task { await saveResultsAndGoHome() } },
                    saving: saving
                )

                // Hidden nav to dashboard
                NavigationLink(isActive: $goToDashboard) {
                    DashboardView().environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()
            }
        }
        .background(CircleBackgroundBottomView())
        .navigationTitle("Test RIASEC")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Offer resume only at the very beginning
            if viewModel.checkpointExists(),
               viewModel.currentIndex == 0,
               viewModel.answeredCount == 0 {
                showResumePrompt = true
            }
        }
        // Resume previous local checkpoint
        .confirmationDialog("Reprendre là où tu t’es arrêté(e) ?", isPresented: $showResumePrompt, titleVisibility: .visible) {
            Button("Reprendre") { viewModel.tryRestoreCheckpoint() }
            Button("Recommencer", role: .destructive) {
                viewModel.clearCheckpoint()
                viewModel.resetRun()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Nous avons retrouvé ta progression précédente.")
        }
        // Singles checkpoint (every 10 answered singles)
        .confirmationDialog("Sauvegarder et revenir plus tard ?", isPresented: $showSinglesCheckpoint, titleVisibility: .visible) {
            Button("Sauvegarder & quitter") {
                viewModel.persistCheckpoint()
                dismiss() // back to previous screen
            }
            Button("Continuer") {
                viewModel.markSinglesCheckpointShown()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Ta progression sera conservée sur cet appareil.")
        }
        .alert(item: Binding(
            get: { errorMessage.map { ErrorMessage(message: $0) } },
            set: { _ in errorMessage = nil })
        ) { err in
            Alert(title: Text("Erreur"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Save results to user

    private func saveResultsAndGoHome() async {
        guard !saving else { return }
        saving = true
        defer { saving = false }

        // Raw scores (already computed in VM)
        let raw = viewModel.scores

        // Normalized (0–100) – adjust divisor if your test differs
        let normalized = raw.mapValues { Int((Double($0) / 33.0) * 100.0) }

        // Differentiation value + level
        let sortedVals = raw.values.sorted(by: >)
        let d1 = Double(sortedVals[safe: 0] ?? 0)
        let d2 = Double(sortedVals[safe: 1] ?? 0)
        let d3 = Double(sortedVals[safe: 2] ?? 0)
        let d4 = Double(sortedVals[safe: 3] ?? 0)
        let d5 = Double(sortedVals[safe: 4] ?? 0)

        let differentiation = Int((d1 - ((d2 + d3) / 2.0)) + (d3 - ((d4 + d5) / 2.0)))
        let level = differentiation >= 6 ? "FORTE" : (differentiation >= 3 ? "MOYENNE" : "FAIBLE")

        // Top 3 letters (for convenience)
        let top3 = raw.sorted { $0.value > $1.value }.prefix(3).map { $0.key }

        let payload: [String: Any] = [
            "riasec_scores": raw,                       // {"R": 5, "I": 3, ...}
            "riasec_normalized": normalized,            // {"R": 45, ...}
            "riasec_differentiation": [                 // was [null] before — now a JSON object
                "value": differentiation,
                "level": level,
                "top": top3
            ]
        ]

        await withCheckedContinuation { cont in
            authVM.updateUserFields(payload) { result in
                switch result {
                case .success:
                    // Clear local checkpoint since the run is done
                    viewModel.clearCheckpoint()
                    withAnimation { goToDashboard = true }
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
                cont.resume()
            }
        }
    }
}

// MARK: - Helper views

/// Small block used when the test is finished
private struct ResultSummaryBlock: View {
    let scores: [String: Int]
    let onSave: () -> Void
    let saving: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Résultats RIASEC")
                .font(.title2.bold())
                .padding(.top)

            // Light summary: top 3 poles
            let top = scores.sorted { $0.value > $1.value }.prefix(3)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(top), id: \.key) { kv in
                    HStack {
                        Text(kv.key).font(.headline)
                        Spacer()
                        Text("\(kv.value)")
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding(.horizontal)

            PrimaryGradientButton(title: saving ? "Enregistrement…" : "Enregistrer et revenir au tableau de bord",
                                  enabled: !saving,
                                  action: onSave)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Utilities you already have elsewhere

func extractTrait(from text: String,
                  defaultPositive: String = "plus capable",
                  defaultNegative: String = "moins compétent") -> (left: String, right: String) {
    let isPositive = text.contains("plus") || text.contains("+")
    let isNegative = text.contains("moins") || text.contains("-")

    if let start = text.range(of: "sens le "),
       let end = text.range(of: " en", range: start.upperBound..<text.endIndex) {
        let trait = text[start.upperBound..<end.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        if isPositive { return (defaultNegative, trait) }
        if isNegative { return (trait, defaultPositive) }
    }
    return (defaultNegative, defaultPositive)
}

// Dispatcher for single/adjective UIs
struct QuestionViewDispatcher: View {
    let question: Question
    @ObservedObject var viewModel: RiasecViewModel
    let onAnswer: ([Int]) -> Void

    var body: some View {
        switch question.kind {
        case .single:
            TextualScaleQuestionView(
                questionText: question.text,
                options: question.options,
                onSelect: { onAnswer([$0]) }
            )
        case .adjective:
            VStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { i in
                    AdjectiveCardView(
                        adjective: question.options[i],
                        isSelected: viewModel.answers[question.id]?.contains(i) ?? false,
                        onTap: {
                            var set = Set(viewModel.answers[question.id] ?? [])
                            if set.contains(i) { set.remove(i) }
                            else if set.count < 2 { set.insert(i) }
                            onAnswer(Array(set))
                        }
                    )
                }
            }
        case .choice:
            EmptyView()
        }
    }
}

// Safe array index


// MARK: - Preview (non-crashing)

struct RiasecTestView_Previews: PreviewProvider {
    struct Wrapper: View {
        @StateObject var auth = AuthViewModel1()
        var body: some View {
            NavigationStack {
                RiasecTestView()
                    .environmentObject(auth)
            }
        }
    }
    static var previews: some View {
        Wrapper().preferredColorScheme(.light)
        Wrapper().preferredColorScheme(.dark)
    }
}
