//
//  SelectObjectiveView.swift
//  PFE_APP
//
//  Created by chaabani achref on 8/7/2025.
//

import SwiftUI

struct SelectObjectiveView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject var authVM: AuthViewModel

    @State private var selectedObjective: String? = nil
    @State private var progress: Double = 0.0
    @State private var goToNext = false
    @State private var navigateToPreferenceQuestions = false // For conditional navigation

    let objectives: [String] = [
        "Je ne sais pas quoi faire après le bac et je veux trouver des idées !",
        "J’ai quelques idées de ce que je voudrais faire après le bac"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressBarView(progress: $progress)
                    .padding(.top)

                ImageWithCaptionView(imageName: "ThinkingStudent", caption: "Objectif")

                titleSection
                cardsSection

                // ✅ Nouveau bouton dégradé
                PrimaryGradientButton(title: "Suivant", enabled: selectedObjective != nil) {
                    if let selected = selectedObjective {
                        authVM.updateUserFields(["objectif": selected]) {
                            DispatchQueue.main.async {
                                if authVM.errorMessage == nil {
                                    authVM.objectif = selected

                                    // 🔁 Synchronisation propre pour SwiftUI
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            if selected == "J’ai quelques idées de ce que je voudrais faire après le bac" {
                                                navigateToPreferenceQuestions = true
                                            } else {
                                                goToNext = true
                                            }
                                        }
                                    }

                                } else {
                                    print("Failed to update user fields: \(authVM.errorMessage ?? "Unknown error")")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)

                // Navigation Links
                NavigationLink(
                    destination: SelectLevelView(progress: $progress),
                    isActive: $goToNext,
                    label: { EmptyView() }
                )
                NavigationLink(
                    destination: PreferenceQuestionsView(),
                    isActive: $navigateToPreferenceQuestions,
                    label: { EmptyView() }
                )
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedObjective = nil
            progress = 0.0
            goToNext = false
            navigateToPreferenceQuestions = false
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Définir ton objectif")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Où en es-tu pour le moment ?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var cardsSection: some View {
        VStack(spacing: 15) {
            ForEach(objectives, id: \.self) { option in
                SelectableCardView(
                    title: option,
                    isSelected: selectedObjective == option
                )
                .onTapGesture {
                    if selectedObjective == nil {
                        progress = min(progress + 0.1, 1.0)
                    }
                    selectedObjective = option
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SelectObjectiveView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                SelectObjectiveView()
                    .environmentObject(AuthViewModel())
                    .preferredColorScheme(.light)
                    .environment(\.dynamicTypeSize, .medium)
            }

            NavigationStack {
                SelectObjectiveView()
                    .environmentObject(AuthViewModel())
                    .preferredColorScheme(.dark)
                    .environment(\.dynamicTypeSize, .accessibility3)
            }
        }
    }
}
