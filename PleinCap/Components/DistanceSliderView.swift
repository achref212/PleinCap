//
//  DistanceSliderView.swift
//  PFE_APP
//
//  Created by chaabani achref on 9/6/2025.
//

import SwiftUI

struct DistanceSliderView: View {
    @Binding var distance: Double
    let maxDistance: Double

    var body: some View {
        HStack {
            Slider(value: $distance, in: 0...maxDistance, step: 1)
                .accentColor(Color.cyan)
                .padding(.leading)

            Text("\(Int(distance))Km")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
}

struct DistanceSliderView_Previews: PreviewProvider {
    @State static var distance: Double = 70

    static var previews: some View {
        Group {
            DistanceSliderView(distance: $distance, maxDistance: 100)
                .preferredColorScheme(.light)

            DistanceSliderView(distance: $distance, maxDistance: 100)
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility2)
        }
        .previewLayout(.sizeThatFits)
    }
}
