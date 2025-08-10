//
//  user.swift
//  PleinCap
//
//  Created by chaabani achref on 8/8/2025.
//

import Foundation

// MARK: - TokenResponse (what /login, /verify-registration, /auth/google return)
struct TokenResponse: Codable {
    let user: UserProfile
    let access_token: String
    let refresh_token: String
    let token_type: String
    let profile_complete: Bool? // backend may or may not include this
}
struct TokenResponse0: Codable {
    let user: UserProfile0
    let access_token: String
    let refresh_token: String
    let token_type: String
    let profile_complete: Bool? // backend may or may not include this
}

// MARK: - User
struct UserProfile: Codable, Identifiable {
    let id: Int
    let email: String
    let nom: String
    let prenom: String
    let sexe: String

    let dateNaissance: Date             // "YYYY-MM-DD" or ISO8601
    let profilePicture: String?

    let niveauScolaire: String?
    let voie: String?
    let objectif: String?
    let specialites: [String]?
    let filiere: String?
    let telephone: String?
    let budget: String?
    let estBoursier: Bool?

    // New address/geo fields on User (nullable in backend)
    let adresse: String?
    let distance: Double?
    let latitude: Double?
    let longitude: Double?
    let etablissement: String?
    let academie: String?

    // Other optional JSON fields you might use later
    let score: Double?
    let idee: String?
    let orientationChoices: [String: AnyCodable]? // if you use it
    let riasecDifferentiation: AnyCodable?
    let preferences: AnyCodable?
    let notes: [UserNote]?

    var planActionId: Int?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, nom, prenom, sexe
        case dateNaissance = "date_naissance"
        case profilePicture = "profile_picture"
        case niveauScolaire = "niveau_scolaire"
        case voie, objectif, specialites, filiere, telephone, budget
        case estBoursier = "est_boursier"

        case adresse, distance, latitude, longitude, etablissement, academie

        case score, idee
        case orientationChoices = "orientation_choices"
        case riasecDifferentiation = "riasec_differentiation"
        case preferences
        case notes

        case planActionId = "plan_action_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Custom decoding to handle multiple date formats
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(Int.self, forKey: .id)
        email           = try c.decode(String.self, forKey: .email)
        nom             = try c.decode(String.self, forKey: .nom)
        prenom          = try c.decode(String.self, forKey: .prenom)
        sexe            = try c.decode(String.self, forKey: .sexe)

        // date_naissance might be "YYYY-MM-DD" or full timestamp
        if let rawBirth = try c.decodeIfPresent(String.self, forKey: .dateNaissance) {
            guard let parsed = DateParsers.parseBirthdate(rawBirth) else {
                throw DecodingError.dataCorruptedError(forKey: .dateNaissance, in: c, debugDescription: "Invalid date_naissance: \(rawBirth)")
            }
            dateNaissance = parsed
        } else {
            throw DecodingError.keyNotFound(CodingKeys.dateNaissance, .init(codingPath: c.codingPath, debugDescription: "date_naissance missing"))
        }

        profilePicture  = try c.decodeIfPresent(String.self, forKey: .profilePicture)
        niveauScolaire  = try c.decodeIfPresent(String.self, forKey: .niveauScolaire)
        voie            = try c.decodeIfPresent(String.self, forKey: .voie)
        objectif        = try c.decodeIfPresent(String.self, forKey: .objectif)
        specialites     = try c.decodeIfPresent([String].self, forKey: .specialites)
        filiere         = try c.decodeIfPresent(String.self, forKey: .filiere)
        telephone       = try c.decodeIfPresent(String.self, forKey: .telephone)
        budget          = try c.decodeIfPresent(String.self, forKey: .budget)
        estBoursier     = try c.decodeIfPresent(Bool.self, forKey: .estBoursier)

        adresse         = try c.decodeIfPresent(String.self, forKey: .adresse)
        distance        = try c.decodeIfPresent(Double.self, forKey: .distance)
        latitude        = try c.decodeIfPresent(Double.self, forKey: .latitude)
        longitude       = try c.decodeIfPresent(Double.self, forKey: .longitude)
        etablissement   = try c.decodeIfPresent(String.self, forKey: .etablissement)
        academie        = try c.decodeIfPresent(String.self, forKey: .academie)

        score           = try c.decodeIfPresent(Double.self, forKey: .score)
        idee            = try c.decodeIfPresent(String.self, forKey: .idee)
        orientationChoices     = try c.decodeIfPresent([String: AnyCodable].self, forKey: .orientationChoices)
        riasecDifferentiation  = try c.decodeIfPresent(AnyCodable.self, forKey: .riasecDifferentiation)
        preferences             = try c.decodeIfPresent(AnyCodable.self, forKey: .preferences)
        notes                   = try c.decodeIfPresent([UserNote].self, forKey: .notes)

        planActionId    = try c.decodeIfPresent(Int.self, forKey: .planActionId)

        if let rawCreated = try c.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = DateParsers.parseTimestamp(rawCreated)
        } else { createdAt = nil }

        if let rawUpdated = try c.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = DateParsers.parseTimestamp(rawUpdated)
        } else { updatedAt = nil }
    }

    // Encode if you send user back (e.g., PATCH). Formats birthdate as "yyyy-MM-dd".
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(email, forKey: .email)
        try c.encode(nom, forKey: .nom)
        try c.encode(prenom, forKey: .prenom)
        try c.encode(sexe, forKey: .sexe)

        try c.encode(DateParsers.birthdateFormatter.string(from: dateNaissance), forKey: .dateNaissance)
        try c.encodeIfPresent(profilePicture, forKey: .profilePicture)

        try c.encodeIfPresent(niveauScolaire, forKey: .niveauScolaire)
        try c.encodeIfPresent(voie, forKey: .voie)
        try c.encodeIfPresent(objectif, forKey: .objectif)
        try c.encodeIfPresent(specialites, forKey: .specialites)
        try c.encodeIfPresent(filiere, forKey: .filiere)
        try c.encodeIfPresent(telephone, forKey: .telephone)
        try c.encodeIfPresent(budget, forKey: .budget)
        try c.encodeIfPresent(estBoursier, forKey: .estBoursier)

        try c.encodeIfPresent(adresse, forKey: .adresse)
        try c.encodeIfPresent(distance, forKey: .distance)
        try c.encodeIfPresent(latitude, forKey: .latitude)
        try c.encodeIfPresent(longitude, forKey: .longitude)
        try c.encodeIfPresent(etablissement, forKey: .etablissement)
        try c.encodeIfPresent(academie, forKey: .academie)

        try c.encodeIfPresent(score, forKey: .score)
        try c.encodeIfPresent(idee, forKey: .idee)
        try c.encodeIfPresent(orientationChoices, forKey: .orientationChoices)
        try c.encodeIfPresent(riasecDifferentiation, forKey: .riasecDifferentiation)
        try c.encodeIfPresent(preferences, forKey: .preferences)
        try c.encodeIfPresent(notes, forKey: .notes)

        try c.encodeIfPresent(planActionId, forKey: .planActionId)
        if let createdAt { try c.encode(DateParsers.iso8601WithMillis.string(from: createdAt), forKey: .createdAt) }
        if let updatedAt { try c.encode(DateParsers.iso8601WithMillis.string(from: updatedAt), forKey: .updatedAt) }
    }
}

// MARK: - Notes (matches backend `notes` JSON)
struct UserNote: Codable {
    let subject: String?
    let score: Double?
}

// MARK: - Flexible date parsing helpers
enum DateParsers {
    // Birthdate from backend often "yyyy-MM-dd"
    static let birthdateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    // Full timestamps
    static let iso8601WithMillis: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX" // supports fractional seconds
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static let iso8601NoMillis: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func parseBirthdate(_ s: String) -> Date? {
        // try plain date first, then fall back to full timestamp if backend sends one
        if let d = birthdateFormatter.date(from: s) { return d }
        if let d = iso8601WithMillis.date(from: s) { return d }
        if let d = iso8601NoMillis.date(from: s) { return d }
        return nil
    }

    static func parseTimestamp(_ s: String) -> Date? {
        if let d = iso8601WithMillis.date(from: s) { return d }
        if let d = iso8601NoMillis.date(from: s) { return d }
        // try raw date as last resort
        if let d = birthdateFormatter.date(from: s) { return d }
        return nil
    }
}

// MARK: - AnyCodable (for unknown/JSON blobs like orientation_choices)
struct AnyCodable: Codable {
    let value: Any
    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let bool = try? c.decode(Bool.self) { value = bool; return }
        if let int = try? c.decode(Int.self) { value = int; return }
        if let dbl = try? c.decode(Double.self) { value = dbl; return }
        if let str = try? c.decode(String.self) { value = str; return }
        if let arr = try? c.decode([AnyCodable].self) { value = arr.map { $0.value }; return }
        if let dict = try? c.decode([String: AnyCodable].self) { value = dict.mapValues { $0.value }; return }
        value = ()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let v as Bool: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as String: try c.encode(v)
        case let v as [Any]:
            try c.encode(v.map { AnyCodable($0) })
        case let v as [String: Any]:
            try c.encode(v.mapValues { AnyCodable($0) })
        default:
            try c.encodeNil()
        }
    }
}
