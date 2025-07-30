import SwiftUICore
import SwiftUI

struct Step1View: View {
    var onComplete: () -> Void
    @State private var selectedOption: String? = nil
    @Environment(\.dismiss) private var dismiss

    private let options = [
        "J’ai choisi ma filière",
        "Mes parents et/ou mon professeur m’ont recommandé de choisir cette filière",
        "Quelqu’un d’autre a décidé pour moi (parents, prof, etc.)",
        "Autre raison"
    ]

    var body: some View {
        ZStack {
            Color(hex: "#F4F6F8").ignoresSafeArea()
            CircleBackgroundBottomView()

            VStack(spacing: 24) {
                TitleWithSideLineView(
                    title: "Identifier tes intérêts",
                    subtitle: "Comment t’es-tu dirigé vers ce type de bac ?"
                )
                .padding(.top)

                VStack(spacing: 16) {
                    ForEach(options, id: \.self) { option in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(
                                        selectedOption == option ? Color(hex: "#17C1C1") : Color.gray.opacity(0.3),
                                        lineWidth: 2
                                    )
                                    .frame(width: 24, height: 24)

                                if selectedOption == option {
                                    Circle()
                                        .fill(Color(hex: "#17C1C1"))
                                        .frame(width: 12, height: 12)
                                }
                            }

                            Text(option)
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#2C4364"))
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            selectedOption == option ? Color(hex: "#17C1C1") : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedOption = option
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    onComplete()
                    dismiss()
                }) {
                    Text("Suivant")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOption == nil ? Color.gray.opacity(0.3) : Color(hex: "#17C1C1"))
                        .cornerRadius(30)
                }
                .disabled(selectedOption == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        Step1View {
            print("✅ Étape 1 complétée → retour vers FinalPlanView")
        }
    }
}
