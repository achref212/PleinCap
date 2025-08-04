import SwiftUI

struct RiasecType: Identifiable {
    let id = UUID()
    let code: String
    let title: String
    let description: String
    var isSelected: Bool = false
}

struct UserGuessRiasecView: View {
    @State private var types: [RiasecType] = [
        RiasecType(code: "R", title: "R–Réaliste", description: "Tu aimes le concret, les activités manuelles ou techniques, travailler avec tes mains ou bouger, voir les résultats de tes actions."),
        RiasecType(code: "I", title: "I–Investigateur", description: "Tu es curieux·se, tu aimes comprendre, observer, chercher, réfléchir."),
        RiasecType(code: "A", title: "A–Artistique", description: "Tu aimes t’exprimer, créer, inventer, imaginer, sortir des sentiers battus."),
        RiasecType(code: "S", title: "S–Social", description: "Tu aimes aider, écouter, expliquer, être en contact avec les autres."),
        RiasecType(code: "E", title: "E–Entreprenant", description: "Tu aimes convaincre, diriger, décider, relever des défis."),
        RiasecType(code: "C", title: "C–Conventionnel", description: "Tu es organisé·e, tu aimes quand c’est clair, structuré, bien rangé.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Bravo, tu as fini le questionnaire !")
                    .font(.title2.bold())
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                Image("finish")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: 20) {
                    TitleWithSideLineView(
                        title: "Juste avant de te montrer les résultats, on te propose un petit jeu :",
                        subtitle: "Si tu devais deviner ton profil, lequel choisirais-tu ?\nLis les 6 types ci-dessous et coche ceux que tu penses faire partie de ton profil (maximum 3)."
                    )

                    ForEach($types) { $type in
                        Button(action: {
                            let selectedCount = types.filter { $0.isSelected }.count
                            if type.isSelected {
                                type.isSelected = false
                            } else if selectedCount < 3 {
                                type.isSelected = true
                            }
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(type.isSelected ? Color.accentColor : Color.clear)
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(Color.cyan, lineWidth: 2))
                                    .padding(.top, 8)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(type.title + " :")
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "#1D2B4F"))

                                    Text(type.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 110)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.cyan.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                PrimaryGradientButton(title: "Suivant", enabled: types.contains(where: { $0.isSelected })) {
                    let selected = types.filter { $0.isSelected }
                    print("Types sélectionnés:", selected.map { $0.code })
                }
                .padding(.bottom)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    UserGuessRiasecView()
}
