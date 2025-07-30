//
//  MainTabView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/5/2025.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject var authVM: AuthViewModel
    var onLogout: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔹 Top Bar personnalisée
                HStack {
                    // 📌 Logo
                    Image("PLogo 1") // Assure-toi que ce logo est bien dans tes Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)

                    Spacer()

                    // 📌 Titre centré
                    Text(titleForTab(selectedTab))
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))

                    Spacer()

                    // 📌 Menu
                    Menu {
                        Button(action: {
                            print("⚙️ Paramètres")
                        }) {
                            Label("Paramètres", systemImage: "gearshape")
                        }

                        Button(role: .destructive, action: {
                            onLogout()
                        }) {
                            Label("Déconnexion", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)

                // 🔹 Onglets principaux
                TabView(selection: $selectedTab) {
                    FormationsView()
                        .tabItem {
                            Label("Accueil", systemImage: "house.fill")
                        }
                        .tag(0)

                    ChatBotView()
                        .tabItem {
                            Label("Assistant", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .tag(1)

                    PredictionView()
                        .tabItem {
                            Label("Prédictions", systemImage: "chart.bar.fill")
                        }
                        .tag(2)

                    ProfileView(authVM: authVM, onLogout: onLogout)
                        .tabItem {
                            Label("Profil", systemImage: "person.crop.circle")
                        }
                        .tag(3)
                }
                .accentColor(.accentColor)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func titleForTab(_ index: Int) -> String {
        switch index {
        case 0: return "Accueil"
        case 1: return "Assistant"
        case 2: return "Prédictions"
        case 3: return "Profil"
        default: return ""
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    @State static var tab = 0
    static var previews: some View {
        let vm = AuthViewModel()
        vm.userProfile = .preview

        return Group {
            MainTabView(selectedTab: $tab, authVM: vm, onLogout: {})
                .preferredColorScheme(.light)

            MainTabView(selectedTab: $tab, authVM: vm, onLogout: {})
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility2)
        }
    }
}
