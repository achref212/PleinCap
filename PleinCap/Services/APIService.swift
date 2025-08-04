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
    
    func getUserPlan(token: String, completion: @escaping (Result<PlanActionData, Error>) -> Void) {
           guard let url = URL(string: baseURL + "/me/plan-action") else {
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

               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(APIError.noData))
                   return
               }

               switch httpResponse.statusCode {
               case 200...299:
                   guard let data = data else {
                       completion(.failure(APIError.noData))
                       return
                   }
                   do {
                       let decoded = try JSONDecoder().decode(PlanActionData.self, from: data)
                       completion(.success(decoded))
                   } catch {
                       completion(.failure(APIError.decodingError))
                   }
               case 401:
                   completion(.failure(APIError.unauthorized))
               case 404:
                   completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Plan action not found"])))
               case 500...599:
                   completion(.failure(APIError.serverError))
               default:
                   completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])))
               }
           }.resume()
       }

       func updateUserLocation(_ locationData: LocationData, token: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
           guard let url = URL(string: baseURL + "/me/location") else {
               completion(.failure(APIError.invalidURL))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "PATCH"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

           do {
               let body = try JSONEncoder().encode(locationData)
               request.httpBody = body
           } catch {
               completion(.failure(error))
               return
           }

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(APIError.noData))
                   return
               }

               switch httpResponse.statusCode {
               case 200...299:
                   guard let data = data else {
                       completion(.failure(APIError.noData))
                       return
                   }
                   do {
                       let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
                       completion(.success(decoded))
                   } catch {
                       completion(.failure(APIError.decodingError))
                   }
               case 401:
                   completion(.failure(APIError.unauthorized))
               case 404:
                   completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Location not found"])))
               case 500...599:
                   completion(.failure(APIError.serverError))
               default:
                   completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])))
               }
           }.resume()
       }
    // Update user's moyenne data (POST)
        func updateUserMoyenne(_ moyenneData: MoyenneData, token: String, completion: @escaping (Result<MoyenneData, Error>) -> Void) {
            guard let url = URL(string: baseURL + "/me/moyenne") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            do {
                let body = try JSONEncoder().encode(moyenneData)
                request.httpBody = body
            } catch {
                completion(.failure(error))
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.noData))
                    return
                }

                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        completion(.failure(APIError.noData))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(MoyenneData.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(APIError.decodingError))
                    }
                case 401:
                    completion(.failure(APIError.unauthorized))
                case 500...599:
                    completion(.failure(APIError.serverError))
                default:
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])))
                }
            }.resume()
        }

        // Get user's moyenne data (GET)
        func getUserMoyenne(token: String, completion: @escaping (Result<MoyenneData, Error>) -> Void) {
            guard let url = URL(string: baseURL + "/me/moyenne") else {
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

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.noData))
                    return
                }

                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        completion(.failure(APIError.noData))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(MoyenneData.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(APIError.decodingError))
                    }
                case 401:
                    completion(.failure(APIError.unauthorized))
                case 404:
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Moyenne not found"])))
                case 500...599:
                    completion(.failure(APIError.serverError))
                default:
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])))
                }
            }.resume()
        }

        // Update existing moyenne data (PATCH)
        func updateExistingMoyenne(_ moyenneData: MoyenneData, token: String, completion: @escaping (Result<MoyenneData, Error>) -> Void) {
            guard let url = URL(string: baseURL + "/me/moyenne") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            do {
                let body = try JSONEncoder().encode(moyenneData)
                request.httpBody = body
            } catch {
                completion(.failure(error))
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.noData))
                    return
                }

                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        completion(.failure(APIError.noData))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(MoyenneData.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(APIError.decodingError))
                    }
                case 401:
                    completion(.failure(APIError.unauthorized))
                case 404:
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Moyenne not found"])))
                case 500...599:
                    completion(.failure(APIError.serverError))
                default:
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected status code"])))
                }
            }.resume()
        }
}

enum APIError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError
    case unauthorized
    case serverError
}
