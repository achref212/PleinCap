import SwiftUI

struct PreferenceQuestion: Identifiable {
    let id = UUID()
    let title: String
    let question: String
    let options: [String]
}

struct PreferenceQuestionsView: View {
    // Comes from the flow (e.g. from EstimatedBudgetView)
    @Binding var progress: Double

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var authVM: AuthViewModel1
    @State private var goToRiasec = false              // ← navigate to Riasec

    // UI state
    @State private var index = 0
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var goToPerformance = false

    // Answers (one Int? per question)
    @State private var answers: [Int?]

    init(progress: Binding<Double>) {
        _progress = progress
        _answers = State(initialValue: Array(repeating: nil, count: PreferenceQuestionsView.makeQuestions().count))
    }

    // Exactly 8 questions, matching your screenshots
    static func makeQuestions() -> [PreferenceQuestion] {
        [
            PreferenceQuestion(
                title: "Études",
                question: "Préférerais-tu suivre des études plutôt…",
                options: [
                    "Longues (plus de 3 ans)",
                    "Courtes (3 ans ou moins)",
                    "Pas de préférence / Je ne sais pas encore"
                ]),

            PreferenceQuestion(
                title: "Apprentissage",
                question: "Préférerais-tu apprendre à travers des choses…",
                options: [
                    "Concrètes (manipuler, fabriquer)",
                    "Abstraites (concepts, théories, débats)",
                    "Pas de préférence"
                ]),

            PreferenceQuestion(
                title: "Environnement",
                question: "Préférerais-tu étudier dans un environnement plutôt…",
                options: [
                    "Pratique (ateliers, projets…)",
                    "Théorique (cours, exposés, lectures…)",
                    "Peu importe"
                ]),

            PreferenceQuestion(
                title: "Formation",
                question: "Tu serais plutôt attiré(e) par une formation…",
                options: [
                    "En apprentissage (= cours + travail en entreprise)",
                    "Hors apprentissage (= cours uniquement)",
                    "Peu importe"
                ]),

            PreferenceQuestion(
                title: "Établissements",
                question: "As-tu une préférence pour les établissements publics ou privés ?",
                options: [
                    "Uniquement du public",
                    "Uniquement du privé",
                    "Je suis ouvert aux deux"
                ]),

            PreferenceQuestion(
                title: "Autonomie",
                question: "Tu préférerais être accompagné(e) ou plutôt autonome dans ton apprentissage ?",
                options: [
                    "Encadré(e)",
                    "Autonome",
                    "Peu importe / Je ne sais pas encore"
                ]),

            PreferenceQuestion(
                title: "Confiance",
                question: "À quel point serais-tu prêt(e) à relever un défi dans ta formation ?",
                options: [
                    "Je n’ai pas peur du challenge !",
                    "Je cherche quelque chose de pas trop difficile",
                    "Pas de préférence, du moment que j’aime ce que je fais"
                ]),

            PreferenceQuestion(
                title: "Projet métier",
                question: "Tu préfères choisir un métier rapidement, ou te laisser encore quelques années pour réfléchir ?",
                options: [
                    "Choisir un métier rapidement !",
                    "Je préfère me laisser le temps",
                    "Pas de préférence"
                ])
        ]
    }

    private let questions = PreferenceQuestionsView.makeQuestions()

    private var current: PreferenceQuestion { questions[index] }
    private var isLast: Bool { index == questions.count - 1 }
    private var stepProgress: Double { Double(index) / Double(questions.count) }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack(spacing: 12) {
                Button {
                    if index > 0 { index -= 1 } else { dismiss() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#1F3552"))
                        .padding(10)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                }

                Spacer(minLength: 12)

                // Local step progress (keeps your global bar style)
                ProgressBarView(progress: .constant(max(0.30, stepProgress))) // keeps ≈30% look like your mock
                    .frame(height: 18)
            }
            .padding([.horizontal, .top])

            ScrollView {
                VStack(spacing: 20) {
                    // Illustration (same look as your other steps)
                    Image("question_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .accessibilityHidden(true)

                    // Card
                    VStack(alignment: .leading, spacing: 16) {
                        TitleWithSideLineView(title: current.title, subtitle: current.question)

                        // Choices
                        VStack(spacing: 14) {
                            ForEach(current.options.indices, id: \.self) { i in
                                ChoiceRow(
                                    title: current.options[i],
                                    selected: answers[index] == i
                                ) {
                                    answers[index] = i
                                }
                            }
                        }

                        // Context link only for Question 4 (apprentissage)
                        if index == 3 {
                            Button {
                                if let url = URL(string: "https://www.service-public.fr/particuliers/vosdroits/F2918") {
                                    openURL(url)
                                }
                            } label: {
                                Text("Comprendre les formations en apprentissage en 20 sec")
                                    .underline()
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }

                        // Footer: counter
                        Text("Question \(index + 1)/\(questions.count)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }

            // Bottom CTA
            PrimaryGradientButton(
                title: isLast ? (isSaving ? "Enregistrement…" : "Terminer")
                              : "Suivant",
                enabled: answers[index] != nil && !isSaving
            ) {
                if isLast {
                    Task { await saveAllAnswers() }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) { index += 1 }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Hidden navigation to the next screen in your flow
            NavigationLink(
                           destination: RiasecTestView().environmentObject(authVM),
                           isActive: $goToRiasec
                       ) { EmptyView() }
                       .hidden()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Définir mes préférences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Keep your global progress moving a bit
            progress = max(progress, 0.35)
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(title: Text("Erreur"),
                  message: Text(errorMessage ?? ""),
                  dismissButton: .default(Text("OK")) {
                      errorMessage = nil
                  })
        }
    }

    // MARK: - Save

    private func saveAllAnswers() async {
        // Build a sanitized dictionary: one key per question
        var quiz: [String: Any] = [:]

        for (i, q) in questions.enumerated() {
            guard let sel = answers[i], q.options.indices.contains(sel) else { continue }
            let key = "q\(i+1)_\(q.title.sanitizedFR)"              // stable, ascii-ish key
            quiz[key] = [
                "question": q.question.sanitizedFR,
                "answer_index": sel,
                "answer_text": q.options[sel].sanitizedFR
            ]
        }

        isSaving = true
        await withCheckedContinuation { cont in
            authVM.updateUserFields(["preferences_quiz": quiz]) { result in
                isSaving = false
                switch result {
                case .success:
                    withAnimation {
                        progress = max(progress, 0.40)
                        goToRiasec = true          // ← go!
                    }
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
                cont.resume()
            }
        }
    }
}

// MARK: - Choice row (rounded pill style)

private struct ChoiceRow: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 38, height: 38)
                    Circle()
                        .stroke(selected ? Color(hex: "#17C1C1") : Color(.systemGray4), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if selected {
                        Circle()
                            .fill(Color(hex: "#17C1C1"))
                            .frame(width: 12, height: 12)
                    }
                }

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Color(hex: "#1F3552"))
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(hex: "#17C1C1").opacity(selected ? 0.9 : 0.4), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview (uses a fake PerformanceView so it compiles)


struct PreferenceQuestionsView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.36
        @StateObject private var authVM = AuthViewModel1()
        var body: some View {
            NavigationStack {
                PreferenceQuestionsView(progress: $progress)
                    .environmentObject(authVM)
            }
        }
    }
    static var previews: some View {
        Wrapper()
            .preferredColorScheme(.light)
        Wrapper()
            .preferredColorScheme(.dark)
    }
}
