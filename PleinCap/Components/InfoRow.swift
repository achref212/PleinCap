//
//  InfoRow.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text("•")
            Text("\(Text(title).bold()) : \(Text(value).foregroundColor(.gray))")
                .font(.subheadline)
        }
    }
}
