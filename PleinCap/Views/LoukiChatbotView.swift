//
//  LoukiChatbotView.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let suggestedFormations: [Formation]?
}

struct LoukiChatbotView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Bonjour 👋 Je suis Louki, ton assistant d'orientation ! Pose-moi une question pour t'aider dans ton parcours.",
            isUser: false,
            suggestedFormations: nil
        )
    ]

    @State private var userInput: String = ""

    let suggestedFormations: [Formation] = [
        Formation(
            title: "Licence en Droit",
            university: "Université Paris 1 Panthéon-Sorbonne",
            description: "",
            location: "Paris",
            price: "Gratuite",
            duration: "3 ans",
            isPublic: true,
            domain: "Droit",
            imageName: "Etablissement_France1"
        ),
        Formation(
            title: "Licence en Droit",
            university: "Université Paris 1 Panthéon-Sorbonne",
            description: "",
            location: "Paris",
            price: "Gratuite",
            duration: "3 ans",
            isPublic: true,
            domain: "Droit",
            imageName: "Etablissement_France1"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image("Louki")
                    .resizable()
                    .frame(width: 65, height: 65)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Louki")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#1D2B4F"))
                    Text("Assistant d'orientation")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            HStack(alignment: .top) {
                                if message.isUser {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 30, height: 30)
                                            .padding(.bottom, 4)
                                        HStack {
                                            Text(message.text)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Color.blue)
                                                .cornerRadius(20)
                                        }
                                        .frame(maxWidth: 250, alignment: .trailing)

                                       
                                    }
                                } else {
                                    VStack(alignment: .leading) {
                                        Image("Louki")
                                            .resizable()
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                            .padding(.bottom, 4)

                                        Text(message.text)
                                            .foregroundColor(.gray)
                                            .padding(12)
                                            .background(Color.cyan.opacity(0.1))
                                            .cornerRadius(20)
                                            .frame(maxWidth: 250, alignment: .leading)

                                        if let suggestions = message.suggestedFormations {
                                            VStack(spacing: 12) {
                                                ForEach(suggestions) { formation in
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        HStack(spacing: 8) {
                                                            Rectangle()
                                                                .fill(Color.orange)
                                                                .frame(width: 4, height: 24)
                                                                .cornerRadius(2)
                                                            VStack(alignment: .leading) {
                                                                Text(formation.title)
                                                                    .font(.headline)
                                                                    .foregroundColor(Color(hex: "#1D2B4F"))
                                                                Text(formation.university)
                                                                    .font(.subheadline)
                                                                    .foregroundColor(.gray)
                                                            }
                                                        }
                                                    }
                                                    .padding()
                                                    .background(Color.cyan.opacity(0.1))
                                                    .cornerRadius(20)
                                                }
                                            }
                                            .padding(.top, 8)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)
                        }
                    }
                    .padding(.vertical)
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                TextField("Pose ta question", text: $userInput)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.cyan, lineWidth: 1)
                    )
                Button(action: sendMessage) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .font(.title3))
                }
            }
            .padding(.all, 16)
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        messages.append(ChatMessage(text: userInput, isUser: true, suggestedFormations: nil))

        let lower = userInput.lowercased()
        if lower.contains("formation") || lower.contains("droit") || lower.contains("orientation") {
            messages.append(ChatMessage(
                text: "Voici quelques suggestions que j’ai trouvées pour toi :",
                isUser: false,
                suggestedFormations: suggestedFormations
            ))
        } else {
            messages.append(ChatMessage(
                text: "Merci pour ta question ! Je vais y réfléchir…",
                isUser: false,
                suggestedFormations: nil
            ))
        }

        userInput = ""
    }
}

#Preview {
    LoukiChatbotView()
}
