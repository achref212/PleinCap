import Foundation

struct UserProfile: Codable {
    let id: Int?
    let email: String
    let nom: String
    let prenom: String
    let sexe: String
    let dateNaissance: Date  // Changed to Date for better handling
    let profilePicture: String?

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
        case voie, objectif, specialites, filiere
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
        location: LocationData? = nil
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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateNaissance = try container.decode(Date.self, forKey: .dateNaissance)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)

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
    }
}
extension UserProfile {
    static let preview = UserProfile(
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
