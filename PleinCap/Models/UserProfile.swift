import Foundation

struct UserProfile: Codable {
    let id: Int?
    let email: String
    let nom: String
    let prenom: String
    let sexe: String
    let dateNaissance: String
    let profilePicture: String?

    let niveauScolaire: String?
    let voie: String?
    let objectif: String?

    let specialites: [String]?
    let filiere: [String]?

    let moyenneGenerale: Double?
    let moyenneFrancais: Double?
    let moyennePhilo: Double?
    let moyenneMath: Double?
    let moyenneSvt: Double?
    let moyennePhysique: Double?
    let moyenneAnglais: Double?

    let telephone: String?
    let adresse: String?
    let distance: String?
    let budget: String?

    let academie: String?
    let estBoursier: Bool?
    let planAction: [String]?

    let createdAt: String?
    let updatedAt: String?

    // Initialiseur manuel pour compatibilité complète
    init(
        id: Int?,
        email: String,
        nom: String,
        prenom: String,
        sexe: String,
        dateNaissance: String,
        profilePicture: String?,
        niveauScolaire: String?,
        voie: String?,
        objectif: String?,
        specialites: [String]?,
        filiere: [String]?,
        moyenneGenerale: Double?,
        moyenneFrancais: Double?,
        moyennePhilo: Double?,
        moyenneMath: Double?,
        moyenneSvt: Double?,
        moyennePhysique: Double?,
        moyenneAnglais: Double?,
        telephone: String?,
        adresse: String?,
        distance: String?,
        budget: String?,
        academie: String?,
        estBoursier: Bool?,
        planAction: [String]?,
        createdAt: String?,
        updatedAt: String?
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
        self.moyenneGenerale = moyenneGenerale
        self.moyenneFrancais = moyenneFrancais
        self.moyennePhilo = moyennePhilo
        self.moyenneMath = moyenneMath
        self.moyenneSvt = moyenneSvt
        self.moyennePhysique = moyennePhysique
        self.moyenneAnglais = moyenneAnglais
        self.telephone = telephone
        self.adresse = adresse
        self.distance = distance
        self.budget = budget
        self.academie = academie
        self.estBoursier = estBoursier
        self.planAction = planAction
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    enum CodingKeys: String, CodingKey {
        case id, email, nom, prenom, sexe
        case dateNaissance = "date_naissance"
        case profilePicture = "profile_picture"
        case niveauScolaire = "niveau_scolaire"
        case voie, specialites, filiere,objectif
        case moyenneGenerale = "moyenne_generale"
        case moyenneFrancais = "moyenne_francais"
        case moyennePhilo = "moyenne_philo"
        case moyenneMath = "moyenne_math"
        case moyenneSvt = "moyenne_svt"
        case moyennePhysique = "moyenne_physique"
        case moyenneAnglais = "moyenne_anglais"
        case telephone, adresse, distance, budget
        case academie
        case estBoursier = "est_boursier"
        case planAction = "plan_action"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nom = try container.decode(String.self, forKey: .nom)
        self.prenom = try container.decode(String.self, forKey: .prenom)
        self.sexe = try container.decode(String.self, forKey: .sexe)
        self.dateNaissance = try container.decode(String.self, forKey: .dateNaissance)
        self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)

        self.niveauScolaire = try container.decodeIfPresent(String.self, forKey: .niveauScolaire)
        self.voie = try container.decodeIfPresent(String.self, forKey: .voie)
        self.objectif = try container.decodeIfPresent(String.self, forKey: .objectif)
        self.specialites = try container.decodeIfPresent([String].self, forKey: .specialites)
        self.filiere = try container.decodeIfPresent([String].self, forKey: .filiere)

        self.moyenneGenerale = try container.decodeIfPresent(Double.self, forKey: .moyenneGenerale)
        self.moyenneFrancais = try container.decodeIfPresent(Double.self, forKey: .moyenneFrancais)
        self.moyennePhilo = try container.decodeIfPresent(Double.self, forKey: .moyennePhilo)
        self.moyenneMath = try container.decodeIfPresent(Double.self, forKey: .moyenneMath)
        self.moyenneSvt = try container.decodeIfPresent(Double.self, forKey: .moyenneSvt)
        self.moyennePhysique = try container.decodeIfPresent(Double.self, forKey: .moyennePhysique)
        self.moyenneAnglais = try container.decodeIfPresent(Double.self, forKey: .moyenneAnglais)

        self.telephone = try container.decodeIfPresent(String.self, forKey: .telephone)
        self.adresse = try container.decodeIfPresent(String.self, forKey: .adresse)
        self.distance = try container.decodeIfPresent(String.self, forKey: .distance)
        self.budget = try container.decodeIfPresent(String.self, forKey: .budget)

        self.academie = try container.decodeIfPresent(String.self, forKey: .academie)
        self.estBoursier = try container.decodeIfPresent(Bool.self, forKey: .estBoursier)
        self.planAction = try container.decodeIfPresent([String].self, forKey: .planAction)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
extension UserProfile {
    static let preview = UserProfile(
        id: 1,
        email: "john@example.com",
        nom: "Doe",
        prenom: "John",
        sexe: "H",
        dateNaissance: "2000-01-01",
        profilePicture: nil,
        niveauScolaire: "Terminale",
        voie: "Générale",
        objectif: "test",
        specialites: ["Maths", "NSI"],
        filiere: ["Scientifique"],
        moyenneGenerale: 15.0,
        moyenneFrancais: 14.5,
        moyennePhilo: 13.0,
        moyenneMath: 17.0,
        moyenneSvt: 16.5,
        moyennePhysique: 16.0,
        moyenneAnglais: 15.5,
        telephone: "+33 6 12 34 56 78",
        adresse: "12 rue des Lilas, Paris",
        distance: "20km",
        budget: "10000",
        academie: "Versailles",
        estBoursier: true,
        planAction: ["Découvrir les prépas", "Explorer les écoles d’ingénieurs"],
        createdAt: "2024-06-01T10:00:00Z",
        updatedAt: "2025-07-23T14:30:00Z"
    )
}
