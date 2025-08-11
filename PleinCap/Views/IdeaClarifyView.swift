import SwiftUI

// MARK: - Gemini Service (unchanged)
struct GeminiService {
    struct GLRequest: Encodable {
        struct Part: Encodable { let text: String }
        struct Content: Encodable { let role: String? = nil; let parts: [Part] }
        let contents: [Content]
    }

    struct GLResponse: Decodable {
        struct Candidate: Decodable {
            struct Content: Decodable {
                struct Part: Decodable { let text: String? }
                let parts: [Part]
            }
            let content: Content
        }
        let candidates: [Candidate]?
    }

    let apiKey: String

    init() {
        self.apiKey = (Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String) ?? ""
    }

    func summarize(idea: String,
                   domains: [String],
                   sectors: [String],
                   trainings: [String]) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "Gemini", code: -1, userInfo: [NSLocalizedDescriptionKey: "Clé Gemini manquante."])
        }

        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"

        let instructions =
        """
        Tu es un assistant d’orientation. Rôle:
        1) Comprendre ce que l’élève a écrit + ses sélections dans:
           - Domaines de formation
           - Domaines de métiers / secteurs
           - Types de formation
        2) Générer 1 à 2 phrases qui reformulent clairement pour vérifier la compréhension.
        3) Pas de liste. Ton poli, clair, et termine par: "c'est bien cela ?"
        """

        let context =
        """
        Idée libre de l’élève:
        "\(idea)"

        Domaines de formation: \(domains.isEmpty ? "aucun" : domains.joined(separator: ", "))
        Domaines de métiers / secteurs: \(sectors.isEmpty ? "aucun" : sectors.joined(separator: ", "))
        Types de formation visés: \(trainings.isEmpty ? "aucun" : trainings.joined(separator: ", "))
        """

        let prompt =
        """
        \(instructions)

        Contexte:
        \(context)

        Ta réponse: 1 ou 2 phrases maximum, termine par "c'est bien cela ?"
        """

        let body = GLRequest(contents: [.init(parts: [.init(text: prompt)])])

        var req = URLRequest(url: URL(string: endpoint)!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "n/a"
            throw NSError(domain: "Gemini", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: "Erreur API Gemini. Réponse: \(raw)"])
        }
        let decoded = try JSONDecoder().decode(GLResponse.self, from: data)
        let text = decoded.candidates?.first?.content.parts.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        return text ?? "Je comprends que tu as une idée, mais peux-tu en dire un peu plus ?"
    }
}

// MARK: - IdeaClarifyView
struct IdeaClarifyView: View {
    @EnvironmentObject var authVM: AuthViewModel1

    // From previous screen (OrientationChoicesView)
    var selectedDomains: [String] = []
    var selectedSectors: [String] = []
    var selectedTrainingTypes: [String] = []

    // Local state
    @State private var freeIdea: String = ""
    @State private var aiSummary: String? = nil
    @State private var userCorrection: String = ""
    @State private var showCorrection: Bool = false

    @State private var isLoading = false
    @State private var savedOK = false
    @State private var localError: String? = nil

    // Navigation to SelectLevelView
    @State private var goToLevel = false
    @State private var progress: Double = 0.3   // continue progress into the next step

    // Optional: when done, caller can override
    var onDone: (() -> Void)? = nil

    private let gemini = GeminiService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress (optional visual consistency)
                ProgressBarView(progress: $progress)
                    .padding(.top)

                header

                card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Précise ton idée")
                            .font(.headline)
                        Text("Explique en quelques lignes ce que tu as en tête (métier, domaine, type d’études…).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextEditor(text: $freeIdea)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)

                        HStack {
                            Spacer()
                            Button {
                                Task { await askGemini() }
                            } label: {
                                HStack {
                                    if isLoading { ProgressView().padding(.trailing, 4) }
                                    Text("Proposer un résumé")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading || freeIdea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }

                if let ai = aiSummary {
                    confirmationCard(ai: ai)
                }

                if let err = localError {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                if savedOK {
                    Text("✅ Ton idée a été enregistrée.")
                        .foregroundColor(.green)
                        .padding(.top, 8)
                }

                // Hidden navigation to SelectLevelView after save
                NavigationLink(
                    destination: SelectLevelView(progress: $progress)
                        .onAppear { withAnimation { progress = max(progress, 0.4) } },
                    isActive: $goToLevel
                ) { EmptyView() }
                .hidden()
            }
            .padding()
        }
        .navigationTitle("Clarifier mon idée")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image("ThinkingStudent")
                .resizable()
                .scaledToFit()
                .frame(height: 160)
                .accessibilityHidden(true)

            Text("On vérifie ensemble qu’on a bien compris ton idée.")
                .font(.title3.weight(.semibold))
                .foregroundColor(Color(hex: "#2C4364"))
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding()
            .background(.background)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private func confirmationCard(ai: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 12) {
                Text("Résumé proposé")
                    .font(.headline)
                Text(ai)
                    .font(.body)
                    .foregroundColor(.primary)

                Text("Est-ce correct ?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 6)

                HStack(spacing: 12) {
                    Button {
                        Task { await saveConfirmedIdea(summary: ai) }
                    } label: {
                        Text("Oui, c’est ça !")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button {
                        withAnimation {
                            showCorrection = true
                        }
                    } label: {
                        Text("Pas vraiment")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if showCorrection {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explique ce qui n’est pas exact")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        TextEditor(text: $userCorrection)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)

                        HStack {
                            Spacer()
                            Button {
                                Task { await refineWithCorrection() }
                            } label: {
                                HStack {
                                    if isLoading { ProgressView().padding(.trailing, 4) }
                                    Text("Proposer une nouvelle synthèse")
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading || userCorrection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    // MARK: - Actions

    private func askGemini() async {
        localError = nil
        aiSummary = nil
        savedOK = false
        isLoading = true
        defer { isLoading = false }

        do {
            let reply = try await gemini.summarize(
                idea: freeIdea,
                domains: selectedDomains,
                sectors: selectedSectors,
                trainings: selectedTrainingTypes
            )
            aiSummary = reply
        } catch {
            localError = error.localizedDescription
        }
    }

    private func refineWithCorrection() async {
        localError = nil
        savedOK = false
        isLoading = true
        defer { isLoading = false }

        let merged = """
        Idée initiale:
        \(freeIdea)

        Correction de l’élève (ce qui n’était pas exact):
        \(userCorrection)
        """

        do {
            let reply = try await gemini.summarize(
                idea: merged,
                domains: selectedDomains,
                sectors: selectedSectors,
                trainings: selectedTrainingTypes
            )
            aiSummary = reply
            userCorrection = "" // clear after re-proposal
            showCorrection = false
        } catch {
            localError = error.localizedDescription
        }
    }

    private func saveConfirmedIdea(summary: String) async {
        localError = nil
        isLoading = true
        savedOK = false
        defer { isLoading = false }

        // Build payload for backend JSON column `orientation_choices`
        let choices: [String: Any] = [
            "formation_domains": selectedDomains,
            "job_sectors": selectedSectors,
            "training_types": selectedTrainingTypes
        ]

        let payload: [String: Any] = [
            "idee": freeIdea.trimmingCharacters(in: .whitespacesAndNewlines), // text field on backend
            "orientation_choices": choices,
            "idee_summary": summary // optional: keep the AI rephrase
        ]

        authVM.updateUserFields(payload) { result in
            switch result {
            case .success:
                savedOK = true
                withAnimation { progress = max(progress, 0.35) }
                // Auto navigate to SelectLevelView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation { goToLevel = true }
                }
                onDone?()
            case .failure(let err):
                localError = err.localizedDescription
            }
        }
    }
}

// MARK: - Preview

struct IdeaClarifyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                IdeaClarifyView()
                    .environmentObject(AuthViewModel1())
                    .preferredColorScheme(.light)
            }

            NavigationStack {
                IdeaClarifyView(
                    selectedDomains: ["Biologie", "Informatique"],
                    selectedSectors: ["Santé / médecine / soins"],
                    selectedTrainingTypes: ["BUT"]
                )
                .environmentObject(AuthViewModel1())
                .preferredColorScheme(.dark)
            }
        }
    }
}
