//
//  RiasecTestViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 3/8/2025.
//

import Foundation
class RiasecViewModel: ObservableObject {
    @Published var currentIndex = 0
    @Published var answers: [Int: [Int]] = [:]
    @Published var scores: [String: Int] = ["R": 0, "I": 0, "A": 0, "S": 0, "E": 0, "C": 0]
    @Published var questions: [Question] = []

    init() {
        loadQuestions()
    }

    func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions_riasec", withExtension: "json") else {
            print("❌ Fichier questions_riasec.json introuvable")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Question].self, from: data)
            self.questions = decoded
        } catch {
            print("❌ Erreur de décodage : \(error)")
        }
    }

    func select(answer indices: [Int], for question: Question) {
        answers[question.id] = indices
        for i in indices {
            let letter = question.correctLetters[i] ?? ""
            if !letter.isEmpty {
                scores[letter, default: 0] += 1
            }
        }
        currentIndex += 1
    }
}
