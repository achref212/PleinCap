import SwiftUI

struct RangeSliderView: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let handleSize: CGFloat = 28
    private let trackHeight: CGFloat = 8

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                .background(Color.white)
                .cornerRadius(24)

            HStack(spacing: 12) {
                // Min Label
                Text("\(Int(minValue))k€")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#2C4364"))

                // Slider
                GeometryReader { geometry in
                    let sliderWidth = geometry.size.width - handleSize
                    let minOffset = CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * sliderWidth
                    let maxOffset = CGFloat((maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * sliderWidth

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: trackHeight)

                        Capsule()
                            .fill(Color(hex: "#17C1C1")) // Turquoise
                            .frame(width: maxOffset - minOffset, height: trackHeight)
                            .offset(x: minOffset)

                        // Left handle
                        Circle()
                            .fill(Color(hex: "#17C1C1"))
                            .frame(width: handleSize, height: handleSize)
                            .offset(x: minOffset)
                            .gesture(DragGesture().onChanged { value in
                                let percent = max(0, min(1, (value.location.x - handleSize / 2) / sliderWidth))
                                let newMin = round(range.lowerBound + percent * (range.upperBound - range.lowerBound))
                                if newMin <= maxValue {
                                    minValue = newMin
                                }
                            })

                        // Right handle
                        Circle()
                            .fill(Color(hex: "#17C1C1"))
                            .frame(width: handleSize, height: handleSize)
                            .offset(x: maxOffset)
                            .gesture(DragGesture().onChanged { value in
                                let percent = max(0, min(1, (value.location.x - handleSize / 2) / sliderWidth))
                                let newMax = round(range.lowerBound + percent * (range.upperBound - range.lowerBound))
                                if newMax >= minValue {
                                    maxValue = newMax
                                }
                            })
                    }
                    .frame(height: handleSize)
                }
                .frame(height: handleSize)

                // Max Label
                Text("\(Int(maxValue))k€")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#2C4364"))
            }
            .padding(.horizontal)
        }
        .frame(height: 80)
        .padding(.horizontal)
    }
}

struct RangeSliderView_Previews: PreviewProvider {
    @State static var min: Double = 20
    @State static var max: Double = 90

    static var previews: some View {
        Group {
            RangeSliderView(minValue: $min, maxValue: $max, range: 0...100)
                .preferredColorScheme(.light)
                .previewLayout(.sizeThatFits)

            RangeSliderView(minValue: $min, maxValue: $max, range: 0...100)
                .preferredColorScheme(.dark)
                .environment(\.dynamicTypeSize, .accessibility3)
                .previewLayout(.sizeThatFits)
        }
    }
}
