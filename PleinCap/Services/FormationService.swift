//
//  FormationService.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import Foundation
class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://127.0.0.1:8000/api/auth" // Update to your server URL
    private let jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Match Pydantic snake_case
            return decoder
        }()
    func fetchFormations(skip: Int = 0, limit: Int = 10, completion: @escaping (Result<[Formation], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/formations/?skip=\(skip)&limit=\(limit)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let formations = try JSONDecoder().decode([Formation].self, from: data)
                completion(.success(formations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchFormation(id: Int, completion: @escaping (Result<Formation, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/formations/\(id)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let formation = try JSONDecoder().decode(Formation.self, from: data)
                completion(.success(formation))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func fetchEtablissements(skip: Int = 0, limit: Int = 10, token: String? = nil, completion: @escaping (Result<[Etablissement], Error>) -> Void) {
            guard var urlComponents = URLComponents(string: "\(baseURL)/etablissements/") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            urlComponents.queryItems = [
                URLQueryItem(name: "skip", value: "\(skip)"),
                URLQueryItem(name: "limit", value: "\(min(limit, 10))")
            ]
            guard let url = urlComponents.url else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            var request = URLRequest(url: url)
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }
                do {
                    let etablissements = try self.jsonDecoder.decode([Etablissement].self, from: data)
                    completion(.success(etablissements))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }

        // Fetch academies
        func fetchAcademies(skip: Int = 0, limit: Int = 10, token: String? = nil, completion: @escaping (Result<[Academie], Error>) -> Void) {
            guard var urlComponents = URLComponents(string: "\(baseURL)/lieu/academies/") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            urlComponents.queryItems = [
                URLQueryItem(name: "skip", value: "\(skip)"),
                URLQueryItem(name: "limit", value: "\(min(limit, 10))")
            ]
            guard let url = urlComponents.url else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            var request = URLRequest(url: url)
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }
                do {
                    let academies = try self.jsonDecoder.decode([Academie].self, from: data)
                    completion(.success(academies))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}
