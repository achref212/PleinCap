//
//  UserService.swift
//  PleinCap
//
//  Created by chaabani achref on 8/8/2025.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case serverError
    case unexpectedStatus(code: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError: return "Failed to decode server response"
        case .unauthorized: return "Unauthorized"
        case .notFound: return "Resource not found"
        case .serverError: return "Server error"
        case .unexpectedStatus(let code): return "Unexpected status code: \(code)"
        }
    }
}

// MARK: - NetworkManager
final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    /// Your FastAPI root (matches routes like `/register`, `/auth/google`, `/me/plan-action`, etc.)
    private let baseURL = "http://127.0.0.1:8000/api/auth"

    // MARK: - Generic request helpers (renamed)
    @discardableResult
    private func performRequest<T: Decodable>(
        _ path: String,
        method: String = "GET",
        token: String? = nil,
        rawBody: Data? = nil,
        decode: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let rawBody { req.httpBody = rawBody }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw NetworkError.invalidResponse }

        switch http.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                #if DEBUG
                if let s = String(data: data, encoding: .utf8) {
                    print("❌ Decoding error for \(path):", error, "\nPayload:\n\(s)")
                }
                #endif
                throw NetworkError.decodingError
            }
        case 401: throw NetworkError.unauthorized
        case 404: throw NetworkError.notFound
        case 500...599: throw NetworkError.serverError
        default: throw NetworkError.unexpectedStatus(code: http.statusCode)
        }
    }

     func performRequest<T: Decodable, E: Encodable>(
        _ path: String,
        method: String = "GET",
        token: String? = nil,
        encodable body: E?,
        decode: T.Type
    ) async throws -> T {
        let bodyData = try body.map { try JSONEncoder().encode($0) }
        return try await performRequest(path, method: method, token: token, rawBody: bodyData, decode: T.self)
    }

    // MARK: - Payloads (renamed/kept)
    struct SignupPayload: Encodable {
        let email: String
        let password: String
        let nom: String
        let prenom: String
        let sexe: String
        let date_naissance: String   // "yyyy-MM-dd"
    }

    struct ConfirmSignupPayload: Encodable {
        let email: String
        let code: String
    }

    struct SigninPayload: Encodable {
        let email: String
        let password: String
    }

    struct GoogleSigninBody: Encodable {
        let token: String
    }

    struct StepCompletionPatch: Encodable {
        let is_done: Bool
    }

    // MARK: - Auth (all renamed)
    /// POST /register -> 202 {message} (we don’t need the payload)
    func signupUser(_ payload: SignupPayload) async throws {
        struct Ack: Decodable { let message: String? }
        _ = try await performRequest("/register", method: "POST", encodable: payload, decode: Ack.self)
    }

    /// POST /verify-registration -> TokenResponse
    func confirmSignup(email: String, code: String) async throws -> TokenResponse {
        let body = ConfirmSignupPayload(email: email, code: code)
        return try await performRequest("/verify-registration", method: "POST", encodable: body, decode: TokenResponse.self)
    }

    /// POST /login -> TokenResponse
    func signinUser(email: String, password: String) async throws -> TokenResponse {
        let body = SigninPayload(email: email, password: password)
        return try await performRequest("/login", method: "POST", encodable: body, decode: TokenResponse.self)
    }

    /// POST /refresh (with current token) -> TokenResponse
    func refreshSession(token: String) async throws -> TokenResponse {
        struct Empty: Encodable {}
        return try await performRequest("/refresh", method: "POST", token: token, encodable: Empty(), decode: TokenResponse.self)
    }

    /// POST /auth/google -> TokenResponse
    func signinWithGoogle(idToken: String) async throws -> TokenResponse {
        let body = GoogleSigninBody(token: idToken)
        return try await performRequest("/auth/google", method: "POST", encodable: body, decode: TokenResponse.self)
    }

    // MARK: - Me (renamed)
    /// GET /me -> UserProfile
    func fetchCurrentUser(token: String) async throws -> UserProfile {
        try await performRequest("/me", token: token, decode: UserProfile.self)
    }

    /// PATCH /me (partial update) -> UserProfile
    /// Provide a dictionary whose keys match backend snake_case (e.g. "niveau_scolaire")
    func updateUserProfile(partial: [String: Any], token: String) async throws -> UserProfile {
        let data = try JSONSerialization.data(withJSONObject: partial, options: [])
        return try await performRequest("/me", method: "PATCH", token: token, rawBody: data, decode: UserProfile.self)
    }

    // MARK: - Plan (renamed)
    /// GET /me/plan-action -> PlanActionResponse
    func fetchUserPlan(token: String) async throws -> PlanActionResponse {
        try await performRequest("/me/plan-action", token: token, decode: PlanActionResponse.self)
    }

    /// GET /users/{userId}/progress -> [UserStepProgressResponse]
    func fetchUserProgress(userId: Int, token: String) async throws -> [UserStepProgressResponse] {
        try await performRequest("/users/\(userId)/progress", token: token, decode: [UserStepProgressResponse].self)
    }

    /// PATCH /users/{userId}/steps/{stepId} { "is_done": Bool } -> UserStepProgressResponse
    func updateStepCompletion(userId: Int, stepId: Int, isDone: Bool, token: String) async throws -> UserStepProgressResponse {
        let body = StepCompletionPatch(is_done: isDone)
        return try await performRequest("/users/\(userId)/steps/\(stepId)", method: "PATCH", token: token, encodable: body, decode: UserStepProgressResponse.self)
    }

    /// POST /users/{userId}/steps/{stepId}/done -> UserStepProgressResponse
    func markStepAsDone(userId: Int, stepId: Int, token: String) async throws -> UserStepProgressResponse {
        struct Empty: Encodable {}
        return try await performRequest("/users/\(userId)/steps/\(stepId)/done", method: "POST", token: token, encodable: Empty(), decode: UserStepProgressResponse.self)
    }
   
}
extension NetworkManager {
       struct ForgotPayload: Encodable { let email: String }
       struct ResetPayload: Encodable { let email: String; let code: String; let new_password: String }
       private struct Ack: Decodable { let message: String? }

       func requestPasswordReset(email: String) async throws {
           _ = try await performRequest("/forgot-password", method: "POST", encodable: ForgotPayload(email: email), decode: Ack.self)
       }

       func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
           _ = try await performRequest("/reset-password", method: "POST", encodable: ResetPayload(email: email, code: code, new_password: newPassword), decode: Ack.self)
       }
   }
