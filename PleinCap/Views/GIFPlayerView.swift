//
//  GIFPlayerView.swift
//  PleinCap
//
//  Created by chaabani achref on 12/8/2025.
//
import SwiftUI
import ImageIO

struct GIFPlayerView: View {
    let name: String               // file in bundle WITHOUT ".gif"
    let cornerRadius: CGFloat

    @State private var frames: [CGImage] = []
    @State private var durations: [Double] = []
    @State private var totalDuration: Double = 0

    var body: some View {
        Group {
            if frames.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TimelineView(.animation) { context in
                    let t = context.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: max(totalDuration, 0.02))

                    let idx = frameIndex(for: t)
                    let ui = UIImage(cgImage: frames[idx])

                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .task { await decodeIfNeeded() }
    }

    private func frameIndex(for time: TimeInterval) -> Int {
        var acc = 0.0
        for (i, d) in durations.enumerated() {
            acc += d
            if time < acc { return i }
        }
        return max(durations.count - 1, 0)
    }

    @MainActor
    private func decodeIfNeeded() async {
        guard frames.isEmpty,
              let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let src = CGImageSourceCreateWithURL(url as CFURL, nil),
              CGImageSourceGetType(src) != nil else { return }

        let count = CGImageSourceGetCount(src)
        var newFrames: [CGImage] = []
        var newDurations: [Double] = []

        for i in 0..<count {
            guard let cg = CGImageSourceCreateImageAtIndex(src, i, nil) else { continue }
            newFrames.append(cg)

            var frameDuration: Double = 0.1
            if let props = CGImageSourceCopyPropertiesAtIndex(src, i, nil) as? [CFString: Any],
               let gif = props[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
                if let v = gif[kCGImagePropertyGIFUnclampedDelayTime] as? Double, v > 0 {
                    frameDuration = v
                } else if let v = gif[kCGImagePropertyGIFDelayTime] as? Double, v > 0 {
                    frameDuration = v
                }
            }
            newDurations.append(max(frameDuration, 0.02))
        }

        let sum = newDurations.reduce(0, +)
        frames = newFrames
        durations = newDurations
        totalDuration = max(sum, 0.02 * Double(newDurations.count))
    }
}
