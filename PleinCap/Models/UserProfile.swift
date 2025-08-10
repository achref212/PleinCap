import Foundation

struct UserProfile0: Codable {
    let id: Int?
    let email: String
    let nom: String
    let prenom: String
    let sexe: String
    let dateNaissance: Date  // Changed to Date for better handling
    let profilePicture: String?
    let access_token: String?

    let niveauScolaire: String?
    let voie: String?
    let objectif: String?
    let specialites: [String]?  // JSON array from backend
    let filiere: String?

    let telephone: String?
    let budget: String?

    let estBoursier: Bool?
    var planActionId: Int?  // Changed to match plan_action_id

    let createdAt: Date?  // Changed to Date
    let updatedAt: Date?  // Changed to Date

    // Optional nested relationships
    var moyenne: MoyenneData?  // Link to Moyenne model
    let location: LocationData?  // Link to Location model

    enum CodingKeys: String, CodingKey {
        case id, email, nom, prenom, sexe
        case dateNaissance = "date_naissance"
        case profilePicture = "profile_picture"
        case niveauScolaire = "niveau_scolaire"
        case voie, objectif, specialites, filiere,access_token
        case telephone, budget
        case estBoursier = "est_boursier"
        case planActionId = "plan_action_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case moyenne, location
    }

    init(
        id: Int? = nil,
        email: String,
        nom: String,
        prenom: String,
        sexe: String,
        dateNaissance: Date,
        profilePicture: String? = nil,
        niveauScolaire: String? = nil,
        voie: String? = nil,
        objectif: String? = nil,
        specialites: [String]? = nil,
        filiere: String? = nil,
        telephone: String? = nil,
        budget: String? = nil,
        estBoursier: Bool? = nil,
        planActionId: Int? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        moyenne: MoyenneData? = nil,
        location: LocationData? = nil,
        access_token: String? = nil
    ) {
        self.id = id
        self.email = email
        self.nom = nom
        self.prenom = prenom
        self.sexe = sexe
        self.dateNaissance = dateNaissance
        self.profilePicture = profilePicture
        self.niveauScolaire = niveauScolaire
        self.voie = voie
        self.objectif = objectif
        self.specialites = specialites
        self.filiere = filiere
        self.telephone = telephone
        self.budget = budget
        self.estBoursier = estBoursier
        self.planActionId = planActionId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.moyenne = moyenne
        self.location = location
        self.access_token = access_token
    }

    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id)
            self.email = try container.decode(String.self, forKey: .email)
            self.nom = try container.decode(String.self, forKey: .nom)
            self.prenom = try container.decode(String.self, forKey: .prenom)
            self.sexe = try container.decode(String.self, forKey: .sexe)

            // Decode date fields with a custom date strategy
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Supports fractional seconds
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            // Fallback formatter for dates without fractional seconds
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")

            // Decode dateNaissance
            if let dateString = try container.decodeIfPresent(String.self, forKey: .dateNaissance) {
                if let date = dateFormatter.date(from: dateString) ?? fallbackFormatter.date(from: dateString) {
                    self.dateNaissance = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .dateNaissance, in: container, debugDescription: "Invalid date format for date_naissance: \(dateString)")
                }
            } else {
                throw DecodingError.keyNotFound(CodingKeys.dateNaissance, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Missing date_naissance"))
            }

            // Decode createdAt
            if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
                self.createdAt = dateFormatter.date(from: createdAtString) ?? fallbackFormatter.date(from: createdAtString)
            } else {
                self.createdAt = nil
            }

            // Decode updatedAt
            if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
                self.updatedAt = dateFormatter.date(from: updatedAtString) ?? fallbackFormatter.date(from: updatedAtString)
            } else {
                self.updatedAt = nil
            }

            self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
            self.niveauScolaire = try container.decodeIfPresent(String.self, forKey: .niveauScolaire)
            self.voie = try container.decodeIfPresent(String.self, forKey: .voie)
            self.objectif = try container.decodeIfPresent(String.self, forKey: .objectif)
            self.specialites = try container.decodeIfPresent([String].self, forKey: .specialites)
            self.filiere = try container.decodeIfPresent(String.self, forKey: .filiere)
            self.telephone = try container.decodeIfPresent(String.self, forKey: .telephone)
            self.budget = try container.decodeIfPresent(String.self, forKey: .budget)
            self.estBoursier = try container.decodeIfPresent(Bool.self, forKey: .estBoursier)
            self.planActionId = try container.decodeIfPresent(Int.self, forKey: .planActionId)
            self.moyenne = try container.decodeIfPresent(MoyenneData.self, forKey: .moyenne)
            self.location = try container.decodeIfPresent(LocationData.self, forKey: .location)
            self.access_token = try container.decodeIfPresent(String.self, forKey: .access_token)
        }
}
extension UserProfile0 {
    static let preview = UserProfile0(
        id: 1,
        email: "john@example.com",
        nom: "Doe",
        prenom: "John",
        sexe: "H",
        dateNaissance: {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: "2000-01-01")!
        }(),
        profilePicture: nil,
        niveauScolaire: "Terminale",
        voie: "Générale",
        objectif: "test",
        specialites: ["Maths", "NSI"],
        filiere: "Scientifique",
        telephone: "+33 6 12 34 56 78",
        budget: "10000",
        estBoursier: true,
        planActionId: 1,
        createdAt: {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter.date(from: "2024-06-01T10:00:00Z")!
        }(),
        updatedAt: {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter.date(from: "2025-07-23T14:30:00Z")!
        }(),
        moyenne: MoyenneData(
            specialty: ["Math", "Physics"],
            notes: [NoteData(subject: "Math", score: 15.5), NoteData(subject: "French", score: 14.0)]
        ),
        location: LocationData(
            adresse: "12 rue des Lilas, Paris",
            distance: 20,
            etablissement: "Lycée Jean Monnet",
            academie: "Versailles"
        )
    )
}
