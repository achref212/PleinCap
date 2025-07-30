//
//  ThemePickerView.swift
//  PFE_APP
//
//  Created by chaabani achref on 24/5/2025.
//
import SwiftUI

struct ThemePickerView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = AppColorScheme.system.rawValue

    var body: some View {
        Form {
            Section(header: Text("Apparence de l’application")) {
                Picker("Thème", selection: $selectedTheme) {
                    ForEach(AppColorScheme.allCases) { scheme in
                        Label(scheme.label, systemImage: scheme.icon)
                            .tag(scheme.rawValue)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Apparence")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
