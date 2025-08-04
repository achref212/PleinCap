import SwiftUI

struct PreferenceQuestion: Identifiable {
    let id = UUID()
    let title: String
    let question: String
    let options: [String]
}



struct PreferenceQuestionsView: View {
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int?] = Array(repeating: nil, count: 9)

    let questions: [PreferenceQuestion] = [
        PreferenceQuestion(
            title: "Études",
            question: "Comment Préférerais-tu suivre les études ?",
            options: ["Études longues (3 ans ou plus)", "Études courtes (2 ans ou moins)", "Pas de Préférence"]
        ),
        PreferenceQuestion(
            title: "Apprentissage",
            question: "Préférerais-tu apprendre à travers des choses…",
            options: ["Concrètes (manipuler, fabriquer)", "Abstraites (concepts, théories, débats)", "Pas de Préférence"]
        ),
        PreferenceQuestion(
            title: "Environnement",
            question: "Préférerais-tu étudier dans un environnement plutôt…",
            options: ["Pratique (ateliers, projets..)", "Théorique (cours, exposés, lectures..)", "Peu importe"]
        ),
        PreferenceQuestion(
            title: "Formation",
            question: "Tu serais plutôt attiré(e) par une formation…",
            options: ["En apprentissage (= Cours + Travail en entreprise)", "Hors apprentissage (= Cours uniquement)", "Peu importe"]
        ),
        PreferenceQuestion(
            title: "Groupe",
            question: "Tu préférerais avoir cours…",
            options: ["En petit groupe, avec les mêmes personnes", "Dans de grands espaces, avec beaucoup de monde", "Peu importe/Je ne sais pas encore"]
        ),
        PreferenceQuestion(
            title: "Autonomie",
            question: "Tu préférerais être accompagné(e) ou plutôt autonome dans ton apprentissage ?",
            options: ["Encadré(e)", "Autonome", "Peu importe/Je ne sais pas encore"]
        ),
        PreferenceQuestion(
            title: "Confiance",
            question: "Te sens-tu prêt(e) à relever un défi dans ta formation ?",
            options: ["Je n’ai pas peur du challenge !", "Je cherche quelque chose de pas trop difficile", "Pas de préférence, du moment que j’aime ce que je fais"]
        ),
        PreferenceQuestion(
            title: "Métier",
            question: "Tu préfères choisir un métier rapidement, ou te laisser encore quelques années pour réfléchir ?",
            options: ["Choisir un métier rapidement !", "Je préfère me laisser le temps", "Pas de préférence"]
        ),
        PreferenceQuestion(
            title: "Apprentissage",
            question: "Souhaites-tu apprendre à travers un cadre structuré ou flexible ?",
            options: ["Structuré", "Flexible", "Peu importe"]
        )
    ]

    var body: some View {
        let current = questions[currentQuestionIndex]

        VStack(spacing: 16) {
            ProgressBarView(progress: .constant(Double(currentQuestionIndex) / Double(questions.count)))
                .padding(.horizontal)

            Image("question_illustration")
                .resizable()
                .scaledToFit()
                .frame(height: 180)

            VStack(alignment: .leading, spacing: 12) {
                TitleWithSideLineView(title: current.title, subtitle: current.question)
                    .padding(.bottom, 8)

                ForEach(current.options.indices, id: \.self) { i in
                    Button(action: {
                        answers[currentQuestionIndex] = i
                    }) {
                        HStack {
                            Circle()
                                .fill(answers[currentQuestionIndex] == i ? Color.accentColor : Color.clear)
                                .frame(width: 24, height: 24)
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))

                            Text(current.options[i])
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.cyan.opacity(0.5), lineWidth: 1)
                        )
                    }
                }

                Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(radius: 2)
            )
            .padding(.horizontal)

            PrimaryGradientButton(title: currentQuestionIndex < questions.count - 1 ? "Suivant" : "Terminer", enabled: answers[currentQuestionIndex] != nil) {
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                } else {
                    print("Réponses utilisateur :", answers)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Preview

struct PreferenceQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceQuestionsView()
            .preferredColorScheme(.light)
    }
}
