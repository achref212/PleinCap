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

