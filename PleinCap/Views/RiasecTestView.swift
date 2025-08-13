import SwiftUI

struct RiasecTestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = RiasecViewModel()

    @State private var showResumePrompt = false
    @State private var showCheckpointDialog = false

    @Namespace private var topID

    var body: some View {
        VStack(spacing: 12) {
            ProgressBarView(progress: .constant(viewModel.progress))
                .padding(.top, 4)

            if viewModel.currentIndex < viewModel.questions.count {
                let batch = viewModel.getCurrentBatch()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            Color.clear.frame(height: 0).id(topID)

                            // Section heading based on first question
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

                            // Choice pair (left/right) layout
                            if batch.first?.kind == .choice, batch.count == 2 {
                                let traits = extractTrait(from: batch[0].text)
                                ForEach(0..<batch[0].options.count, id: \.self) { i in
                                    DomainCompetenceRow(
                                        domain: batch[0].options[i],
                                        leftQuestion: "Je me sens le \(traits.left)",
                                        rightQuestion: "Je me sens le \(traits.right)",
                                        isLeftSelected: viewModel.answers[batch[0].id]?.contains(i) ?? false,
                                        isRightSelected: viewModel.answers[batch[1].id]?.contains(i) ?? false,
                                        onLeftTap: { viewModel.registerAnswer(for: batch[0].id, indices: [i]) },
                                        onRightTap: { viewModel.registerAnswer(for: batch[1].id, indices: [i]) }
                                    )
                                }
                            } else {
                                // Singles & adjectives
                                ForEach(batch) { question in
                                    QuestionViewDispatcher(question: question, viewModel: viewModel) { indices in
                                        viewModel.registerAnswer(for: question.id, indices: indices)
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

                // Footer Next
                let allAnswered = batch.allSatisfy { !(viewModel.answers[$0.id] ?? []).isEmpty }
                PrimaryGradientButton(title: "Suivant", enabled: allAnswered) {
                    viewModel.advance()
                    if viewModel.shouldShowCheckpoint { showCheckpointDialog = true }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            } else {
                // ✅ Test finished — show results (save to backend outside this screen).
                ResultView(scores: viewModel.scores)

                PrimaryGradientButton(title: "Terminer", enabled: true) {
                    // Clear checkpoint so next run starts fresh
                    viewModel.clearCheckpoint()
                    dismiss()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(CircleBackgroundBottomView())
        .navigationTitle("Test RIASEC")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Offer resume if we have a checkpoint and we’re at the very beginning
            if viewModel.checkpointExists() && viewModel.answeredCount == 0 && viewModel.currentIndex == 0 {
                showResumePrompt = true
            }
        }
        // Resume prompt (when opening the test again)
        .confirmationDialog("Reprendre là où tu t’es arrêté(e) ?", isPresented: $showResumePrompt, titleVisibility: .visible) {
            Button("Reprendre") {
                viewModel.tryRestoreCheckpoint()
            }
            Button("Recommencer", role: .destructive) {
                viewModel.clearCheckpoint()
                viewModel.resetRun()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Nous avons retrouvé ta progression précédente.")
        }
        // Checkpoint dialog (every 10 réponses)
        .confirmationDialog("Sauvegarder ta progression et revenir plus tard ?", isPresented: $showCheckpointDialog, titleVisibility: .visible) {
            Button("Sauvegarder & quitter") {
                viewModel.persistCheckpoint()
                dismiss()
            }
            Button("Continuer") { /* just close the dialog */ }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Ta progression sera conservée sur cet appareil.")
        }
    }
}

// MARK: - Helpers already used in your code

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

// Dispatch single/adjective question UIs
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

struct ResultView: View {
    let scores: [String: Int]

    var rawScores: [String: Int] {
        scores
    }

    var normalizedScores: [String: Int] {
        scores.mapValues { Int((Double($0) / 33.0) * 100.0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Résultats RIASEC")
                    .font(.title2.bold())
                    .padding(.top)

                RiasecProfileSummary(scores: scores)

                RadarChartView(rawScores: rawScores, normalizedScores: normalizedScores)

                HorizontalBarChartView(rawScores: rawScores, normalizedScores: normalizedScores)
            }
            .padding(.bottom)
        }
        .background(CircleBackgroundBottomView())
    }
}

struct ContentView0: View {
    var body: some View {
        NavigationView {
            RiasecTestView()
        }
    }
}

#Preview {
    ContentView0()
}
