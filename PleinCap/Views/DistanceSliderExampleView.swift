//
//  DistanceSliderExampleView.swift
//  PFE_APP
//
//  Created by chaabani achref on 9/6/2025.
//

import SwiftUI
struct DistanceSliderExampleView: View {
    @State private var distance: Double = 30

    var body: some View {
        VStack(spacing: 32) {
            DistanceSliderView(distance: $distance, maxDistance: 200)

            Text("Distance sélectionnée : \(Int(distance)) Km")
                .font(.title2.bold())
        }
        .padding()
    }
}
struct DistanceSliderViewa_Previews: PreviewProvider {
    @State static var previewDistance: Double = 50

    static var previews: some View {
        DistanceSliderExampleView()
            .preferredColorScheme(.light)

        DistanceSliderExampleView()
            .preferredColorScheme(.dark)
            .environment(\.dynamicTypeSize, .accessibility2)
    }
}
