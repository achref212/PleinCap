// RecommendationsViewModel.swift
import Foundation
import SwiftUI

enum SQLAgentRecoPrompt {

    /// ✅ Simple, chat-like prompt (what you asked for)
    static func simple(userID: Int, topK: Int) -> String {
        """
        Je veux \(topK) recommandations de formations pour l’utilisateur id=\(userID).
        Utilise UNIQUEMENT les données de cet utilisateur : spécialités, voie, filière, budget, académie/localisation,
        établissement, niveau, notes, préférences (training_types, job_sectors, formation_domains)
        """
    }

    /// More guided version (used only on retry if the simple one fails)
//    static func french(userID: Int, topK: Int) -> String {
//        """
//        Je veux une recommandation personnalisée pour moi (id utilisateur = \(userID)).
//
//        Objectif : propose-moi les \(topK) formations les plus pertinentes.
//
//        Schéma utile :
//        - "user" (id, specialites JSON[], notes JSON[], voie, filiere, orientation_choices JSON, budget, academie, est_boursier, …)
//        - "formations" (id, titre, resume_programme, type_formation, etablissement, prix_annuel, …)
//        - "matieres_enseignees" (formation_id, matiere)
//        - "debouches_secteurs" (formation_id, secteur)
//
//        RÈGLES JSON :
//        - user.* (JSON) → json_array_elements_text(<json>) ou (<json>::jsonb + jsonb_array_elements_text(...))
//        - PAS de DISTINCT direct sur colonnes JSON. Si besoin, caster en texte.
//        - Colonnes TEXT qui contiennent du JSON → NULLIF(col,'[]')::jsonb + jsonb_array_elements_text(...)
//
//        Contraintes de sortie :
//        - 1 seule instruction SELECT (CTE WITH autorisé). Pas de DDL ni multi-statements. Aucune ellipse.
//        - 1ère colonne: formation_id (= f.id).
//        - ORDER BY meilleure pertinence, LIMIT \(topK).
//
//        Réponds UNIQUEMENT par le SQL dans:
//        ```sql
//        SELECT ... ;
//        ```
//        """
//    }

//    static func frenchRetry(userID: Int, topK: Int, errorHint: String) -> String {
//        """
//        La requête précédente a échoué :
//
//        \(errorHint)
//
//        Regénère UNE requête SQL PostgreSQL CORRECTE en respectant STRICTEMENT :
//        - 0 ellipse « … »
//        - 1 seule instruction SELECT (CTE WITH autorisé)
//        - 1ère colonne: formation_id (= f.id)
//        - JSON: json_array_elements_text(<json>) ou (<json>::jsonb + jsonb_array_elements_text(...))
//        - TEXT contenant JSON: NULLIF(col,'[]')::jsonb + jsonb_array_elements_text(...)
//        - Pas de DISTINCT direct sur JSON
//        - LIMIT \(topK)
//
//        Réponds UNIQUEMENT par:
//        ```sql
//        SELECT ... ;
//        ```
//        """
//    }
}

@MainActor
final class RecommendationsViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var errorMessage: ErrorMessage? = nil

    @Published var recommendedIDs: [Int] = []     // ordered IDs for your list
    @Published var lastAnswerText: String? = nil  // raw agent text
    @Published var lastSQL: String? = nil         // final SQL used

    private let service: SQLAgentService

    init(service: SQLAgentService) {
        self.service = service
    }

    // MARK: - Connectivity

    func connect() async {
        do {
            _ = try await service.connect()
            isConnected = true
            errorMessage = nil
        } catch {
            isConnected = false
            errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }

    // MARK: - Entry point

    /// Simple chat-like call. You can pass just (userID, topK) like your UI already does.
    func recommendForUser(userID: Int, topK: Int) async {
        await recommendForUser(userID: userID, topK: topK, simplePrompt: true)
    }

    /// If you ever want to force the stricter prompt from the UI, set simplePrompt = false.
    func recommendForUser(userID: Int, topK: Int, simplePrompt: Bool) async {
        guard !isLoading else { return }
        if !isConnected { await connect(); if !isConnected { return } }

        isLoading = true
        errorMessage = nil
        lastAnswerText = nil
        lastSQL = nil
        recommendedIDs.removeAll()

        do {
            try await runOnce(userID: userID, topK: topK, simple: simplePrompt) // simple prompt first
        } catch {
            let err1 = error.localizedDescription
            if shouldRetry(for: err1) {
                do {
                    // Retry with the guided prompt using the last error as a hint
                    try await runOnce(userID: userID, topK: topK, simple: false, errorHint: err1)
                } catch {
                    // Final safety: fallback SQL we know works with your schema
                    do {
                        try await runFallback(userID: userID, topK: topK)
                    } catch {
                        self.errorMessage = ErrorMessage(message: error.localizedDescription)
                    }
                }
            } else {
                // Not retryable → go straight to fallback
                do {
                    try await runFallback(userID: userID, topK: topK)
                } catch {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }

        isLoading = false
    }

    // MARK: - One attempt (ask → extract SQL → execute → parse IDs)

    private func runOnce(userID: Int, topK: Int, simple: Bool, errorHint: String? = nil) async throws {
        let prompt: String
        if let hint = errorHint {
            prompt = SQLAgentRecoPrompt.simple(userID: userID, topK: topK)
        } else {
            prompt = simple
                ? SQLAgentRecoPrompt.simple(userID: userID, topK: topK)
                : SQLAgentRecoPrompt.simple(userID: userID, topK: topK)
        }

        let answer = try await service.ask(prompt)
        self.lastAnswerText = answer

        guard let sql = Self.extractSQL(from: answer) ?? Self.fallbackExtractSQL(from: answer) else {
            throw NSError(domain: "Reco", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Aucune requête SQL trouvée dans la réponse."])
        }
        guard !sql.contains("..") && !sql.contains("…") else {
            throw NSError(domain: "Reco", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "La requête SQL contient des ellipses (« … »)."])
        }
        self.lastSQL = sql

        let resp = try await service.executeSQL(sql)
        let ids = Self.parseFirstColumnIDs(from: resp)
        guard !ids.isEmpty else {
            throw NSError(domain: "Reco", code: -3,
                          userInfo: [NSLocalizedDescriptionKey: "Résultat vide (aucune formation recommandée)."])
        }
        self.recommendedIDs = ids
    }

    // MARK: - Known-good fallback SQL (no jsonb dependency)

    private func buildFallbackSQL(userID: Int, topK: Int) -> String {
        """
        WITH u AS (
          SELECT id, orientation_choices, specialites, budget
          FROM "user"
          WHERE id = \(userID)
        ),
        tt AS (
          SELECT lower(trim(value)) AS v
          FROM u, LATERAL json_array_elements_text(u.orientation_choices->'training_types') AS value
        ),
        fd AS (
          SELECT lower(trim(value)) AS v
          FROM u, LATERAL json_array_elements_text(u.orientation_choices->'formation_domains') AS value
        ),
        js AS (
          SELECT lower(trim(value)) AS v
          FROM u, LATERAL json_array_elements_text(u.orientation_choices->'job_sectors') AS value
        ),
        us AS (
          SELECT lower(trim(value)) AS v
          FROM u, LATERAL json_array_elements_text(u.specialites) AS value
        )
        SELECT
          f.id AS formation_id,
          f.titre,
          (
            COALESCE((SELECT COUNT(*) FROM tt WHERE lower(trim(f.type_formation)) = tt.v), 0)
            +
            COALESCE((
              SELECT COUNT(*) FROM fd
              JOIN "matieres_enseignees" me
                ON lower(trim(me.matiere)) = fd.v
              WHERE me.formation_id = f.id
            ), 0)
            +
            COALESCE((
              SELECT COUNT(*) FROM js
              JOIN "debouches_secteurs" ds
                ON lower(trim(ds.secteur)) = js.v
              WHERE ds.formation_id = f.id
            ), 0)
            +
            COALESCE((
              SELECT COUNT(*) FROM us
              JOIN "specialites_favorisees" sf
                ON sf.formation_id = f.id
               AND lower(trim(sf.specialite)) = us.v
            ), 0)
          ) AS score
        FROM "formations" f
        WHERE
          f.titre IS NOT NULL AND f.titre <> '' AND f.titre <> 'N/A'
          AND f.etablissement IS NOT NULL AND f.etablissement <> '' AND f.etablissement <> 'N/A'
          AND (
            f.prix_annuel IS NULL
            OR (SELECT NULLIF(trim(budget), '') FROM u) IS NULL
            OR f.prix_annuel <= (SELECT NULLIF(trim(budget), '')::double precision FROM u)
          )
        ORDER BY score DESC NULLS LAST, f.id
        LIMIT \(topK);
        """
    }

    private func runFallback(userID: Int, topK: Int) async throws {
        let sql = buildFallbackSQL(userID: userID, topK: topK)
        self.lastSQL = sql
        let resp = try await service.executeSQL(sql)
        let ids = Self.parseFirstColumnIDs(from: resp)
        guard !ids.isEmpty else {
            throw NSError(domain: "Reco", code: -4,
                          userInfo: [NSLocalizedDescriptionKey: "Fallback SQL a renvoyé 0 ligne."])
        }
        self.recommendedIDs = ids
    }

    // MARK: - Retry heuristic

    private func shouldRetry(for error: String) -> Bool {
        let lower = error.lowercased()
        return lower.contains("jsonb_array_elements_text(json) does not exist")
            || lower.contains("function jsonb_array_elements_text")
            || lower.contains("could not identify an equality operator for type json")
            || lower.contains("syntax error at or near \"..\"")
            || lower.contains("syntax error at or near '…'")
            || lower.contains("unterminated")
            || lower.contains("bad request")
    }

    // MARK: - Utils

    private static func extractSQL(from text: String) -> String? {
        if let s = firstMatch(in: text, pattern: #"```sql\s*([\s\S]*?)```"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let s = firstMatch(in: text, pattern: #"```\s*([\s\S]*?)```"#)     { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let s = firstMatch(in: text, pattern: #"(?is)\bSELECT\b[\s\S]*?;"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        return nil
    }

    private static func fallbackExtractSQL(from text: String) -> String? {
        if let s = firstMatch(in: text, pattern: #"(?is)\bSELECT\b[\s\S]*"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        return nil
    }

    private static func firstMatch(in text: String, pattern: String) -> String? {
        (try? NSRegularExpression(pattern: pattern)).flatMap { re in
            let range = NSRange(text.startIndex..., in: text)
            guard let m = re.firstMatch(in: text, options: [], range: range),
                  m.numberOfRanges >= 2,
                  let r = Range(m.range(at: 1), in: text) else { return nil }
            return String(text[r])
        }
    }

    private static func parseFirstColumnIDs(from resp: ExecuteQueryResponse) -> [Int] {
        guard let rows = resp.results, !rows.isEmpty else { return [] }
        var ids: [Int] = []; ids.reserveCapacity(rows.count)
        for row in rows {
            guard let first = row.first else { continue }
            switch first {
            case .number(let d): ids.append(Int(d))
            case .string(let s): if let v = Int(s) { ids.append(v) }
            default: break
            }
        }
        return ids
    }
}
