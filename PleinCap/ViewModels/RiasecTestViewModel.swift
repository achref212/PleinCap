import Foundation

// MARK: - ViewModel

final class RiasecViewModel: ObservableObject {
    // Public state
    @Published var currentIndex: Int = 0
    @Published var answers: [Int: [Int]] = [:]                // questionID -> selected option indices
    @Published var scores: [String: Int] = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]
    @Published var questions: [Question] = []

    // --- Checkpoint for SINGLE questions only ---
    private(set) var nextSinglesCheckpoint: Int = 10          // ask after 10, then 20, 30...
    private let checkpointKey = "riasec_checkpoint_v1"

    // Init
    init() { loadQuestions() }

    // Load questions from bundle
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

    // MARK: - Quick lookups

    private var questionsByID: [Int: Question] {
        Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
    }

    // MARK: - Progress

    var answeredCount: Int {
        questions.filter { !(answers[$0.id] ?? []).isEmpty }.count
    }

    var singleAnsweredCount: Int {
        questions.filter { $0.kind == .single && !(answers[$0.id] ?? []).isEmpty }.count
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(answeredCount) / Double(questions.count)
    }

    // MARK: - Batching used by the view

    func getCurrentBatch() -> [Question] {
        let idx = currentIndex
        guard idx < questions.count else { return [] }
        switch questions[idx].kind {
        case .single:
            return Array(questions[idx..<min(idx + 5, questions.count)])
        case .choice:
            return Array(questions[idx..<min(idx + 2, questions.count)])
        case .adjective:
            return [questions[idx]]
        }
    }

    func advance() {
        guard currentIndex < questions.count else { return }
        switch questions[currentIndex].kind {
        case .single:    currentIndex += 5
        case .choice:    currentIndex += 2
        case .adjective: currentIndex += 1
        }
        // (We do NOT bump the checkpoint here. The view decides when to show the dialog,
        // then calls `markSinglesCheckpointShown()` when the user continues.)
    }

    // MARK: - Answering / scoring

    func registerAnswer(for questionID: Int, indices: [Int]) {
        answers[questionID] = indices

        // Recompute safely so edits never double-count
        var newScores: [String: Int] = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]
        for (qid, inds) in answers {
            guard let q = questionsByID[qid] else { continue }
            for i in inds {
                let letter = q.correctLetters[i]
                if !letter.isEmpty {
                    newScores[letter, default: 0] += 1
                }
            }
        }
        scores = newScores
    }
    // MARK: - Singles-only checkpoint logic

    /// Should we ask the user now? (Only for SINGLE-kind answered count)
    var shouldShowSinglesCheckpoint: Bool {
        singleAnsweredCount >= nextSinglesCheckpoint && currentIndex < questions.count
    }

    /// Call this when the user *continues* after seeing the prompt,
    /// so we won't immediately re-prompt again.
    func markSinglesCheckpointShown() {
        while singleAnsweredCount >= nextSinglesCheckpoint {
            nextSinglesCheckpoint += 10
        }
    }

    // MARK: - Local checkpoint persistence (resume later)

    private struct Snapshot: Codable {
        let currentIndex: Int
        let answers: [String: [Int]]   // String keys for JSON safety
        let scores: [String: Int]
        let nextSinglesCheckpoint: Int
    }

    func checkpointExists() -> Bool {
        UserDefaults.standard.data(forKey: checkpointKey) != nil
    }

    func persistCheckpoint() {
        let snap = Snapshot(
            currentIndex: currentIndex,
            answers: Dictionary(uniqueKeysWithValues: answers.map { (String($0.key), $0.value) }),
            scores: scores,
            nextSinglesCheckpoint: nextSinglesCheckpoint
        )
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: checkpointKey)
        }
    }

    func tryRestoreCheckpoint() {
        guard let data = UserDefaults.standard.data(forKey: checkpointKey),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        currentIndex = snap.currentIndex
        answers = Dictionary(uniqueKeysWithValues: snap.answers.compactMap { (Int($0.key) ?? -1, $0.value) }.filter { $0.0 >= 0 })
        scores = snap.scores
        nextSinglesCheckpoint = snap.nextSinglesCheckpoint
    }

    func clearCheckpoint() {
        UserDefaults.standard.removeObject(forKey: checkpointKey)
    }

    // Optional helper to reset the run
    func resetRun() {
        currentIndex = 0
        answers.removeAll()
        scores = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]
        nextSinglesCheckpoint = 10
    }
}
