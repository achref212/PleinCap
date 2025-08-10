//
//  AcademieService.swift
//  PleinCap
//
//  Created by chaabani achref on 10/8/2025.
//
import Foundation

enum API {
    static var baseURL: URL {
        if let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let u = URL(string: s) { return u }
        return URL(string: "http://127.0.0.1:8000/api/auth")!
    }
}

struct APIClient {
    var tokenProvider: () -> String? = { nil }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Encodable? = Optional<Never>.none,
        authorized: Bool = false,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var url = API.baseURL
        url.appendPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        guard var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty { comps.queryItems = query }
        guard let finalURL = comps.url else { throw APIError.invalidURL }

        var req = URLRequest(url: finalURL)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            do {
                req.httpBody = try JSONEncoder().encode(AnyEncodable(body)) // ✅ back
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.invalidPayload
            }
        }

        if authorized, let token = tokenProvider() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            throw APIError.serverError
        }
        guard !data.isEmpty else { throw APIError.noData }

        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.decodingError }
    }
}



// MARK: - Directory Service

final class DirectoryService {
    private let client: APIClient

    init(tokenProvider: @escaping () -> String? = { nil }) {
        self.client = APIClient(tokenProvider: tokenProvider)
    }

    func listAcademies() async throws -> [Academie] {
        try await client.request("/academies")
    }

    func getAcademie(id: Int, includeEtablissements: Bool = true) async throws -> Academie {
        let query = includeEtablissements ? [URLQueryItem(name: "with_etablissements", value: "true")] : []
        return try await client.request("/academies/\(id)", query: query)
    }

    func listEtablissements(id: Int) async throws -> [Etablissement] {
        try await client.request("/academies/\(id)/etablissements")
    }

    func listEtablissements() async throws -> [Etablissement] {
        try await client.request("/etablissements")
    }

    func filter(_ etablissements: [Etablissement],
                city: String? = nil,
                track: String? = nil,
                query: String? = nil) -> [Etablissement] {
        etablissements.filter { etab in
            var ok = true
            if let city = city, !city.isEmpty {
                ok = ok && (etab.city?.localizedCaseInsensitiveContains(city) ?? false)
            }
            if let track = track, !track.isEmpty {
                ok = ok && (etab.track?.localizedCaseInsensitiveContains(track) ?? false)
            }
            if let q = query, !q.isEmpty {
                ok = ok && (
                    etab.displayName.localizedCaseInsensitiveContains(q) ||
                    (etab.city?.localizedCaseInsensitiveContains(q) ?? false)
                )
            }
            return ok
        }
    }
}
