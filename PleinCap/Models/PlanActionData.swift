//
//  PlanActionData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct PlanActionData: Codable {
    let id: Int
    let nom: String
    let steps: [PlanStepData]?

    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case steps
    }
}
