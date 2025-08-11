import SwiftUI

struct SelectAcademieView: View {
    @EnvironmentObject var authVM: AuthViewModel1
    @Binding var progress: Double

    @StateObject private var dirVM = DirectoryViewModel()

    @State private var searchText: String = ""
    @State private var selectedAcademie: Academie? = nil
    @State private var goToEtablissements = false
    @State private var isSaving = false

    private let pageSize: Int = 4
    @State private var currentPage: Int = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Académie")
                    .font(.title.bold())
                    .foregroundColor(Color(hex: "#1F3552"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                // Search + map (same style as your original)
                searchAndMapCard

                // Meta + list + pagination
                listMeta
                listCard
                paginationBar

                // Hidden programmatic nav
                NavigationLink(destination: destinationView, isActive: $goToEtablissements) {
                    EmptyView()
                }
                .hidden()

                // Apply → save academie then push to établissements
                PrimaryGradientButton(
                    title: isSaving ? "Enregistrement…" : "Appliquer",
                    enabled: selectedAcademie != nil && !isSaving
                ) {
                    Task { await applySelectionAndProceed() }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if dirVM.academies.isEmpty { dirVM.fetchAcademies() }
        }
        .onChange(of: dirVM.academies.count) { _ in clampPage() }
        .onChange(of: searchText) { _ in currentPage = 1 }
        .onChange(of: filteredAcademies.count) { _ in clampPage() }
        .alert(item: $dirVM.errorMessage) { err in
            Alert(title: Text("Erreur"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Destination (extracted to keep compiler happy)

    private var destinationView: some View {
        Group {
            if let acad = selectedAcademie {
                // NOTE: SelectEtablissementView has a custom init that also takes authVM
                SelectEtablissementView(
                    academie: acad,
                    progress: $progress,
                    authVM: authVM
                )
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Search + Map

    private var searchAndMapCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                Rectangle().fill(Color.orange).frame(width: 3, height: 20).cornerRadius(1.5)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ta zone académique").font(.headline).foregroundColor(Color(hex: "#1F3552"))
                    Text("À quelle académie appartiens-tu ?").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
            }

            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Rechercher une académie ou ville", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(hex: "#EFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: 40))

            Image("carte_france")
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .accessibilityHidden(true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Meta

    private var listMeta: some View {
        HStack {
            if dirVM.isLoading { ProgressView().padding(.trailing, 6) }
            if totalResults > 0 {
                Text("Résultats: \(totalResults)  •  Page \(currentPage) / \(totalPages)")
                    .font(.footnote).foregroundColor(.secondary)
            } else if !dirVM.isLoading {
                Text("Aucune académie trouvée.")
                    .font(.footnote).foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - List

    private var listCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Rectangle().fill(Color.orange).frame(width: 4).cornerRadius(2)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Liste des académies").font(.headline).foregroundColor(Color(hex: "#1F3552"))
                    Text("Choisis ton académie dans la liste ci-dessous").font(.subheadline).foregroundColor(.secondary)
                }
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(displayedAcademies) { academie in
                        AcademieRow(
                            name: academie.name,
                            isSelected: selectedAcademie?.id == academie.id
                        )
                        .onTapGesture { selectedAcademie = academie }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: RowHeight) // ~4 rows
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var RowHeight: CGFloat { 360 }

    // MARK: - Pagination

    private var paginationBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { goPrevPage() }
            } label: {
                HStack(spacing: 8) { Image(systemName: "chevron.left") }
            }
            .buttonStyle(.bordered)
            .disabled(currentPage <= 1)

            Spacer()

            Text(rangeLabel).font(.footnote).foregroundColor(.secondary)

            Spacer()

            Button {
                withAnimation { goNextPage() }
            } label: {
                HStack(spacing: 6) { Image(systemName: "chevron.right") }
            }
            .buttonStyle(.bordered)
            .disabled(currentPage >= totalPages)
        }
    }

    private var rangeLabel: String {
        guard totalResults > 0 else { return "0–0 sur 0" }
        return "\(displayRange.lowerBound + 1)–\(displayRange.upperBound) sur \(totalResults)"
    }

    // MARK: - Data & Helpers

    private var filteredAcademies: [Academie] {
        let all = dirVM.academies
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private var totalResults: Int { filteredAcademies.count }

    private var totalPages: Int { max(1, Int(ceil(Double(totalResults) / Double(pageSize)))) }

    private var displayedAcademies: [Academie] {
        guard totalResults > 0 else { return [] }
        let start = (currentPage - 1) * pageSize
        let end = min(start + pageSize, totalResults)
        return Array(filteredAcademies[start..<end])
    }

    private var displayRange: (lowerBound: Int, upperBound: Int) {
        guard totalResults > 0 else { return (0, 0) }
        let start = (currentPage - 1) * pageSize
        let end = min(start + pageSize, totalResults)
        return (start, end)
    }

    private func clampPage() {
        if currentPage > totalPages { currentPage = totalPages }
        if currentPage < 1 { currentPage = 1 }
    }

    private func goPrevPage() { guard currentPage > 1 else { return }; currentPage -= 1 }
    private func goNextPage() { guard currentPage < totalPages else { return }; currentPage += 1 }

    // MARK: - Save + Navigate

    private func applySelectionAndProceed() async {
        guard let acad = selectedAcademie else { return }
        isSaving = true
        defer { isSaving = false }

        await withCheckedContinuation { continuation in
            authVM.updateUserFields(["academie": acad.name]) { result in
                switch result {
                case .success:
                    withAnimation {
                        // small bump so users see progress move forward
                        progress = max(progress, 0.85)
                        goToEtablissements = true
                    }
                    continuation.resume()
                case .failure(let error):
                    dirVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(error.localizedDescription)")
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Row

private struct AcademieRow: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle().fill(Color(hex: "#2EC1C1")).frame(width: 3).cornerRadius(2)
            Text(name).foregroundColor(Color(hex: "#1F3552")).font(.headline)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color(hex: "#2EC1C1"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isSelected ? Color(hex: "#E0FBFB") : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#2EC1C1"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

struct SelectAcademieView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.85
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            NavigationStack {
                SelectAcademieView(progress: $progress)
                    .environmentObject(authVM)
            }
        }
    }

    static var previews: some View {
        Group {
            Wrapper().preferredColorScheme(.light)
            Wrapper().preferredColorScheme(.dark)
        }
    }
}
