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
    @StateObject private var viewModel = FormationViewModel()
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Bonjour 👋 Je suis Louki, ton assistant d'orientation ! Pose-moi une question pour t'aider dans ton parcours.",
            isUser: false,
            suggestedFormations: nil
        )
    ]
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
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

                                            if isLoading && messages.last?.id == message.id {
                                                ProgressView()
                                                    .padding(12)
                                            } else {
                                                Text(message.text)
                                                    .foregroundColor(.gray)
                                                    .padding(12)
                                                    .background(Color.cyan.opacity(0.1))
                                                    .cornerRadius(20)
                                                    .frame(maxWidth: 250, alignment: .leading)

                                                if let suggestions = message.suggestedFormations {
                                                    VStack(spacing: 12) {
                                                        ForEach(suggestions) { formation in
                                                            NavigationLink(destination: FormationDetailsView(formationId: formation.id)) {
                                                                VStack(alignment: .leading, spacing: 4) {
                                                                    HStack(spacing: 8) {
                                                                        Rectangle()
                                                                            .fill(Color.orange)
                                                                            .frame(width: 4, height: 24)
                                                                            .cornerRadius(2)
                                                                        VStack(alignment: .leading) {
                                                                            Text(formation.titre)
                                                                                .font(.headline)
                                                                                .foregroundColor(Color(hex: "#1D2B4F"))
                                                                            Text(formation.etablissement)
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
                                                    }
                                                    .padding(.top, 8)
                                                }
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
                                if let lastMessage = messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
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
            .navigationTitle("Louki Chat")
            .onAppear {
                viewModel.fetchFormations()
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMessage = ChatMessage(text: userInput, isUser: true, suggestedFormations: nil)
        messages.append(userMessage)

        isLoading = true
        let lower = userInput.lowercased()

        if lower.contains("formation") || lower.contains("droit") || lower.contains("orientation") {
            // ✅ Appel correct avec une seule closure
            viewModel.fetchFormations(completion: { (result: Result<[Formation], Error>) in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let formations):
                        let responseMessage = ChatMessage(
                            text: "Voici quelques suggestions que j’ai trouvées pour toi :",
                            isUser: false,
                            suggestedFormations: Array(formations.prefix(2))
                        )
                        messages.append(responseMessage)
                    case .failure(let error):
                        let errorMessage = ChatMessage(
                            text: "Désolé, je n’ai pas pu trouver de suggestions : \(error.localizedDescription)",
                            isUser: false,
                            suggestedFormations: nil
                        )
                        messages.append(errorMessage)
                    }
                }
            })
        } else {
            isLoading = false
            let responseMessage = ChatMessage(
                text: "Merci pour ta question ! Je vais y réfléchir…",
                isUser: false,
                suggestedFormations: nil
            )
            messages.append(responseMessage)
        }

        userInput = ""
    }
}

// ... (FormationViewModel extension remains unchanged)

#Preview {
    LoukiChatbotView()
        .environmentObject(FormationViewModel())
}
