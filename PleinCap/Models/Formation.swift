//
//  Formation.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

// Models.swift
// Models.swift
import Foundation

// Main Formation struct
struct Formation: Identifiable, Codable {
    let id: Int
    let timestamp: String
    let url: String
    let titre: String
    let etablissement: String
    let typeFormation: String
    let typeEtablissement: String
    let formationControleeParEtat: Bool
    let apprentissage: String?
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
    let filieresBac: [FiliereBac]?
    let specialitesFavorisees: [SpecialiteFavorisee]?
    let matieresEnseignees: [MatiereEnseignee]?
    let debouchesMetiers: [DeboucheMetier]?
    let debouchesSecteurs: [DeboucheSecteur]?
    let tsTauxParBac: [TsTauxParBac]?
    let intervallesAdmis: [IntervalsAdmis]?
    let criteresCandidature: [CriteresCandidature]?
    let boursiers: Boursiers?
    let profilsAdmis: [ProfilsAdmis]?
    let promoCharacteristics: PromoCharacteristics?
    let postFormationOutcomes: PostFormationOutcomes?
    let voieGenerale: Voie?
    let voiePro: Voie?
    let voieTechnologique: Voie?

    enum CodingKeys: String, CodingKey {
        case id, timestamp, url, titre, etablissement
        case typeFormation = "type_formation"
        case typeEtablissement = "type_etablissement"
        case formationControleeParEtat = "formation_controlee_par_etat"
        case apprentissage
        case prixAnnuel = "prix_annuel"
        case salaireMoyen = "salaire_moyen"
        case poursuiteEtudes = "poursuite_etudes"
        case tauxInsertion = "taux_insertion"
        case lienOnisep = "lien_onisep"
        case resumeProgramme = "resume_programme"
        case duree
        case formationSelective = "formation_selective"
        case tauxPassage2eAnnee = "taux_passage_2e_annee"
        case accesFormation = "acces_formation"
        case preBacAdmissionPercentage = "pre_bac_admission_percentage"
        case femalePercentage = "female_percentage"
        case newBacStudentsCount = "new_bac_students_count"
        case totalAdmittedCount = "total_admitted_count"
        case complementaryPhaseAcceptancePercentage = "complementary_phase_acceptance_percentage"
        case tauxReussite3_4Ans = "taux_reussite_3_4_ans"
        case lieu
        case salaireBornes = "salaire_bornes"
        case badges
        case filieresBac = "filieres_bac"
        case specialitesFavorisees = "specialites_favorisees"
        case matieresEnseignees = "matieres_enseignees"
        case debouchesMetiers = "debouches_metiers"
        case debouchesSecteurs = "debouches_secteurs"
        case tsTauxParBac = "ts_taux_par_bac"
        case intervallesAdmis = "intervalles_admis"
        case criteresCandidature = "criteres_candidature"
        case boursiers
        case profilsAdmis = "profils_admis"
        case promoCharacteristics = "promo_characteristics"
        case postFormationOutcomes = "post_formation_outcomes"
        case voieGenerale = "voie_generale"
        case voiePro = "voie_pro"
        case voieTechnologique = "voie_technologique"
    }
}

// Nested structs
struct Lieu: Codable {
    let id: Int
    let ville: String
    let region: String
    let departement: String
    let academy: String
    let gpsCoordinates: String

    enum CodingKeys: String, CodingKey {
        case id, ville, region, departement, academy
        case gpsCoordinates = "gps_coordinates"
    }
}

struct SalaireBornes: Codable {
    let id: Int
    let min: Double
    let max: Double
}

struct Badge: Codable {
    let id: Int
    let badge: String
}

struct FiliereBac: Codable {
    let id: Int
    let filiere: String
}

struct SpecialiteFavorisee: Codable {
    let id: Int
    let specialite: String
}

struct MatiereEnseignee: Codable {
    let id: Int
    let matiere: String
}

struct DeboucheMetier: Codable {
    let id: Int
    let metier: String
}

struct DeboucheSecteur: Codable {
    let id: Int
    let secteur: String
}

struct TsTauxParBac: Codable {
    let id: Int
    let bacType: String
    let taux: String

    enum CodingKeys: String, CodingKey {
        case id
        case bacType = "bac_type"
        case taux
    }
}

struct IntervalsAdmis: Codable {
    let id: Int
    let intervalType: String
    let tleGenerale: String
    let tleTechno: String
    let tlePro: String

    enum CodingKeys: String, CodingKey {
        case id
        case intervalType = "interval_type"
        case tleGenerale = "tle_generale"
        case tleTechno = "tle_techno"
        case tlePro = "tle_pro"
    }
}

struct SousCritere: Codable {
    let id: Int
    let type: String
    let titre: String
    let description: String
}

struct CriteresCandidature: Codable {
    let id: Int
    let categorie: String
    let poids: Double
    let sousCriteres: [SousCritere]
}

struct Boursiers: Codable {
    let id: Int
    let tauxMinimumBoursiers: String
    let pourcentageBoursiersNeoBacheliers: Double

    enum CodingKeys: String, CodingKey {
        case id
        case tauxMinimumBoursiers = "taux_minimum_boursiers"
        case pourcentageBoursiersNeoBacheliers = "pourcentage_boursiers_neo_bacheliers"
    }
}

struct ProfilsAdmis: Codable {
    let id: Int
    let bacType: String
    let percentage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case bacType = "bac_type"
        case percentage
    }
}

struct PromoCharacteristics: Codable {
    let id: Int
    let newBacStudentsCount: Int
    let femalePercentage: Double
    let totalAdmittedCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case newBacStudentsCount = "new_bac_students_count"
        case femalePercentage = "female_percentage"
        case totalAdmittedCount = "total_admitted_count"
    }
}

struct PostFormationOutcomes: Codable {
    let id: Int
    let poursuiventEtudes: String
    let enEmploi: String
    let autreSituation: String

    enum CodingKeys: String, CodingKey {
        case id
        case poursuiventEtudes = "poursuivent_etudes"
        case enEmploi = "en_emploi"
        case autreSituation = "autre_situation"
    }
}

struct Voie: Codable {
    let id: Int
    let filieres: String
    let specialities: String

    enum CodingKeys: String, CodingKey {
        case id, filieres, specialities
    }
}
