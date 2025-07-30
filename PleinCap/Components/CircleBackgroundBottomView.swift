import SwiftUI

struct CircleBackgroundBottomView: View {
    var body: some View {
        ZStack {
            // Grand cercle en bas à gauche
            Circle()
                .stroke(Color(hex: "#D6F4F8"), lineWidth: 1)
                .frame(width: 300)
                .offset(x: -140, y: 280)

            Circle()
                .fill(Color(hex: "#EDF4F6").opacity(0.7))
                .frame(width: 280)
                .offset(x: -130, y: 300)

            // Petit cercle en haut à droite
            Circle()
                .stroke(Color(hex: "#D6F4F8"), lineWidth: 1)
                .frame(width: 180)
                .offset(x: 140, y: -400)
        }
    }
}
