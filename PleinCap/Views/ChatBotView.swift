//
//  ChatBotView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/5/2025.
//

import SwiftUI

struct ChatBotView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var messages: [Message] = [
        Message(text: "Bonjour, comment puis-je vous aider ?", fromUser: false)
    ]
    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.fromUser { Spacer() }
                                Text(msg.text)
                                    .padding(12)
                                    .foregroundColor(msg.fromUser ? .white : .primary)
                                    .background(
                                        msg.fromUser
                                        ? Color.accentColor
                                        : Color(UIColor.secondarySystemBackground)
                                    )
                                    .cornerRadius(16)
                                    .frame(maxWidth: 280, alignment: msg.fromUser ? .trailing : .leading)
                                    .id(msg.id)
                                if !msg.fromUser { Spacer() }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Votre message…", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.none)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding(10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Assistant")
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func sendMessage() {
        let clean = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        messages.append(Message(text: clean, fromUser: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.append(Message(text: "Merci pour votre message.", fromUser: false))
        }
        inputText = ""
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let fromUser: Bool
}


struct ChatBotView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ChatBotView()
            }
            .preferredColorScheme(.light)

            NavigationView {
                ChatBotView()
            }
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility3)
        }
    }
}

