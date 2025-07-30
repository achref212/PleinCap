import SwiftUI

struct FinalPlanView: View {
    @State private var currentStepIndex = 0
    @State private var steps: [PlanStep] = []

    init() {
        _steps = State(initialValue: FinalPlanView.createSteps())
    }

    static func createSteps() -> [PlanStep] {
        [
            PlanStep(
                title: "Identifier tes centres d’intérêts",
                description: "Découvre ce qui te passionne !",
                dateRange: "Du 11 au 13 avril",
                viewBuilder: { onComplete in
                    AnyView(Step1View(onComplete: onComplete))
                }
            ),
            PlanStep(
                title: "Explorer les formations",
                description: "Trouve celles qui te correspondent",
                dateRange: "Du 14 au 16 avril",
                viewBuilder: { onComplete in AnyView(Step2View(onComplete: onComplete)) }
            ),
            PlanStep(
                title: "Affiner les recherches",
                description: "Resserre tes options",
                dateRange: "Du 17 au 18 avril",
                viewBuilder: { onComplete in AnyView(Step3View(onComplete: onComplete)) }
            ),
            PlanStep(
                title: "Élaborer ta liste de vœux",
                description: "Organise ta stratégie",
                dateRange: "Du 19 avril",
                viewBuilder: { onComplete in AnyView(Step4View(onComplete: onComplete)) }
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F4F6F8").ignoresSafeArea()
                CircleBackgroundBottomView()

                VStack(spacing: 24) {
                    Text("plan d'action")
                        .font(.title.bold())
                        .foregroundColor(Color(hex: "#2C4364"))
                        .padding(.top)

                    // 🟠 Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 4)
                                .cornerRadius(2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("On y est !")
                                    .font(.headline.bold())
                                    .foregroundColor(Color(hex: "#2C4364"))
                                Text("Ton plan d’action personnalisé")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(Color(hex: "#17C1C1"))
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("D’ici 10 jours")
                                    .foregroundColor(Color(hex: "#17C1C1"))
                                    .font(.subheadline.bold())
                                Text("environ 15 min par jour")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#17C1C1"), lineWidth: 1)
                                .background(Color(hex: "#E6FAFA").opacity(0.6))
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)

                    // ✅ Étapes
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(steps.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 12) {
                                VStack {
                                    if steps[index].isDone {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title3)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .frame(width: 24, height: 24)
                                            .background(Circle().fill(Color.white).shadow(radius: 1))
                                    }

                                    if index < steps.count - 1 {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 2)
                                            .frame(maxHeight: .infinity)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(steps[index].dateRange):")
                                        .foregroundColor(Color(hex: "#17C1C1"))
                                        .font(.subheadline.bold())
                                    Text(steps[index].title)
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#2C4364"))
                                }
                                .padding()
                                .background(Color(hex: "#FFF9F3"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    NavigationLink(
                        destination: steps[currentStepIndex].viewBuilder() {
                            steps[currentStepIndex].isDone = true
                            if currentStepIndex < steps.count - 1 {
                                currentStepIndex += 1
                            }
                        },
                        label: {
                            Text("Suivant")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#17C1C1"))
                                .cornerRadius(30)
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    FinalPlanView()
}
