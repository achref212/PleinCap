//
//  LocationData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct LocationData: Codable {
    let adresse: String?
    let distance: Double?
    let latitude: Double?
    let longitude: Double?
    let etablissement: String?
    let academie: String?

    enum CodingKeys: String, CodingKey {
        case adresse
        case distance
        case latitude
        case longitude
        case etablissement
        case academie
    }

    init(
        adresse: String? = nil,
        distance: Double? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        etablissement: String? = nil,
        academie: String? = nil
    ) {
        self.adresse = adresse
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.etablissement = etablissement
        self.academie = academie
    }
}
