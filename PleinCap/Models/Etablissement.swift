//
//  Etablissement.swift
//  PleinCap
//
//  Created by chaabani achref on 10/8/2025.
//

// Etablissement.swift
import Foundation


struct Etablissement: Codable, Identifiable, Hashable {
    let id: Int
    let academieId: Int        // ✅ use academieId consistently
    let etablissement: String?
    let city: String?
    let sector: String?
    let track: String?
    var displayName: String { etablissement ?? "Établissement #\(id)" }

    enum CodingKeys: String, CodingKey {
        case id
        case academieId = "academie_id"
        case etablissement, city, sector, track
    }
}
