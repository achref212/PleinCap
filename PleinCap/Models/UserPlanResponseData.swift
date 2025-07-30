//
//  UserPlanResponseData.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import Foundation

struct UserPlanResponseData: Codable {
    let id: Int
    let userId: Int?
    let questionId: Int?
    let reponse: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case questionId = "question_id"
        case reponse
    }
}
