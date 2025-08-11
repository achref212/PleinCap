//
//  BourseEligibilityView.swift
//  PleinCap
//
//  Created by chaabani achref on 11/8/2025.
//

import SwiftUI

struct BourseEligibilityView: View {
    @EnvironmentObject var authVM: AuthViewModel1
    @Environment(\.openURL) private var openURL

    @Binding var progress: Double

    @State private var selection: BourseOption? = nil
    @State private var isSaving = false
    @State private var goToBudget = false      // ✅ navigation flag

    var body: some View {
        VStack(spacing: 24) {
            // Top bar
            HStack {
                Spacer()
                ProgressBarView(progress: $progress)
                    .frame(maxWidth: 420)
                Spacer()
            }
            .padding(.horizontal)

            // Illustration
            Image("bourse_illustration")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 380)
                .padding(.top, 8)

            // Card
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 10) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 28)
                        .cornerRadius(2)
                    Text("Es-tu (éligible) boursier ?")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))
                }

                VStack(spacing: 14) {
                    BourseOptionRow(title: "Oui",
                                    isSelected: selection == .yes) { selection = .yes }
                    BourseOptionRow(title: "Non",
                                    isSelected: selection == .no) { selection = .no }
                    BourseOptionRow(title: "Je ne sais pas",
                                    isSelected: selection == .unknown) { selection = .unknown }
                }

                Button {
                    if let url = URL(string: "https://www.lescrous.fr/nos-services/une-offre-de-services-riche-et-de-qualite-pour-tous-les-etudiants/#simulateur-de-bourse-testez-votre-eligibilite") {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Clique ici").underline().foregroundColor(.blue)
                        Text("pour savoir si tu peux être boursier").foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
            .padding(.horizontal)

            Spacer(minLength: 8)

            // Suivant
            PrimaryGradientButton(
                title: isSaving ? "Enregistrement…" : "Suivant",
                enabled: selection != nil && !isSaving
            ) {
                Task { await saveThenContinue() }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Bourse")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let current = authVM.estBoursier { selection = current ? .yes : .no }
            progress = max(progress, 0.30)
        }

        // ✅ Hidden link to the budget screen
        .background(
            NavigationLink(isActive: $goToBudget) {
                EstimatedBudgetView(progress: $progress)
                    .environmentObject(authVM)
            } label: { EmptyView() }
                .hidden()
        )
    }

    // MARK: - Actions

    private func saveThenContinue() async {
        guard let selection else { return }

        switch selection {
        case .yes, .no:
            isSaving = true
            let value = (selection == .yes)
            await withCheckedContinuation { cont in
                authVM.updateUserFields(["est_boursier": value]) { result in
                    isSaving = false
                    switch result {
                    case .success:
                        authVM.estBoursier = value
                        progress = max(progress, 0.35)
                        withAnimation { goToBudget = true }   // ➜ Budget
                    case .failure(let err):
                        authVM.errorMessage = ErrorMessage(
                            message: "Échec de la mise à jour: \(err.localizedDescription)"
                        )
                    }
                    cont.resume()
                }
            }
        case .unknown:
            // No DB write; still proceed
            progress = max(progress, 0.35)
            withAnimation { goToBudget = true }
        }
    }
}

// MARK: - Types

private enum BourseOption { case yes, no, unknown }

// MARK: - Row

private struct BourseOptionRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "#17C1C1") : Color(.systemGray4), lineWidth: 2)
                        .frame(width: 36, height: 36)
                    if isSelected {
                        Circle().fill(Color(hex: "#17C1C1"))
                            .frame(width: 18, height: 18)
                    }
                }
                Text(title)
                    .foregroundColor(Color(hex: "#1F3552"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 62)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(isSelected ? Color(hex: "#17C1C1") : Color(.systemGray5), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct BourseEligibilityView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.30
        @StateObject private var authVM = AuthViewModel1()
        var body: some View {
            NavigationStack {
                BourseEligibilityView(progress: $progress)
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
