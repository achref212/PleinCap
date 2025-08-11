import SwiftUI

struct NotesIntroView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double

    // Navigation states
    @State private var goToEntry  = false
    @State private var goToBourse = false

    var body: some View {
        VStack(spacing: 24) {
            // Top bar: back + progress
            HStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#1F3552"))
                        .padding(10)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                        .accessibilityLabel("Retour")
                }

                Spacer(minLength: 12)

                ProgressBarView(progress: $progress)
                    .frame(height: 18)
                    .accessibilityLabel("Progression")
            }
            .padding(.horizontal)

            // Title + subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Pour finir, j’aurais besoin de quelques-unes de tes notes")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))

                Text("Pas de stress : ce n’est pas pour te bloquer dans tes choix, mais pour mieux estimer tes chances d’être accepté dans les formations qui te plairont.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // Illustration
            Image("notes_illustration")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)
                .padding(.horizontal)
                .accessibilityHidden(true)

            // Card with explanation + action
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 10) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 3, height: 22)
                        .cornerRadius(1.5)

                    Text("Tu peux entrer manuellement tes notes et classements.")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#1F3552"))
                }

                PillOutlineButton(
                    title: "Entrer vos notes et classements",
                    systemImage: "pencil.and.outline"
                ) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    goToEntry = true          // 👉 open NotesEntryView
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            )
            .padding(.horizontal)

            Spacer(minLength: 8)

            // Primary “Suivant” ➜ BourseEligibilityView
            PrimaryGradientButton(title: "Suivant", enabled: true) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                goToBourse = true
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(
            LinearGradient(colors: [Color(.systemGroupedBackground), Color(.systemGroupedBackground)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .onAppear {
            if progress < 0.30 {
                withAnimation(.easeInOut(duration: 0.25)) { progress = 0.30 }
            }
        }
        // Hidden navigation links
        .background(
            Group {
                NavigationLink(isActive: $goToEntry) {
                    NotesEntryView(progress: $progress)
                        .environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()

                NavigationLink(isActive: $goToBourse) {
                    BourseEligibilityView(progress: $progress)
                        .environmentObject(authVM)
                } label: { EmptyView() }
                .hidden()
            }
        )
    }
}

// MARK: - Outlined pill button

private struct PillOutlineButton: View {
    let title: String
    let systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#F7931E"))
                    .accessibilityHidden(true)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

struct NotesIntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotesIntroView(progress: .constant(0.30))
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            NotesIntroView(progress: .constant(0.30))
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.dark)
    }
}
