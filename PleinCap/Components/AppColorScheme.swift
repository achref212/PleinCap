//
//  AppColorScheme.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/5/2025.
//
import SwiftUI

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var toColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "Système"
        case .light: return "Clair"
        case .dark: return "Sombre"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
