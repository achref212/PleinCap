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

    var body: some Scene {
            WindowGroup {
                HomeView()

            }
        }
}
