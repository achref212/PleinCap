import Foundation

struct MoyenneData: Codable {
    let id: Int?
    let specialty: [String]?  // List of specialties, e.g., ["Math", "Physics"]
    let notes: [NoteData]?   // List of notes, e.g., [{"subject": "Math", "score": 15.5}, ...]

    enum CodingKeys: String, CodingKey {
        case id
        case specialty
        case notes
    }

    init(
        id: Int? = nil,
        specialty: [String]? = nil,
        notes: [NoteData]? = nil
    ) {
        self.id = id
        self.specialty = specialty
        self.notes = notes
    }
}

struct NoteData: Codable {
    let subject: String
    let score: Double

    enum CodingKeys: String, CodingKey {
        case subject
        case score
    }

    init(subject: String, score: Double) {
        self.subject = subject
        self.score = score
    }
}
