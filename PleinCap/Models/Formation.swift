//
//  Formation.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

// Models.swift
import Foundation

struct Formation: Codable, Identifiable {
    let id: Int
    let timestamp: String
    let url: String
    let titre: String
    let etablissement: String
    let typeFormation: String? // type_formation
    let typeEtablissement: String? // type_etablissement
    let formationControleeParEtat: Bool?
    let apprentissage: String? // "Oui" or "Non"
    let prixAnnuel: Double?
    let salaireMoyen: Double?
    let poursuiteEtudes: String?
    let tauxInsertion: String?
    let lienOnisep: String?
    let resumeProgramme: String?
    let duree: String?
    let formationSelective: Bool?
    let tauxPassage2eAnnee: String?
    let accesFormation: String?
    let preBacAdmissionPercentage: Double?
    let femalePercentage: Double?
    let newBacStudentsCount: Int?
    let totalAdmittedCount: Int?
    let complementaryPhaseAcceptancePercentage: Double?
    let tauxReussite3_4Ans: String?
    let lieu: Lieu?
    let salaireBornes: SalaireBornes?
    let badges: [Badge]?
    let filieresBac: [String]?
    let specialitesFavorisees: [String]?
    let matieresEnseignees: [String]?
    let debouchesMetiers: [String]?
    let debouchesSecteurs: [String]?
    let tsTauxParBac: [TsTauxParBac]?
    let intervallesAdmis: [IntervallesAdmis]?
    let criteresCandidature: [CritereCandidature]?
    let boursiers: Boursiers?
    let profilsAdmis: [ProfilAdmis]?
    let promoCharacteristics: PromoCharacteristics?
    let postFormationOutcomes: PostFormationOutcomes?
    let voieGenerale: Voie?
    let voiePro: Voie?
    let voieTechnologique: Voie?

    // Ensure camelCase to snake_case mapping
    enum CodingKeys: String, CodingKey {
        case id, timestamp, url, titre, etablissement, typeFormation = "type_formation", typeEtablissement = "type_etablissement", formationControleeParEtat = "formation_controlee_par_etat", apprentissage, prixAnnuel = "prix_annuel", salaireMoyen = "salaire_moyen", poursuiteEtudes = "poursuite_etudes", tauxInsertion = "taux_insertion", lienOnisep = "lien_onisep", resumeProgramme = "resume_programme", duree, formationSelective = "formation_selective", tauxPassage2eAnnee = "taux_passage_2e_annee", accesFormation = "acces_formation", preBacAdmissionPercentage = "pre_bac_admission_percentage", femalePercentage = "female_percentage", newBacStudentsCount = "new_bac_students_count", totalAdmittedCount = "total_admitted_count", complementaryPhaseAcceptancePercentage = "complementary_phase_acceptance_percentage", tauxReussite3_4Ans = "taux_reussite_3_4_ans", lieu, salaireBornes = "salaire_bornes", badges, filieresBac = "filieres_bac", specialitesFavorisees = "specialites_favorisees", matieresEnseignees = "matieres_enseignees", debouchesMetiers = "debouches_metiers", debouchesSecteurs = "debouches_secteurs", tsTauxParBac = "ts_taux_par_bac", intervallesAdmis = "intervalles_admis", criteresCandidature = "criteres_candidature", boursiers, profilsAdmis = "profils_admis", promoCharacteristics = "promo_characteristics", postFormationOutcomes = "post_formation_outcomes", voieGenerale = "voie_generale", voiePro = "voie_pro", voieTechnologique = "voie_technologique"
    }
}
struct Badge: Codable {
    let badge: String
}
struct Lieu: Codable {
    let ville: String?
    let region: String?
    let departement: String?
    let academy: String?
    let gpsCoordinates: String? // "lat, lon" format

    enum CodingKeys: String, CodingKey {
        case ville, region, departement, academy, gpsCoordinates = "gps_coordinates"
    }
}

struct SalaireBornes: Codable {
    let min: Double?
    let max: Double?
}

struct TsTauxParBac: Codable {
    let bacType: String? // e.g., "TS Tle système français G"
    let taux: String?

    enum CodingKeys: String, CodingKey {
        case bacType = "bac_type"
        case taux
    }
}

struct IntervallesAdmis: Codable {
    let intervalType: String?
    let tleGenerale: String?
    let tleTechno: String?
    let tlePro: String?

    enum CodingKeys: String, CodingKey {
        case intervalType = "interval_type"
        case tleGenerale = "tle_generale"
        case tleTechno = "tle_techno"
        case tlePro = "tle_pro"
    }
}

struct CritereCandidature: Codable {
    let categorie: String?
    let poids: Double?
    let sousCriteres: [SousCritere]?

    enum CodingKeys: String, CodingKey {
        case categorie, poids, sousCriteres = "sous_criteres"
    }
}

struct SousCritere: Codable {
    let type: String?
    let titre: String?
    let description: String?
}

struct Boursiers: Codable {
    let tauxMinimumBoursiers: String?
    let pourcentageBoursiersNeoBacheliers: Double?

    enum CodingKeys: String, CodingKey {
        case tauxMinimumBoursiers = "taux_minimum_boursiers"
        case pourcentageBoursiersNeoBacheliers = "pourcentage_boursiers_neo_bacheliers"
    }
}

struct ProfilAdmis: Codable {
    let bacType: String?
    let percentage: Double?

    enum CodingKeys: String, CodingKey {
        case bacType = "bac_type"
        case percentage
    }
}

struct PromoCharacteristics: Codable {
    let newBacStudentsCount: Int?
    let femalePercentage: Double?
    let totalAdmittedCount: Int?

    enum CodingKeys: String, CodingKey {
        case newBacStudentsCount = "new_bac_students_count"
        case femalePercentage = "female_percentage"
        case totalAdmittedCount = "total_admitted_count"
    }
}

struct PostFormationOutcomes: Codable {
    let poursuiventEtudes: String?
    let enEmploi: String?
    let autreSituation: String?

    enum CodingKeys: String, CodingKey {
        case poursuiventEtudes = "poursuivent_etudes"
        case enEmploi = "en_emploi"
        case autreSituation = "autre_situation"
    }
}

struct Voie: Codable {
    let filieres: [String]?
    let specialities: [String]?

    enum CodingKeys: String, CodingKey {
        case filieres, specialities
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let filieresString = try? container.decode(String.self, forKey: .filieres),
           let filieresData = filieresString.data(using: .utf8) {
            self.filieres = try? JSONDecoder().decode([String].self, from: filieresData)
        } else {
            self.filieres = nil
        }

        if let specialitiesString = try? container.decode(String.self, forKey: .specialities),
           let specialitiesData = specialitiesString.data(using: .utf8) {
            self.specialities = try? JSONDecoder().decode([String].self, from: specialitiesData)
        } else {
            self.specialities = nil
        }
    }
}
