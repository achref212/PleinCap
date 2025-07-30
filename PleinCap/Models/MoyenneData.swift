//
//  MoyenneData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct MoyenneData: Codable {
    let id: Int?
    let moyenneGenerale: Double?
    let moyenneFrancais: Double?
    let moyennePhilo: Double?
    let moyenneMath: Double?
    let moyenneSvt: Double?
    let moyennePhysique: Double?
    let moyenneAnglais: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case moyenneGenerale = "moyenne_generale"
        case moyenneFrancais = "moyenne_francais"
        case moyennePhilo = "moyenne_philo"
        case moyenneMath = "moyenne_math"
        case moyenneSvt = "moyenne_svt"
        case moyennePhysique = "moyenne_physique"
        case moyenneAnglais = "moyenne_anglais"
    }

    init(
        id: Int? = nil,
        moyenneGenerale: Double? = nil,
        moyenneFrancais: Double? = nil,
        moyennePhilo: Double? = nil,
        moyenneMath: Double? = nil,
        moyenneSvt: Double? = nil,
        moyennePhysique: Double? = nil,
        moyenneAnglais: Double? = nil
    ) {
        self.id = id
        self.moyenneGenerale = moyenneGenerale
        self.moyenneFrancais = moyenneFrancais
        self.moyennePhilo = moyennePhilo
        self.moyenneMath = moyenneMath
        self.moyenneSvt = moyenneSvt
        self.moyennePhysique = moyennePhysique
        self.moyenneAnglais = moyenneAnglais
    }
}
