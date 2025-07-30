//
//  PlanQuestionData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct PlanQuestionData: Codable {
    let id: Int
    let contenu: String
    let stepId: Int?
    let responses: [UserPlanResponseData]?

    enum CodingKeys: String, CodingKey {
        case id
        case contenu
        case stepId = "step_id"
        case responses
    }
}
