//
//  QuestionType.swift
//  PleinCap
//
//  Created by chaabani achref on 3/8/2025.
//

import Foundation
enum QuestionKind: String, Codable {
    case single
    case adjective
    case choice
}

struct Question: Identifiable, Codable {
    let id: Int
    let kind: QuestionKind
    let text: String
    let options: [String]
    let correctLetters: [String]
}
