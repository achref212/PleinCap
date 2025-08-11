import SwiftUI

struct EstimatedBudgetView: View {
    @Binding var progress: Double

    @EnvironmentObject var authVM: AuthViewModel1
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // UI
    @State private var budgetText: String = ""        // user input (string sent to backend)
    @State private var isSaving = false
    @State private var goNext = false

    // Validation
    private var canSave: Bool {
        !budgetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress
                ProgressBarView(progress: $progress)
                    .padding(.top)

                // Illustration + caption (like your other screens)
                ImageWithCaptionView(imageName: "budget", caption: "Budget Estimé")

                // Card
                VStack(alignment: .leading, spacing: 18) {
                    // Heading line + title
                    HStack(alignment: .top, spacing: 10) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 24)
                            .cornerRadius(2)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("As-tu une idée du budget que tu pourrais mettre pour ta 1ʳᵉ année d’études ?")
                                .font(dynamicTypeSize.isAccessibilitySize ? .title3.bold() : .title2.bold())
                                .foregroundColor(Color(hex: "#2C4364"))

                            Text("N’hésite pas à demander ce chiffre à tes parents si besoin, tu pourras toujours le changer plus tard. Tu n’es bien sûr pas obligé de répondre à cette question !")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }

                    // Field label
                    Text("Budget annuel en euros (€)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#2C4364"))

                    // Rounded text field
                    TextField("Ex: 1500", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(.secondarySystemBackground))
                        )

                    // Big white pill button
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        // User chooses to skip -> don't update budget, just continue
                        withAnimation {
                            goNext = true
                        }
                    } label: {
                        Text("je ne sais pas encore")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#17C1C1"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 36)
                                            .fill(Color.white)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                )
                .padding(.horizontal)

                // Primary continue
                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement..." : "Suivant",
                    enabled: canSave && !isSaving
                ) {
                    Task { await saveAndContinue() }
                }
                .padding(.horizontal)

                // Nav to next screen in your flow
                NavigationLink(destination: PlanGenerationView(), isActive: $goNext) {
                    EmptyView()
                }
                .hidden()
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Prefill if user already has a budget
            if let b = authVM.budget, !b.isEmpty { budgetText = b }
            progress = max(progress, 0.30)
        }
        .alert(item: $authVM.errorMessage) { err in
            Alert(title: Text("Erreur"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Save

    private func saveAndContinue() async {
        let raw = budgetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }

        // Sanitize: keep digits, comma, dot. Store as string (your DB column is varchar)
        var sanitized = raw.replacingOccurrences(of: "[^0-9.,]", with: "", options: .regularExpression)
        // Normalize comma to dot (optional)
        sanitized = sanitized.replacingOccurrences(of: ",", with: ".")

        isSaving = true
        await withCheckedContinuation { cont in
            authVM.updateUserFields(["budget": sanitized]) { result in
                self.isSaving = false
                switch result {
                case .success:
                    self.authVM.budget = sanitized
                    withAnimation { self.goNext = true }
                case .failure(let error):
                    self.authVM.errorMessage = ErrorMessage(message: "Échec de l’enregistrement du budget : \(error.localizedDescription)")
                }
                cont.resume()
            }
        }
    }
}

struct EstimatedBudgetView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.32
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            NavigationStack {
                EstimatedBudgetView(progress: $progress)
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            Wrapper().preferredColorScheme(.light)
            Wrapper().preferredColorScheme(.dark)
        }
    }
}
