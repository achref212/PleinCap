//
//  RiasecTestView.swift
//  PleinCap
//
//  Created by chaabani achref on 3/8/2025.
//

import SwiftUI

struct RiasecTestView: View {
    @StateObject var viewModel = RiasecViewModel()

    var body: some View {
        VStack(spacing: 12) {
            ProgressBarView(progress: Binding(
                get: {
                    Double(viewModel.currentIndex) / Double(viewModel.questions.count)
                }, set: { _ in }
            ))

            if viewModel.currentIndex < viewModel.questions.count {
                let questions = viewModel.getCurrentBatch()
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(questions) { question in
                            QuestionViewDispatcher(question: question) { selectedIndices in
                                viewModel.registerAnswer(for: question.id, indices: selectedIndices)
                            }
                        }
                    }
                }
                .padding(.bottom, 12)

                Button("Suivant") {
                    viewModel.advance()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                ResultView(scores: viewModel.scores)
            }
        }
        .background(CircleBackgroundBottomView())
    }
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

// MARK: - Dispatcher

struct QuestionViewDispatcher: View {
    let question: Question
    let onAnswer: ([Int]) -> Void

    var body: some View {
        switch question.kind {
        case .single:
            SingleChoiceQuestionView(question: question, onAnswer: onAnswer)
        case .adjective:
            AdjectiveQuestionView(question: question, onAnswer: onAnswer)
        case .choice:
            DomainChoiceQuestionView(question: question, onAnswer: onAnswer)
        }
    }
}

// MARK: - Views

struct SingleChoiceQuestionView: View {
    let question: Question
    let onAnswer: ([Int]) -> Void
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.text)
                .font(.title3.bold())
                .padding(.horizontal)

            ForEach(question.options.indices, id: \..self) { i in
                Button(action: {
                    selectedIndex = i
                    onAnswer([i])
                }) {
                    Text(question.options[i])
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(selectedIndex == i ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedIndex == i ? Color.blue.opacity(0.1) : Color.clear)
                                )
                        )
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
}

struct AdjectiveQuestionView: View {
    let question: Question
    let onAnswer: ([Int]) -> Void
    @State private var selected: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.text)
                    .font(.title3.bold())
                    .padding(.horizontal)

                ForEach(question.options.indices, id: \..self) { i in
                    Button(action: {
                        if selected.contains(i) {
                            selected.remove(i)
                        } else if selected.count < 2 {
                            selected.insert(i)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(selected.contains(i) ? Color.blue : Color.clear)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))

                            Text(question.options[i])
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }

                Button("Valider") {
                    onAnswer(Array(selected))
                }
                .disabled(selected.count != 2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
}

struct DomainChoiceQuestionView: View {
    let question: Question
    let onAnswer: ([Int]) -> Void
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.text)
                .font(.title3.bold())
                .padding(.horizontal)

            ForEach(question.options.indices, id: \..self) { i in
                Button(action: {
                    selectedIndex = i
                    onAnswer([i])
                }) {
                    HStack {
                        Circle()
                            .fill(selectedIndex == i ? Color.purple : Color.clear)
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.purple, lineWidth: 2))

                        Text(question.options[i])
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }
}

// MARK: - Result

struct ResultView: View {
    let scores: [String: Int]

    var rawScores: [String: Int] {
        scores
    }

    var normalizedScores: [String: Int] {
        let max = scores.values.max() ?? 1
        return scores.mapValues { Int(Double($0) / Double(max) * 10.0) }
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
