import SwiftUI

struct CircleBackgroundView: View {
    var body: some View {
        ZStack {
            Color("PrimaryBackground") // définit dans Assets.xcassets, ex: turquoise

            // Cercles en haut à gauche
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 250, height: 250)
                .offset(x: -170, y: -300)

            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: 230, height: 230)
                .offset(x: -140, y: -280)

            // Cercles en haut à droite
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 260, height: 260)
                .offset(x: 160, y: -310)

            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: 240, height: 240)
                .offset(x: 129, y: -290)

            // Cercle bas gauche
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 350, height: 350)
                .offset(x: -180, y: 400)

            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .frame(width: 320, height: 320)
                .offset(x: -180, y: 400)

            // Cercle bas droite
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 120, height: 120)
                .offset(x: 150, y: 430)

            // Petits points décoratifs
            Group {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 8)
                    .offset(x: -140, y: -90)

                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 8)
                    .offset(x: 110, y: 30)

                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 8)
                    .offset(x: 180, y: 460)

                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 8)
                    .offset(x: -100, y: 520)
            }
        }
        .ignoresSafeArea()
    }
}

struct CircleBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        CircleBackgroundView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}
