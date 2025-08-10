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

struct PlanActionResponse: Codable, Identifiable {
    let id: Int
    let nom: String
    let start_date: String?
    let end_date: String?
    let is_active: Bool?
    let steps: [PlanStepResponse]?
}

struct PlanStepResponse: Codable, Identifiable, Hashable {
    let id: Int
    let plan_action_id: Int
    let titre: String
    let description: String?
    let ordre: Int
    let start_date: String?
    let end_date: String?
}

struct UserStepProgressResponse: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let step_id: Int
    let is_done: Bool
    let done_at: String?
}
