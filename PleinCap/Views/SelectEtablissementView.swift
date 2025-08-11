import SwiftUI

// MARK: - View

struct SelectEtablissementView: View {
    // Académie chosen previously
    let academie: Academie

    // Pass explicitly (no EnvironmentObject crash in previews)
    private let authVM: AuthViewModel1

    // Directory VM – injected or created with token provider
    @StateObject private var dirVM: DirectoryViewModel

    @Binding var progress: Double

    @State private var goToNext = false
    @State private var isSaving = false

    // MARK: Init
    init(
        academie: Academie,
        progress: Binding<Double>,
        authVM: AuthViewModel1,
        dirVM: DirectoryViewModel? = nil
    ) {
        self.academie = academie
        self.authVM = authVM
        _progress = progress
        if let provided = dirVM {
            _dirVM = StateObject(wrappedValue: provided)
        } else {
            _dirVM = StateObject(wrappedValue: DirectoryViewModel(authVM: authVM))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            searchCard
            content

            Spacer(minLength: 8)

            // Programmatic nav
            NavigationLink(
                destination: LocationPreferenceView(initialProgress: progress)
                    .environmentObject(authVM),
                isActive: $goToNext
            ) { EmptyView() }
            .hidden()

            applyButton
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Établissements – \(academie.name)")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: academie.id) {
            dirVM.pageSize = 4
            if dirVM.etablissements.isEmpty || dirVM.selectedAcademie?.id != academie.id {
                dirVM.fetchEtablissements(in: academie)
            }
        }
        .refreshable { dirVM.fetchEtablissements(in: academie) }
        .onChange(of: dirVM.searchText) { _ in
            // New search -> go back to page 0 safely
            dirVM.currentPage = 0
        }
        .onChange(of: dirVM.filteredEtablissements.count) { _ in
            clampPageToBounds()
        }
        .alert(item: $dirVM.errorMessage) { error in
            Alert(title: Text("Erreur"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Sections

    private var header: some View {
        Text("Sélectionne ton établissement")
            .font(.title2.bold())
            .foregroundColor(Color(hex: "#1F3552"))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 3, height: 20)
                    .cornerRadius(1.5)
                Text("Recherche")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))
                Spacer()
            }

            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Rechercher un établissement ou une ville", text: $dirVM.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(hex: "#EFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private var content: some View {
        if dirVM.isLoading {
            ProgressView("Chargement des établissements…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let err = dirVM.errorMessage?.message {
            Text("Erreur : \(err)")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            resultsMeta
            resultsList
            if !dirVM.filteredEtablissements.isEmpty { paginationBar }
        }
    }

    private var resultsMeta: some View {
        HStack {
            if dirVM.filteredEtablissements.isEmpty {
                Text("Aucun établissement trouvé.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                Text("Résultats: \(dirVM.filteredEtablissements.count)  •  Page \(dirVM.currentPage + 1) / \(max(dirVM.totalPages, 1))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(uniquePageItems, id: \.id) { etab in
                    EtablissementRow(
                        etablissement: etab.displayName,
                        subtitle: etab.city ?? "—",
                        isSelected: dirVM.selectedEtablissement?.id == etab.id
                    )
                    .onTapGesture { dirVM.selectedEtablissement = etab }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 360) // ~4 rows visible
    }

    private var paginationBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { safePrevPage() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Précédent")
                }
            }
            .buttonStyle(.bordered)
            .disabled(!(dirVM.currentPage > 0))

            Spacer()

            Text(rangeLabel)
                .font(.footnote)
                .foregroundColor(.secondary)

            Spacer()

            Button {
                withAnimation { safeNextPage() }
            } label: {
                HStack(spacing: 6) {
                    Text("Suivant")
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.bordered)
            .disabled(!(dirVM.currentPage + 1 < dirVM.totalPages))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var rangeLabel: String {
        let total = dirVM.filteredEtablissements.count
        guard total > 0 else { return "0–0 sur 0" }
        let start = max(0, dirVM.currentPage) * max(1, dirVM.pageSize)
        let end = min(start + dirVM.pageSize, total)
        return "\(min(start + 1, total))–\(end) sur \(total)"
    }

    private var applyButton: some View {
        PrimaryGradientButton(
            title: isSaving ? "Enregistrement…" : "Appliquer",
            enabled: dirVM.selectedEtablissement != nil && !isSaving
        ) {
            Task { await saveOnlyEtablissementAndProceed() }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    // MARK: - Paging helpers (defensive)

    private var uniquePageItems: [Etablissement] {
        dirVM.currentPageItems.unique(by: \.id)
    }

    private func clampPageToBounds() {
        let tp = dirVM.totalPages
        if tp <= 0 {
            dirVM.currentPage = 0
        } else if dirVM.currentPage >= tp {
            dirVM.currentPage = tp - 1
        } else if dirVM.currentPage < 0 {
            dirVM.currentPage = 0
        }
    }

    private func safeNextPage() {
        guard dirVM.currentPage + 1 < dirVM.totalPages else { return }
        dirVM.nextPage()
    }

    private func safePrevPage() {
        guard dirVM.currentPage > 0 else { return }
        dirVM.previousPage()
    }

    // MARK: - Actions

    private func saveOnlyEtablissementAndProceed() async {
        guard let etab = dirVM.selectedEtablissement else { return }
        isSaving = true
        defer { isSaving = false }

        let payload: [String: Any] = [
            "etablissement": etab.etablissement ?? etab.displayName
        ]

        await withCheckedContinuation { cont in
            authVM.updateUserFields(payload) { result in
                switch result {
                case .success:
                    withAnimation {
                        progress = max(progress, 0.9)
                        goToNext = true
                    }
                    cont.resume()
                case .failure(let err):
                    dirVM.errorMessage = ErrorMessage(message: "Erreur mise à jour : \(err.localizedDescription)")
                    cont.resume()
                }
            }
        }
    }
}

// MARK: - Row

private struct EtablissementRow: View {
    let etablissement: String
    let subtitle: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Rectangle().fill(Color(hex: "#2EC1C1")).frame(width: 3).cornerRadius(2)

            VStack(alignment: .leading, spacing: 2) {
                Text(etablissement)
                    .foregroundColor(Color(hex: "#1F3552"))
                    .font(.headline)
                    .lineLimit(2)
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }

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

// MARK: - Small utilities

private extension Array {
    /// Remove duplicates by a key path (stable first winner).
    func unique<T: Hashable>(by key: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        var result: [Element] = []
        result.reserveCapacity(count)
        for el in self {
            let k = el[keyPath: key]
            if seen.insert(k).inserted { result.append(el) }
        }
        return result
    }
}

// MARK: - Preview (no network)

struct SelectEtablissementView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.75
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            let mock = DirectoryViewModel()
            let seed: [Etablissement] = [
                Etablissement(id: 1, academieId: 1, etablissement: "Lycée Jean Jaurès", city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 2, academieId: 1, etablissement: "Lycée Jean Jaurès", city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 3, academieId: 1, etablissement: "Lycée Marie Curie", city: "Reims",   sector: "Public", track: "Technologique"),
                Etablissement(id: 4, academieId: 1, etablissement: "Lycée Victor Hugo", city: "Épernay", sector: "Privé",  track: "Général"),
                Etablissement(id: 5, academieId: 1, etablissement: "Lycée Gutenberg",   city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 6, academieId: 1, etablissement: "Lycée Blaise Pascal",city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 7, academieId: 1, etablissement: "Lycée Diderot",     city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 8, academieId: 1, etablissement: "Lycée Colbert",     city: "Reims",   sector: "Public", track: "Général"),
                Etablissement(id: 9, academieId: 1, etablissement: "Lycée Carnot",      city: "Reims",   sector: "Public", track: "Général")
            ]
            mock.etablissements = seed
            mock.filteredEtablissements = seed
            mock.pageSize = 4
            mock.currentPage = 0

            return NavigationStack {
                SelectEtablissementView(
                    academie: Academie(id: 1, name: "Reims", etablissements: nil),
                    progress: $progress,
                    authVM: authVM,
                    dirVM: mock
                )
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
