import SwiftUI

struct StatusCardView<Icon: View>: View {
    let icon: Icon
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            icon
                .frame(width: 40, height: 40)

            Text(title)
                .font(.title3.bold())
                .foregroundColor(Color(hex:"#2C4364"))
                .multilineTextAlignment(.center)

            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
        .dynamicTypeSize(.medium ... .accessibility4)
    }
}
