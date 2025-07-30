//
//  PlanStepData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct PlanStepData: Codable {
    let id: Int
    let titre: String
    let planActionId: Int?
    let questions: [PlanQuestionData]?

    enum CodingKeys: String, CodingKey {
        case id
        case titre
        case planActionId = "plan_action_id"
        case questions
    }
}
