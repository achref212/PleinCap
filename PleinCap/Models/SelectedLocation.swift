//
//  SelectedLocation.swift
//  PFE_APP
//
//  Created by chaabani achref on 13/6/2025.
//

import Foundation
// SelectedLocation.swift
import MapKit

/// Les infos que l’on veut mémoriser
struct SelectedLocation: Identifiable, Codable, Equatable {
    var id        = UUID()
    var title     : String
    var latitude  : Double
    var longitude : Double
    var distanceKm: Double
    var location :String
}

/// Petit store observable – à injecter dans l’Environment si besoin
@Observable
final class LocationSelectionStore {
    var selection: SelectedLocation?
}
