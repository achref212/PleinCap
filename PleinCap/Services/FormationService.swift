import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "http://127.0.0.1:8000/api/auth" // Update to your actual server URL
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // Match Pydantic snake_case
        decoder.dateDecodingStrategy = .iso8601 // Handle timestamp
        return decoder
    }()
    
    private var authToken: String? {
        // Placeholder; replace with actual token fetch logic
        return "YOUR_AUTH_TOKEN" // Update with real token or fetch from UserDefaults/Keychain
    }
    func fetchFormationsVoieTechnologique(completion: @escaping (Result<[Formation], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/voie_technologique") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
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
    func fetchFormations(skip: Int = 0, limit: Int = 10, completion: @escaping (Result<[Formation], Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(baseURL)/formations")!
        urlComponents.queryItems = [
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NetworkService: Fetch formations error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("NetworkService: No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            // Log raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("NetworkService: Raw response - \(jsonString)")
            }
            
            do {
                let formations = try self.jsonDecoder.decode([Formation].self, from: data)
                print("NetworkService: Decoded \(formations.count) formations")
                completion(.success(formations))
            } catch {
                print("NetworkService: Decoding error - \(error.localizedDescription)")
                // Print detailed error if possible
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Decoding error context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found, context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type \(type) not found, context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for \(type), context: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchFormation(id: Int, completion: @escaping (Result<Formation, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/formations/\(id)")!
        
        var request = URLRequest(url: url)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NetworkService: Fetch formation \(id) error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("NetworkService: No data for formation \(id)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("NetworkService: Raw response for formation \(id) - \(jsonString)")
            }
            
            do {
                let formation = try self.jsonDecoder.decode(Formation.self, from: data)
                print("NetworkService: Decoded formation \(id)")
                completion(.success(formation))
            } catch {
                print("NetworkService: Decoding error for formation \(id) - \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Decoding error context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found, context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type \(type) not found, context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for \(type), context: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
