//
//  TokenResponse.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//


import Foundation

struct UserResponse: Codable {
    let id: Int
    let email: String
    let nom: String
    let prenom: String
    let sexe: String
    let date_naissance: String
}
struct TokenResponse: Codable {
    let user: UserProfile
    let access_token: String
    let refresh_token: String?
    let token_type: String
}
