//
//  Academie.swift
//  PleinCap
//
//  Created by chaabani achref on 10/8/2025.
//

// Academie.swift
import Foundation

struct Academie: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    /// Present only if you call `/academies/{id}?with_etablissements=true`
    let etablissements: [Etablissement]?

    // If later you decide to expose the URL in the API, just uncomment:
    // let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case etablissements
        // case url
    }
}
