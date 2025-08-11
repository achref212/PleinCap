import SwiftUI

struct SplashScreenView: View {
    let onFinish: () -> Void

    // Animation state
    @State private var launched = false
    @State private var showLogo = false
    @State private var startRipples = false
    @State private var showSubtitle = false

    // How long to keep the splash before calling onFinish
    private let duration: TimeInterval = 2.5

    var body: some View {
        ZStack {
            // Your existing background (kept as-is)
            CircleBackgroundView()
                .ignoresSafeArea()

            // Animated ripples behind the logo
            ZStack {
                RipplePulse(isAnimating: startRipples, lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .opacity(0.55)

                RipplePulse(isAnimating: startRipples, lineWidth: 2, delay: 0.35)
                    .frame(width: 260, height: 260)
                    .opacity(0.35)
            }
            .allowsHitTesting(false)

            // Logo + subtitle
            VStack(spacing: 14) {
                Image("PLogo 2")                 // your logo asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(showLogo ? 1 : 0.8)
                    .opacity(showLogo ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.05), value: showLogo)

            }
        }
        .task {
            guard !launched else { return }
            launched = true

            // sequence
            showLogo = true
            startRipples = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                showSubtitle = true
            }

            // end
            try? await Task.sleep(for: .seconds(duration))
            onFinish()
        }
    }
}

/// Expanding + fading circle stroke you can reuse anywhere
private struct RipplePulse: View {
    let isAnimating: Bool
    var lineWidth: CGFloat = 2
    var delay: Double = 0

    @State private var scale: CGFloat = 0.6
    @State private var alpha: CGFloat = 0.6

    var body: some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.9), lineWidth: lineWidth)
            .scaleEffect(scale)
            .opacity(alpha)
            .onChange(of: isAnimating) { newValue in
                guard newValue else { return }
                animate()
            }
            .onAppear {
                if isAnimating { animate() }
            }
    }

    private func animate() {
        // reset
        scale = 0.6
        alpha = 0.6

        withAnimation(.easeOut(duration: 1.2).delay(delay).repeatForever(autoreverses: false)) {
            scale = 1.6
            alpha = 0
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView(onFinish: {})
            .preferredColorScheme(.light)

        SplashScreenView(onFinish: {})
            .preferredColorScheme(.dark)
    }
}
