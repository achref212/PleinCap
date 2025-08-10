//
//  PleinCapApp.swift
//  PleinCap
//
//  Created by chaabani achref on 30/7/2025.
//

import SwiftUI
import SwiftData

@main
struct PleinCapApp: App {
    @AppStorage("selectedTheme") private var selectedTheme: String = AppColorScheme.system.rawValue
    @StateObject var locationManager = LocationManager()
    @StateObject private var authVM = AuthViewModel1() // ✅ Important : @StateObject

    var body: some Scene {
            WindowGroup {
                NavigationStack {
                    HomeView() // ou n’importe quelle vue de départ
                }
                .environmentObject(authVM) // ✅ Injecté ici globalement
            }
        }
}
