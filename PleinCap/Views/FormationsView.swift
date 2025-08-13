import SwiftUI

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct FormationsView: View {
    // Existing formations source
    @StateObject private var viewModel = FormationViewModel()

    // 🔌 SQLAgent for recommendations (use your LAN IP on device)
    @StateObject private var recoVM: RecommendationsViewModel

    // User / Agent config
    private let userID: Int
    @State private var topK: Int

    // Predefined set of 10 random images
    private let randomImages = [
        "image1","image2","image3","image4","image5",
        "image6","image7","image8","image9","image10"
    ]

    // Inject config (assistantID/deviceLAN are passed into the SQLAgentService)
    init(userID: Int = 7, initialTopK: Int = 10, assistantID: String = "my_agent", deviceLAN: String? = nil) {
        self.userID = userID
        _topK = State(initialValue: initialTopK)

        let cfg = SQLAgentConfig.default(assistantID: assistantID, deviceLAN: deviceLAN)
        let service = SQLAgentService(config: cfg)
        _recoVM = StateObject(wrappedValue: RecommendationsViewModel(service: service))
    }

    // Use recommendations if we have them; preserve returned order inside groups
    private var groupedFormations: [String: [Formation]] {
        let source: [Formation]
        if !recoVM.recommendedIDs.isEmpty {
            let order = Dictionary(uniqueKeysWithValues: recoVM.recommendedIDs.enumerated().map { ($0.element, $0.offset) })
            source = viewModel.formations.filter { order[$0.id] != nil }
            return Dictionary(grouping: source, by: { $0.typeFormation ?? "Unknown" })
                .mapValues { arr in arr.sorted { (order[$0.id] ?? .max) < (order[$1.id] ?? .max) } }
        } else {
            source = viewModel.formations
            return Dictionary(grouping: source, by: { $0.typeFormation ?? "Unknown" })
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F4F6F8").ignoresSafeArea()
                CircleBackgroundBottomView()

                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    if !recoVM.isConnected || recoVM.errorMessage != nil {
                        connectionBanner
                    }
                    contentSection
                }
            }
            .navigationBarTitle("Formations", displayMode: .inline)
        }
        .onAppear {
            viewModel.fetchFormations()
            Task { await recoVM.connect() }
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .alert(item: $recoVM.errorMessage) { error in
            Alert(title: Text("Reco Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Header with action

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommandations pour Vous")
                        .font(.title2.bold())
                        .foregroundColor(Color(hex: "#00B8D9"))
                    Text("Basées sur ton profil et tes centres d'intérêt")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if recoVM.isLoading {
                    ProgressView()
                        .padding(.trailing, 4)
                }
            }

            // Top-K & action
            HStack(spacing: 12) {
                Picker("Nombre", selection: $topK) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)

                Button {
                    Task { await recoVM.recommendForUser(userID: userID, topK: topK) }
                } label: {
                    Label("Recommander pour moi", systemImage: "sparkles")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.borderedProminent)
                .disabled(!recoVM.isConnected || recoVM.isLoading)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Connection banner

    private var connectionBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: recoVM.errorMessage == nil ? "wifi" : "xmark.octagon.fill")
                .foregroundColor(recoVM.errorMessage == nil ? .accentColor : .red)
            Text(recoVM.errorMessage?.message ?? "Connexion à l’agent…")
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
            Spacer()
            Button("Réessayer") {
                Task { await recoVM.connect() }
            }
            .font(.footnote)
        }
        .padding(8)
        .background(Color.yellow.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    // MARK: - Content

    private var contentSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // If recommendations are available, we show only those (already filtered in groupedFormations)
                ForEach(groupedFormations.sorted(by: { $0.key < $1.key }), id: \.key) { typeFormation, items in
                    formationGroupSection(typeFormation: typeFormation, items: items)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func formationGroupSection(typeFormation: String, items: [Formation]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(typeFormation)
                .font(.title3.bold())
                .foregroundColor(Color(hex: "#2C4364"))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(Array(items.enumerated()), id: \.1.id) { index, formation in
                        navigationLinkForFormation(index: index, formation: formation)
                            .overlay(alignment: .topLeading) {
                                if !recoVM.recommendedIDs.isEmpty && recoVM.recommendedIDs.contains(formation.id) {
                                    Text("Recommandé")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.9))
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                        .padding(8)
                                }
                            }
                    }
                }
                .padding(.trailing, 20)
            }
        }
    }

    private func navigationLinkForFormation(index: Int, formation: Formation) -> some View {
        NavigationLink(destination: FormationDetailsView(formationId: formation.id)) {
            formationCardView(index: index, formation: formation)
        }
    }

    private func formationCardView(index: Int, formation: Formation) -> some View {
        let imageName = randomImages[index % randomImages.count]
        let image = Image(imageName)
        let university = formation.etablissement
        let description = formation.resumeProgramme ?? "No description available"
        let location = formation.lieu?.ville ?? "Unknown location"
        let price = formation.prixAnnuel ?? 0
        let duration = formation.duree ?? "N/A"
        let isPublic = formation.formationControleeParEtat ?? false

        return FormationCardView(
            image: image,
            title: formation.titre,
            university: university,
            description: description,
            location: location,
            price: price,
            duration: duration,
            isPublic: isPublic
        )
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .padding(.leading, index == 0 ? 16 : 0)
    }
}

// MARK: - Small helpers

private extension String {
    func trimmed() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}


#Preview {
    FormationsView()
}
