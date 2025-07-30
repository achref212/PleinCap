//
//  Item.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
