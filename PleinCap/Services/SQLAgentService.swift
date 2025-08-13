//
//  SQLAgentService.swift
//  PleinCap
//
//  Option A (Existing Postgres via Node .env)
//  LangGraph input shape: { assistant_id, input: { question, uuid } }
//

import Foundation

// MARK: - Public Config

public struct SQLAgentConfig {
    public var nodeCandidates: [URL]
    public var langGraphCandidates: [URL]
    public var assistantID: String   // e.g. "my_agent"

    public init(nodeCandidates: [String], langGraphCandidates: [String], assistantID: String = "my_agent") {
        self.nodeCandidates = nodeCandidates.compactMap(URL.init(string:))
        self.langGraphCandidates = langGraphCandidates.compactMap(URL.init(string:))
        self.assistantID = assistantID
    }

    /// Defaults for Simulator. On device, pass your Mac LAN IP (e.g., "192.168.1.50").
    public static func `default`(assistantID: String = "my_agent", deviceLAN: String? = nil) -> SQLAgentConfig {
        var node = ["http://127.0.0.1:3001", "http://localhost:3001"]
        var lg   = ["http://127.0.0.1:2024", "http://localhost:2024"]
        if let ip = deviceLAN {
            node.insert("http://\(ip):3001", at: 0)
            lg.insert("http://\(ip):2024", at: 0)
        }
        return .init(nodeCandidates: node, langGraphCandidates: lg, assistantID: assistantID)
    }
}

// MARK: - Public Models

public enum JSONValue: Decodable {
    case string(String), number(Double), bool(Bool), object([String: JSONValue]), array([JSONValue]), null
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let b = try? c.decode(Bool.self) { self = .bool(b) }
        else if let d = try? c.decode(Double.self) { self = .number(d) }
        else if let s = try? c.decode(String.self) { self = .string(s) }
        else if let a = try? c.decode([JSONValue].self) { self = .array(a) }
        else if let o = try? c.decode([String: JSONValue].self) { self = .object(o) }
        else { throw DecodingError.dataCorrupted(.init(codingPath: c.codingPath, debugDescription: "Unsupported JSON")) }
    }
}

public struct ExecuteQueryResponse: Decodable {
    public let results: [[JSONValue]]?
    public let message: String?
    public let changes: Int?
}

// MARK: - Service

public actor SQLAgentService {

    // MARK: Errors

    public enum ServiceError: LocalizedError {
        case noReachableNode([URL])
        case noReachableLangGraph([URL])
        case badStatus(Int, String)
        case decodeFailed(String, String)
        case emptyAnswer
        public var errorDescription: String? {
            switch self {
            case .noReachableNode(let c):
                return "Node server not reachable. Tried: " + c.map(\.absoluteString).joined(separator: ", ")
            case .noReachableLangGraph(let c):
                return "LangGraph server not reachable. Tried: " + c.map(\.absoluteString).joined(separator: ", ")
            case .badStatus(let code, let body):
                return "HTTP \(code): \(body)"
            case .decodeFailed(let why, let payload):
                return "Decode failed: \(why)\nPayload:\n\(payload)"
            case .emptyAnswer:
                return "Empty answer from agent"
            }
        }
    }

    // MARK: Init + timeouts

    private let cfg: SQLAgentConfig
    private let session: URLSession

    /// Short per-request timeout used for pings/health checks.
    private let pingTimeout: TimeInterval
    /// Long per-request timeout used for `ask` (LangGraph).
    private let askTimeout: TimeInterval
    /// Medium per-request timeout used for SQL.
    private let sqlTimeout: TimeInterval
    /// Session-wide resource timeout (must be >= the longest request you plan).
    private let resourceTimeout: TimeInterval

    private let datasetUUID = "default" // Option A — Node .env pool
    private var nodeOK: URL?
    private var lgOK: URL?

    /// Defaults: ping=8s, ask=360s, sql=180s, resource=600s.
    public init(config: SQLAgentConfig,
                pingTimeout: TimeInterval = 12,
                askTimeout: TimeInterval = 600,
                sqlTimeout: TimeInterval = 300,
                resourceTimeout: TimeInterval = 1200) {
        self.cfg = config
        self.pingTimeout = pingTimeout
        self.askTimeout = askTimeout
        self.sqlTimeout = sqlTimeout
        self.resourceTimeout = max(resourceTimeout, max(askTimeout, sqlTimeout))

        let sc = URLSessionConfiguration.ephemeral
        sc.timeoutIntervalForRequest = 60               // base; overridden per request
        sc.timeoutIntervalForResource = self.resourceTimeout
        sc.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: sc)
    }

    // MARK: Connectivity

    @discardableResult
    public func connect() async throws -> (node: URL, langGraph: URL) {
        if nodeOK == nil { nodeOK = try await firstReachableNode() }
        if lgOK == nil   { lgOK   = try await firstReachableLG() }
        return (nodeOK!, lgOK!)
    }

    private func firstReachableNode() async throws -> URL {
        for base in cfg.nodeCandidates {
            let url = base.appendingPathComponent("get-schema/\(datasetUUID)")
            do {
                _ = try await sendRaw(to: url, method: "GET", body: Optional<String>.none, tolerateAllStatus: false, timeout: pingTimeout)
                return base
            } catch { /* try next */ }
        }
        throw ServiceError.noReachableNode(cfg.nodeCandidates)
    }

    private func firstReachableLG() async throws -> URL {
        for base in cfg.langGraphCandidates {
            if await tryAskPing(base) { return base }
        }
        throw ServiceError.noReachableLangGraph(cfg.langGraphCandidates)
    }

    /// Ping LangGraph by POSTing to /runs/wait with tiny payload.
    /// Any status < 500 counts as reachable (422/400 are fine).
    private func tryAskPing(_ base: URL) async -> Bool {
        struct LGInput: Encodable { let question: String; let uuid: String }
        struct Body: Encodable { let assistant_id: String; let input: LGInput }
        let body = Body(assistant_id: cfg.assistantID,
                        input: LGInput(question: "ping", uuid: datasetUUID))
        let url = base.appendingPathComponent("runs/wait")
        do {
            let (_, http) = try await sendRaw(to: url, method: "POST", body: body, tolerateAllStatus: true, timeout: pingTimeout)
            return http.statusCode < 500
        } catch {
            return false
        }
    }

    // MARK: Public API

    /// Ask your LangGraph agent a question. (Long timeout by default)
    public func ask(_ question: String) async throws -> String {
        try await connect()
        guard let lg = lgOK else { throw ServiceError.noReachableLangGraph(cfg.langGraphCandidates) }

        struct LGInput: Encodable { let question: String; let uuid: String }
        struct Body: Encodable { let assistant_id: String; let input: LGInput }
        let body = Body(assistant_id: cfg.assistantID,
                        input: LGInput(question: question, uuid: datasetUUID))

        let url = lg.appendingPathComponent("runs/wait")
        let (data, _) = try await sendRaw(to: url, method: "POST", body: body, tolerateAllStatus: false, timeout: askTimeout)

        // Typical shapes: { values.final_text } or { message }, else fallback to raw.
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let values = obj["values"] as? [String: Any],
               let final = values["final_text"] as? String,
               !final.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return final }
            if let msg = obj["message"] as? String,
               !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return msg }
            if let msgs = obj["messages"] as? [[String: Any]],
               let lastAI = msgs.last(where: { ($0["role"] as? String)?.lowercased() == "ai" }),
               let content = lastAI["content"] as? String,
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return content }
        }
        let raw = String(data: data, encoding: .utf8) ?? ""
        guard !raw.isEmpty else { throw ServiceError.emptyAnswer }
        return raw
    }

    /// Execute raw SQL through your Node server (uses the default .env pool).
    public func executeSQL(_ sql: String) async throws -> ExecuteQueryResponse {
        try await connect()
        guard let node = nodeOK else { throw ServiceError.noReachableNode(cfg.nodeCandidates) }

        struct Body: Encodable { let uuid: String; let query: String }
        let url = node.appendingPathComponent("execute-query")
        let (data, _) = try await sendRaw(to: url, method: "POST", body: Body(uuid: datasetUUID, query: sql), tolerateAllStatus: false, timeout: sqlTimeout)
        do {
            return try JSONDecoder().decode(ExecuteQueryResponse.self, from: data)
        } catch {
            let payload = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            throw ServiceError.decodeFailed(error.localizedDescription, payload)
        }
    }

    /// Fetch a human-readable schema preview from your Node server (great for debugging).
    public func schemaPreview() async throws -> String {
        try await connect()
        guard let node = nodeOK else { throw ServiceError.noReachableNode(cfg.nodeCandidates) }
        let url = node.appendingPathComponent("get-schema/\(datasetUUID)")
        let (data, resp) = try await sendRaw(to: url, method: "GET", body: Optional<String>.none, tolerateAllStatus: false, timeout: 20)
        guard (200..<300).contains(resp.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ServiceError.badStatus(resp.statusCode, body)
        }
        struct S: Decodable { let schema: String }
        return try JSONDecoder().decode(S.self, from: data).schema
    }

    // MARK: - HTTP helper

    /// Send JSON with a per-request timeout (overrides session’s request timeout).
    private func sendRaw(to url: URL,
                         method: String,
                         body: Encodable?,
                         tolerateAllStatus: Bool,
                         timeout: TimeInterval) async throws -> (Data, HTTPURLResponse) {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = timeout  // ⬅️ per-request timeout
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(AnyEncodable1(body))
        }
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw ServiceError.badStatus(-1, "No HTTPURLResponse")
        }
        if !tolerateAllStatus && !(200..<300).contains(http.statusCode) {
            let txt = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            throw ServiceError.badStatus(http.statusCode, txt)
        }
        return (data, http)
    }
}

// MARK: - Tiny type-erased encoder

private struct AnyEncodable1: Encodable {
    private let enc: (Encoder) throws -> Void
    init(_ base: Encodable) { self.enc = base.encode }
    func encode(to encoder: Encoder) throws { try enc(encoder) }
}
