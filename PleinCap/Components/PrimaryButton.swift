//
//  PrimaryButton.swift
//  PFE_APP
//
//  Created by chaabani achref on 22/5/2025.
//
import SwiftUI

struct PrimaryGradientButton: View {
    var title: String
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: {
            if enabled { action() }
        }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if enabled {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2EC1C1"),   // Teal principal
                                    Color(hex: "#00B8B8"),   // plus foncé
                                    Color(hex: "#6EE9E9")    // plus clair
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(color: enabled ? Color(hex: "#2EC1C1").opacity(0.4) : .clear, radius: 6, x: 0, y: 3)
        }
        .disabled(!enabled)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                PrimaryGradientButton(title: "Suivant", enabled: true) {
                    print("✅ Action exécutée")
                }

                PrimaryGradientButton(title: "Suivant", enabled: false) {
                    print("⛔️ Action désactivée")
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .previewDisplayName("Light Mode")
            .preferredColorScheme(.light)

            VStack(spacing: 20) {
                PrimaryGradientButton(title: "Suivant", enabled: true) {}
                PrimaryGradientButton(title: "Suivant", enabled: false) {}
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .previewDisplayName("Dark + Accessibilité")
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}
