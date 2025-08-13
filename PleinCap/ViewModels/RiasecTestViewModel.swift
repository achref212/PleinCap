import Foundation

// MARK: - ViewModel

final class RiasecViewModel: ObservableObject {
    // Public state
    @Published var currentIndex: Int = 0
    @Published var answers: [Int: [Int]] = [:]                // questionID -> selected option indices
    @Published var scores: [String: Int] = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]
    @Published var questions: [Question] = []

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

    // MARK: - Progress
    var answeredCount: Int {
        questions.filter { !(answers[$0.id] ?? []).isEmpty }.count
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
        bumpCheckpointIfNeeded()
    }

    // MARK: - Answering / scoring
    func registerAnswer(for questionID: Int, indices: [Int]) {
        answers[questionID] = indices

        // Recompute scores so edits never double-count
        var newScores: [String: Int] = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]

        for (qid, inds) in answers {
            guard let q = questions.first(where: { $0.id == qid }) else { continue }

            for i in inds {
                // If `correctLetters` is an Array<String>
                if i >= 0 && i < q.correctLetters.count {
                    let letter = q.correctLetters[i]
                    if !letter.isEmpty {
                        newScores[letter, default: 0] += 1
                    }
                }

                // If in your model `correctLetters` is a Dictionary<Int, String>,
                // use this instead (uncomment and remove the array branch above):
                // if let letter = q.correctLetters[i], !letter.isEmpty {
                //     newScores[letter, default: 0] += 1
                // }
            }
        }

        scores = newScores
    }

    // MARK: - Checkpoint (local only; no backend write)
    private(set) var nextCheckpoint: Int = 10
    var shouldShowCheckpoint: Bool {
        answeredCount >= nextCheckpoint && currentIndex < questions.count
    }
    private func bumpCheckpointIfNeeded() {
        while answeredCount >= nextCheckpoint { nextCheckpoint += 10 }
    }

    private struct Snapshot: Codable {
        let currentIndex: Int
        let answers: [String: [Int]]   // String keys for JSON safety
        let scores: [String: Int]
        let nextCheckpoint: Int
    }
    private let checkpointKey = "riasec_checkpoint_v1"

    func checkpointExists() -> Bool {
        UserDefaults.standard.data(forKey: checkpointKey) != nil
    }

    func persistCheckpoint() {
        let snap = Snapshot(
            currentIndex: currentIndex,
            answers: Dictionary(uniqueKeysWithValues: answers.map { (String($0.key), $0.value) }),
            scores: scores,
            nextCheckpoint: nextCheckpoint
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
        nextCheckpoint = snap.nextCheckpoint
    }

    func clearCheckpoint() {
        UserDefaults.standard.removeObject(forKey: checkpointKey)
    }

    // Optional helper to reset the run
    func resetRun() {
        currentIndex = 0
        answers.removeAll()
        scores = ["R": 0,"I": 0,"A": 0,"S": 0,"E": 0,"C": 0]
        nextCheckpoint = 10
    }
}
