//
//  LoukiChatbotView.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI

struct LoukiSQLChatbotView: View {
    // MARK: – ViewModels
    @StateObject private var vm: ChatbotViewModel
    @StateObject private var formationVM = FormationViewModel()   // keep your existing one

    // Map AI message → suggested formations (optional feature)
    @State private var suggestionsForMessage: [UUID: [Formation]] = [:]

    // UI state
    @State private var userInput: String = ""
    @State private var isLoadingBubble: Bool = false

    // MARK: – Init with service config (safe: no self capture)
    /// On a real iPhone, pass your Mac LAN IP, e.g. deviceLAN: "192.168.1.50"
    /// Assistant id defaults to "my_agent" to match your LangGraph.
    init(deviceLAN: String? = nil, assistantID: String = "my_agent") {
        let cfg = SQLAgentConfig.default(assistantID: assistantID, deviceLAN: deviceLAN)
        let service = SQLAgentService(config: cfg)
        _vm = StateObject(wrappedValue: ChatbotViewModel(service: service))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header (Louki style)
                header
                Divider()

                // Optional: connection/error banner
                if !vm.isConnected || vm.lastError != nil {
                    HStack(spacing: 8) {
                        Image(systemName: vm.lastError == nil ? "wifi" : "xmark.octagon.fill")
                            .foregroundColor(vm.lastError == nil ? .accentColor : .red)
                        Text(vm.lastError ?? "Connexion en cours…")
                            .foregroundColor(.primary)
                            .font(.subheadline)
                            .lineLimit(2)
                        Spacer()
                        Button("Réessayer") {
                            Task { await vm.connect(showSchema: false) }
                        }
                        .font(.footnote)
                    }
                    .padding(8)
                    .background(Color.yellow.opacity(0.25))
                }

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            // First system message (Louki hello)
                            helloCard

                            // All conversation messages from ChatbotViewModel
                            ForEach(vm.messages) { message in
                                messageRow(message)
                                    .id(message.id)

                                // Optional: formation suggestions for this AI message
                                if let list = suggestionsForMessage[message.id], !list.isEmpty {
                                    suggestionList(list)
                                        .padding(.horizontal)
                                }
                            }

                            // Loader bubble while waiting for AI
                            if isLoadingBubble {
                                aiLoaderBubble
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: vm.messages.count) { _ in
                        withAnimation {
                            if let last = vm.messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                Divider()
                composer
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Louki Chat")
            .task {
                // Connect to servers (Node + LangGraph) and show schema if you want
                await vm.connect(showSchema: false)
                // Preload formations to fill the cache (optional)
                formationVM.fetchFormations()
            }
            .alert(item: $formationVM.errorMessage) { error in
                Alert(title: Text("Erreur"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: – Header

    private var header: some View {
        HStack(spacing: 12) {
            Image("Louki")
                .resizable()
                .frame(width: 65, height: 65)

            VStack(alignment: .leading, spacing: 4) {
                Text("Louki")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#1D2B4F"))
                Text("Assistant d'orientation")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }

            Spacer()

            Toggle("Auto-run SQL", isOn: $vm.autoRunSQL)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        .padding()
    }

    private var helloCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Image("Louki")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .padding(.bottom, 4)

                Text("Bonjour 👋 Je suis Louki, ton assistant SQL/Orientation. Pose-moi une question sur tes données ou demande une formation.")
                    .foregroundColor(.gray)
                    .padding(12)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(20)
                    .frame(maxWidth: 260, alignment: .leading)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: – Message bubble rows

    private func messageRow(_ msg: ChatMessage1) -> some View {
        HStack(alignment: .top) {
            if msg.role == .user {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .padding(.bottom, 4)
                    Text(msg.text)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .frame(maxWidth: 260, alignment: .trailing)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Image("Louki")
                        .resizable()
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                        .padding(.bottom, 4)

                    // AI/System bubble
                    Text(msg.text)
                        .foregroundColor(.gray)
                        .padding(12)
                        .background(msg.role == .ai ? Color.cyan.opacity(0.1) : Color.yellow.opacity(0.15))
                        .cornerRadius(20)
                        .frame(maxWidth: 260, alignment: .leading)

                    // If AI proposed SQL, show block + run button
                    if msg.role == .ai, let sql = msg.sql {
                        sqlBlock(sql: sql, messageID: msg.id)
                    }

                    // If we have result rows, display them
                    if let rows = msg.rows, !rows.isEmpty {
                        resultGrid(rows: rows)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    private func sqlBlock(sql: String, messageID: UUID) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SQL proposé :")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: true) {
                Text(sql)
                    .font(.system(.footnote, design: .monospaced))
                    .padding(10)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(8)
            }

            HStack(spacing: 12) {
                Button {
                    Task { await vm.runSQL(sql, attachToMessageWithID: messageID) }
                } label: {
                    Label("Exécuter SQL", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isExecutingSQL)

                if vm.isExecutingSQL {
                    ProgressView()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func resultGrid(rows: [[String]]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Résultats :")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 12) {
                            ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                                Text(cell)
                                    .font(.system(.footnote, design: .monospaced))
                                    .padding(6)
                                    .background(Color(UIColor.tertiarySystemBackground))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }

    private var aiLoaderBubble: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Image("Louki")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .padding(.bottom, 4)

                ProgressView()
                    .padding(12)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(20)
                    .frame(maxWidth: 260, alignment: .leading)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: – Composer

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Pose ta question", text: $userInput, axis: .vertical)
                .padding(12)
                .background(Color.white)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.cyan, lineWidth: 1)
                )
                .lineLimit(1...4)
                .onSubmit { sendMessage() }  // send on Return

            Button(action: sendMessage) {
                Circle()
                    .fill(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !vm.isConnected ? Color.gray : Color.cyan)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .font(.title3)
                    )
            }
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending || !vm.isConnected)
        }
        .padding(.all, 16)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: – Send logic

    private func sendMessage() {
        let clean = userInput.trimmed()
        guard !clean.isEmpty, vm.isConnected else { return }

        isLoadingBubble = true

        Task {
            // 1) Ask the agent via service/VM
            await vm.send(text: clean)
            isLoadingBubble = false

            // 2) If user asked about formations, show suggestions under the LAST AI message
            let lower = clean.lowercased()
            if lower.contains("formation") || lower.contains("orientation") || lower.contains("droit") {
                await fetchSuggestionsAndAttachToLastAI()
            }

            userInput = ""
        }
    }

    private func fetchSuggestionsAndAttachToLastAI() async {
        // Make sure the last message is the AI response we want to decorate
        guard let lastAI = vm.messages.last(where: { $0.role == .ai }) else { return }

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            formationVM.fetchFormations { (result: Result<[Formation], Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let formations):
                        self.suggestionsForMessage[lastAI.id] = Array(formations.prefix(2))
                    case .failure:
                        break
                    }
                    cont.resume()
                }
            }
        }
    }

    // MARK: – Suggestions (Louki cards)

    private func suggestionList(_ items: [Formation]) -> some View {
        VStack(spacing: 12) {
            ForEach(items) { formation in
                NavigationLink(destination: FormationDetailsView(formationId: formation.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 4, height: 24)
                                .cornerRadius(2)
                            VStack(alignment: .leading) {
                                Text(formation.titre)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#1D2B4F"))
                                Text(formation.etablissement)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: – Small helpers

private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

// MARK: – Preview

#Preview {
    LoukiSQLChatbotView()
}
