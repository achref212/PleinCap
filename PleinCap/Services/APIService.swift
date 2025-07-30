//
//  APIService.swift
//  PFE_APP
//
//  Created by chaabani achref on 21/5/2025.
//
// APIService.swift
import Foundation
import UIKit
import GoogleSignIn

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8000/api/auth"

    private init() {}

    func postRequest(path: String, body: [String: Any], token: String? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getRequest(path: String, token: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            completion(.success(data))
        }.resume()
    }
    func updateUserProfile(updatedData: [String: Any], token: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: baseURL + "/me") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updatedData)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func patchRequest(path: String, body: [String: Any], token: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            return completion(.failure(APIError.invalidURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                return completion(.failure(APIError.invalidResponse))
            }

            completion(.success(data))
        }.resume()
    }
   
    func loginWithGoogle(googleAccessToken: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: baseURL + "/auth/google") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": googleAccessToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum APIError: Error {
    case invalidURL
    case noData
    case invalidResponse
}
