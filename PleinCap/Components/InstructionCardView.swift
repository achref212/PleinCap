import SwiftUI

struct InstructionCardView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2)
                .padding(.top, 4)

            Text(text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#1D2B4F"))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#f0f0f0")) // ✅ fond doux légèrement coloré
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// Preview
struct InstructionCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionCardView(text: "Voici une liste d'adjectifs. Choisis 2 adjectifs qui te ressemblent le plus tel(le) que tu es et non pas tel(le) que tu voudrais être.")
                .preferredColorScheme(.light)

            InstructionCardView(text: "Voici une liste d'adjectifs. Choisis 2 adjectifs qui te ressemblent le plus tel(le) que tu es et non pas tel(le) que tu voudrais être.")
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
