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
    @StateObject private var formationVM = FormationViewModel()
    @StateObject private var authVM = AuthViewModel1() // ✅ Important : @StateObject
    @State private var showSplash = true

    var body: some Scene {
            WindowGroup {
                Group {
                                if showSplash {
                                    SplashScreenView {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            showSplash = false
                                        }
                                    }
                                } else {
                                    HomeView()              // your actual root view
                                }
                            }
                .environmentObject(authVM)
                .environmentObject(formationVM)
            }
        }
}
