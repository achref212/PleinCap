import SwiftUI

struct SplashScreenView: View {
    let onFinish: () -> Void                       // callback
    @State private var launched = false            // évite doublon
    @State private var animate = false
    private let duration: TimeInterval = 2.5

    var body: some View {
        ZStack {
            CircleBackgroundView()

            Image("PLogo 2")                       // ton logo
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0.8)
                .animation(.easeOut(duration: 0.8), value: animate)
        }
        .ignoresSafeArea()
        .task {
            guard !launched else { return }
            launched = true
            animate = true
            try? await Task.sleep(for: .seconds(duration))
            onFinish()
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
