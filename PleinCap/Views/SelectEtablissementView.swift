import SwiftUI

struct SelectEtablissementView: View {
    let academie: Academie
    private let authVM: AuthViewModel1
    @StateObject private var dirVM: DirectoryViewModel
    @Binding var progress: Double

    @State private var goToNext = false
    @State private var isSaving = false
    private struct IsPreviewKey: EnvironmentKey {
        static let defaultValue: Bool = false
    }
    private var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
   

    init(academie: Academie, progress: Binding<Double>, authVM: AuthViewModel1) {
        self.academie = academie
        self.authVM = authVM
        _progress = progress
        _dirVM = StateObject(wrappedValue: DirectoryViewModel(authVM: authVM))
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            searchCard
            content

            Spacer(minLength: 8)

            NavigationLink(destination: destinationView, isActive: $goToNext) { EmptyView() }
                .hidden()

            applyButton
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Établissements – \(academie.name)")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: academie.id) {
            // ✅ Never call real network in previews
            guard !isPreview else { return }
            dirVM.pageSize = 4
            dirVM.fetchEtablissements(in: academie)
        }
        .onReceive(dirVM.$etablissements) { _ in
            dirVM.currentPage = 0
        }
        .refreshable {
            guard !isPreview else { return }
            dirVM.fetchEtablissements(in: academie)
        }
        .alert(item: $dirVM.errorMessage) { error in
            Alert(title: Text("Erreur"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    private var destinationView: some View {
        LocationPreferenceView(initialProgress: progress)
            .environmentObject(authVM)
    }

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
                Rectangle().fill(Color.orange).frame(width: 3, height: 20).cornerRadius(1.5)
                Text("Recherche").font(.headline).foregroundColor(Color(hex: "#1F3552"))
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
        } else if dirVM.filteredEtablissements.isEmpty {
            Text("Aucun établissement trouvé pour « \(academie.name) ».")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        } else {
            resultsMeta
            resultsList
            paginationBar
        }
    }

    private var resultsMeta: some View {
        HStack {
            Text("Résultats: \(dirVM.filteredEtablissements.count)  •  Page \(dirVM.currentPage + 1) / \(max(dirVM.totalPages, 1))")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var resultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(dirVM.currentPageItems, id: \.id) { etab in
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
        .frame(maxHeight: 360)
    }

    private var paginationBar: some View {
        HStack(spacing: 12) {
            Button { withAnimation { dirVM.previousPage() } } label: {
                HStack(spacing: 6) { Image(systemName: "chevron.left"); Text("Précédent") }
            }
            .buttonStyle(.bordered)
            .disabled(!(dirVM.currentPage > 0))

            Spacer()

            Text(rangeLabel).font(.footnote).foregroundColor(.secondary)

            Spacer()

            Button { withAnimation { dirVM.nextPage() } } label: {
                HStack(spacing: 6) { Text("Suivant"); Image(systemName: "chevron.right") }
            }
            .buttonStyle(.bordered)
            .disabled(!(dirVM.currentPage + 1 < dirVM.totalPages))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
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

    private var rangeLabel: String {
        let total = dirVM.filteredEtablissements.count
        guard total > 0 else { return "0–0 sur 0" }
        let start = dirVM.currentPage * dirVM.pageSize
        let end = min(start + dirVM.pageSize, total)
        return "\(start + 1)–\(end) sur \(total)"
    }

    private func saveOnlyEtablissementAndProceed() async {
        guard let etab = dirVM.selectedEtablissement else { return }
        isSaving = true
        defer { isSaving = false }
        let payload: [String: Any] = ["etablissement": etab.etablissement ?? etab.displayName]

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
                Text(etablissement).foregroundColor(Color(hex: "#1F3552")).font(.headline).lineLimit(2)
                Text(subtitle).foregroundColor(.secondary).font(.subheadline)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill").imageScale(.medium).foregroundColor(Color(hex: "#2EC1C1"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isSelected ? Color(hex: "#E0FBFB") : .white)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#2EC1C1"), lineWidth: 1))
        )
    }
}

// MARK: - Preview

struct SelectEtablissementView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var progress: Double = 0.75
        @StateObject var authVM = AuthViewModel1()

        var body: some View {
            // ✅ local mock data only; no network
          
            return NavigationStack {
                SelectEtablissementView(
                    academie: Academie(id: 1, name: "Versailles", etablissements:nil),
                    progress: $progress,
                    authVM: authVM
                )
                .environmentObject(authVM)
                .onAppear {
                    // Seed the VM used inside the view
                    // (Populate through the dirVM since it's @StateObject inside)
                }
            }
        }
    }

    static var previews: some View {
        Wrapper().preferredColorScheme(.light)
        Wrapper().preferredColorScheme(.dark)
    }
}
