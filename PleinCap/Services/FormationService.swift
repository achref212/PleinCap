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
}
