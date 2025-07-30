import SwiftUI

struct EstimatedBudgetView: View {
    @Binding var progress: Double
    @State private var minBudget: Double = 20
    @State private var maxBudget: Double = 90
    @State private var goNext = false

    private let initialMin: Double = 20
    private let initialMax: Double = 90

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressBarView(progress: $progress)
                    .padding(.top)

                // 🔹 Remplacement de l'image simple par ImageWithCaptionView
                ImageWithCaptionView(imageName: "budget", caption: "Budget Estimé")

                VStack(alignment: .leading, spacing: 16) {
                                  HStack(spacing: 8) {
                                      Rectangle()
                                          .fill(Color.orange)
                                          .frame(width: 4)
                                          .cornerRadius(2)

                                      VStack(alignment: .leading, spacing: 4) {
                                          Text("Indique ton budget annuel pour les études supérieures.")
                                              .font(.subheadline)
                                              .foregroundColor(Color(hex: "#2C4364"))
                                              .fixedSize(horizontal: false, vertical: true)
                                      }

                                      Spacer()
                                  }

                                  Text("Entre \(Int(minBudget))k€ et \(Int(maxBudget))k€")
                                      .font(.headline)
                                      .foregroundColor(Color(hex: "#2C4364"))

                                  RangeSliderView(
                                      minValue: $minBudget,
                                      maxValue: $maxBudget,
                                      range: 0...100
                                  )
                              }
                .padding(.vertical, 20)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal)

                Button {
                    goNext = true
                } label: {
                    Text("Suivant")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (minBudget == initialMin && maxBudget == initialMax)
                            ? Color.gray.opacity(0.3)
                            : Color(hex: "#17C1C1")
                        )
                        .cornerRadius(30)
                }
                .disabled(minBudget == initialMin && maxBudget == initialMax)
                .padding(.horizontal)

                // 👉 Redirection vers PlanGenerationView
                NavigationLink(destination: PlanGenerationView(), isActive: $goNext) {
                    EmptyView()
                }
                .hidden()
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EstimatedBudgetView(progress: .constant(0.3))
    }
}
