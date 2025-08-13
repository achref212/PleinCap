//
//  ChatbotViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 12/8/2025.
//
import Foundation
import SwiftUI

public struct ChatMessage1: Identifiable, Equatable {
    public enum Role { case user, ai, system }
    public let id = UUID()
    public let role: Role
    public var text: String
    public var sql: String? = nil
    public var rows: [[String]]? = nil
}

@MainActor
final class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatMessage1] = []
    @Published var input: String = ""
    @Published var isSending = false
    @Published var isExecutingSQL = false
    @Published var lastError: String? = nil
    @Published var autoRunSQL = false
    @Published var isConnected = false

    private let service: SQLAgentService

    init(service: SQLAgentService) {
        self.service = service
    }

    /// Call this on appear. It pings Node + LangGraph and prints which base URLs were selected.
    func connect(showSchema: Bool = false) async {
        do {
            let (node, lg) = try await service.connect()
            isConnected = true
            messages.append(.init(role: .system, text: "🔌 Connected.\nNode: \(node.absoluteString)\nLangGraph: \(lg.absoluteString)"))
            if showSchema {
                let schema = try await service.schemaPreview()
                messages.append(.init(role: .system, text: "📚 Schema (default):\n\(schema)"))
            }
        } catch {
            isConnected = false
            lastError = error.localizedDescription
            messages.append(.init(role: .system, text: "❌ \(error.localizedDescription)"))
        }
    }

    func clear() {
        messages.removeAll()
        lastError = nil
    }

    func send() async {
        let q = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        await send(text: q)
    }

    func send(text: String) async {
        messages.append(.init(role: .user, text: text))
        input = ""
        lastError = nil
        isSending = true

        do {
            let answer = try await service.ask(text)
            var aiMsg = ChatMessage1(role: .ai, text: answer)
            if let sql = extractSQL(from: answer) { aiMsg.sql = sql }
            messages.append(aiMsg)
            isSending = false

            if autoRunSQL, let sql = aiMsg.sql {
                await runSQL(sql, attachToMessageWithID: aiMsg.id)
            }
        } catch {
            isSending = false
            lastError = error.localizedDescription
            messages.append(.init(role: .system, text: "❌ \(error.localizedDescription)"))
        }
    }

    func runSQL(_ sql: String, attachToMessageWithID mid: UUID? = nil) async {
        let clean = sql.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        isExecutingSQL = true
        lastError = nil
        do {
            let resp = try await service.executeSQL(clean)
            let flat = stringifyResults(resp)
            if let idx = messages.firstIndex(where: { $0.id == mid }) {
                var m = messages[idx]; m.rows = flat; messages[idx] = m
            } else {
                var text = "✅ SQL executed."
                if flat.isEmpty { text += " (No rows)" }
                messages.append(.init(role: .system, text: text, sql: clean, rows: flat))
            }
        } catch {
            lastError = error.localizedDescription
            messages.append(.init(role: .system, text: "❌ SQL error: \(error.localizedDescription)"))
        }
        isExecutingSQL = false
    }

    // MARK: helpers

    private func extractSQL(from text: String) -> String? {
        if let s = firstMatch(in: text, pattern: #"```sql\s*([\s\S]*?)```"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let s = firstMatch(in: text, pattern: #"```\s*([\s\S]*?)```"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let s = firstMatch(in: text, pattern: #"(?is)\b(SELECT|INSERT|UPDATE|DELETE)\b[\s\S]*?;"#) { return s.trimmingCharacters(in: .whitespacesAndNewlines) }
        return nil
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        (try? NSRegularExpression(pattern: pattern)).flatMap { re in
            let range = NSRange(text.startIndex..., in: text)
            guard let m = re.firstMatch(in: text, options: [], range: range),
                  m.numberOfRanges >= 2,
                  let r = Range(m.range(at: 1), in: text) else { return nil }
            return String(text[r])
        }
    }

    private func stringifyResults(_ resp: ExecuteQueryResponse) -> [[String]] {
        guard let rows = resp.results, !rows.isEmpty else {
            if let msg = resp.message, !msg.isEmpty { return [[msg]] }
            if let changes = resp.changes { return [["\(changes) row(s) affected"]] }
            return []
        }
        return rows.map { $0.map(string) }
    }

    private func string(_ v: JSONValue) -> String {
        switch v {
        case .string(let s): return s
        case .number(let d): return floor(d) == d ? String(Int(d)) : String(d)
        case .bool(let b):   return b ? "true" : "false"
        case .object(let o):
            if let d = try? JSONSerialization.data(withJSONObject: o.mapValues(any), options: [.sortedKeys]),
               let s = String(data: d, encoding: .utf8) { return s }
            return "{…}"
        case .array(let a):
            if let d = try? JSONSerialization.data(withJSONObject: a.map(any), options: []),
               let s = String(data: d, encoding: .utf8) { return s }
            return "[…]"
        case .null: return "NULL"
        }
    }

    private func any(_ v: JSONValue) -> Any {
        switch v {
        case .string(let s): return s
        case .number(let d): return floor(d) == d ? Int(d) : d
        case .bool(let b):   return b
        case .object(let o): return o.mapValues(any)
        case .array(let a):  return a.map(any)
        case .null:          return NSNull()
        }
    }
}
