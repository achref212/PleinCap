import SwiftUI

struct RiasecTestView: View {
    @StateObject var viewModel = RiasecViewModel()
    @Namespace var topID

    var body: some View {
        VStack(spacing: 12) {
            ProgressBarView(progress: Binding(
                get: {
                    Double(viewModel.currentIndex) / Double(viewModel.questions.count)
                }, set: { _ in }
            ))

            if viewModel.currentIndex < viewModel.questions.count {
                let questions = viewModel.getCurrentBatch()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            Color.clear.frame(height: 0).id(topID)

                            if questions.first?.kind == .choice, questions.count == 2 {
                                let traits = extractTrait(from: questions[0].text)
                                InstructionCardView(text: "Indique le domaine dans lequel tu te sens le plus capable dans la colonne de droite et le domaine dans lequel tu te sens le moins compétent dans la colonne de gauche")
                                ForEach(0..<questions[0].options.count, id: \ .self) { i in
                                    DomainCompetenceRow(
                                        domain: questions[0].options[i],
                                        leftQuestion: "Je me sens le \(traits.left)",
                                        rightQuestion: "Je me sens le \(traits.right)",
                                        isLeftSelected: viewModel.answers[questions[0].id]?.contains(i) ?? false,
                                        isRightSelected: viewModel.answers[questions[1].id]?.contains(i) ?? false,
                                        onLeftTap: {
                                            viewModel.registerAnswer(for: questions[0].id, indices: [i])
                                        },
                                        onRightTap: {
                                            viewModel.registerAnswer(for: questions[1].id, indices: [i])
                                        }
                                    )
                                }
                            } else {
                                if let first = questions.first {
                                    if first.kind == .single {
                                        InstructionCardView(text: "Pour chacune des propositions suivantes, choisis l'appréciation qui correspond à ce que tu penses de toi")
                                    } else if first.kind == .adjective {
                                        InstructionCardView(text: "Voici une liste d'adjectifs. Choisis 2 adjectifs qui te ressemblent le plus tel(le) que tu es et non pas tel(le) que tu voudrais être.")
                                    }
                                }
                                ForEach(questions) { question in
                                    QuestionViewDispatcher(question: question, viewModel: viewModel) { selectedIndices in
                                        viewModel.registerAnswer(for: question.id, indices: selectedIndices)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.currentIndex) { _ in
                        withAnimation {
                            proxy.scrollTo(topID, anchor: .top)
                        }
                    }
                }

                let answeredAll = questions.allSatisfy { viewModel.answers[$0.id]?.isEmpty == false }
                PrimaryGradientButton(title: "Suivant", enabled: answeredAll) {
                    viewModel.advance()
                }
                .padding()
            } else {
                ResultView(scores: viewModel.scores)
            }
        }
        .background(CircleBackgroundBottomView())
    }
}

func extractTrait(from text: String, defaultPositive: String = "plus capable", defaultNegative: String = "moins compétent") -> (left: String, right: String) {
    let isPositive = text.contains("plus") || text.contains("+")
    let isNegative = text.contains("moins") || text.contains("-")

    if let rangeStart = text.range(of: "sens le "),
       let rangeEnd = text.range(of: " en", range: rangeStart.upperBound..<text.endIndex) {
        let trait = text[rangeStart.upperBound..<rangeEnd.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        if isPositive {
            return (left: defaultNegative, right: trait)
        } else if isNegative {
            return (left: trait, right: defaultPositive)
        }
    }
    return (left: defaultNegative, right: defaultPositive)
}

extension RiasecViewModel {
    func getCurrentBatch() -> [Question] {
        let current = currentIndex
        if current >= questions.count { return [] }
        let kind = questions[current].kind
        if kind == .single {
            return Array(questions[current..<min(current + 5, questions.count)])
        } else if kind == .choice {
            return Array(questions[current..<min(current + 2, questions.count)])
        } else {
            return [questions[current]]
        }
    }

    func advance() {
        let kind = questions[currentIndex].kind
        if kind == .single {
            currentIndex += 5
        } else if kind == .choice {
            currentIndex += 2
        } else {
            currentIndex += 1
        }
    }

    func registerAnswer(for id: Int, indices: [Int]) {
        answers[id] = indices
        guard let question = questions.first(where: { $0.id == id }) else { return }
        for i in indices {
            let letter = question.correctLetters[i] ?? ""
            if !letter.isEmpty {
                scores[letter, default: 0] += 1
            }
        }
    }
}

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
                ForEach(question.options.indices, id: \ .self) { i in
                    AdjectiveCardView(
                        adjective: question.options[i],
                        isSelected: viewModel.answers[question.id]?.contains(i) ?? false,
                        onTap: {
                            var current = Set(viewModel.answers[question.id] ?? [])
                            if current.contains(i) {
                                current.remove(i)
                            } else if current.count < 2 {
                                current.insert(i)
                            }
                            viewModel.registerAnswer(for: question.id, indices: Array(current))
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
