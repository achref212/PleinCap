import SwiftUI

struct OrientationChoicesView: View {
    @EnvironmentObject var authVM: AuthViewModel1

    // Local selections
    @State private var selectedDomains: [String] = []
    @State private var selectedSectors: [String] = []
    @State private var selectedTrainingTypes: [String] = []

    // UI state
    @State private var saving = false
    @State private var goToClarify = false
    @State private var localError: String?

    // Progress (tweak if you want)
    @State private var progress: Double = 0.2

    // MARK: - Options
    private let domainOptions: [String] = [
        "Mathématiques","Physique / Chimie","Sciences de la vie / Biologie","Informatique / Numérique",
        "Économie / Gestion","Sciences sociales (socio, géo, anthropo, etc.)","Histoire / Géopolitique",
        "Philosophie / Pensée critique","Langues / Cultures étrangères","Littérature / Français",
        "Art / Design / Architecture","Musique / Théâtre / Cinéma","Sport / STAPS","Médecine / Santé / Soins",
        "Droit / Justice / Notariat","Sciences politiques / Relations internationales",
        "Environnement / Climat / Développement durable","Éducation / Pédagogie",
        "Psychologie / Accompagnement humain","Ingénierie / Sciences appliquées",
        "Métiers techniques / pratiques (électricité, BTP, mécanique…)","Je ne sais pas encore"
    ]

    private let sectorOptions: [String] = [
        "Santé / médecine / soins","Enseignement / éducation","Droit / justice / notariat",
        "Informatique / cybersécurité / IA","Communication / journalisme / médias",
        "Art / design / création visuelle","Architecture / urbanisme","Cinéma / musique / spectacle",
        "Sport / entraînement / coaching","Environnement / développement durable",
        "Relations internationales / diplomatie","Sciences / recherche / innovation",
        "Ingénierie / industrie","BTP / travaux / énergie","Métiers manuels (électricité, plomberie, etc.)",
        "Commerce / vente / marketing","Management / entrepreneuriat",
        "Psychologie / accompagnement humain","Transport / logistique / aviation",
        "Armée / sécurité / gendarmerie","Animation / travail social","Je ne sais pas encore"
    ]

    private let trainingOptions: [String] = [
        "Licence à l’université (bac+3)","BUT (ex-DUT, bac+3)","BTS (bac+2)","CPGE (classes prépas)",
        "Écoles d’ingénieurs","Écoles de commerce / management","Écoles d’art / design",
        "Écoles d’architecture","Écoles de journalisme / communication","PASS / LAS (accès santé)",
        "Écoles paramédicales (IFSI, ergo, kiné…)","STAPS","Écoles de théâtre / cinéma / musique",
        "Écoles de cuisine / hôtellerie","Formations sportives (BPJEPS…)","DEUST / autres formations courtes pro (bac+2)",
        "Formations sociales / éducatives","Écoles de droit / sciences politiques",
        "Formations dans l’armée / sécurité","Apprentissage (en école ou CFA)","Formations à distance",
        "Je ne sais pas encore"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("On affine ton orientation")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#2C4364"))
                    ProgressView(value: progress).tint(.accentColor)
                }
                .padding(.horizontal)

                // Menus
                selectionGroup(
                    title: "Domaine(s) de formation qui t’intéresse(nt)",
                    options: domainOptions,
                    selection: $selectedDomains
                )

                selectionGroup(
                    title: "Domaine(s) de métier(s) / secteur(s) d’activité",
                    options: sectorOptions,
                    selection: $selectedSectors
                )

                selectionGroup(
                    title: "Type(s) de formation visée",
                    options: trainingOptions,
                    selection: $selectedTrainingTypes
                )

                // Error
                if let err = localError {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // Continue
                VStack(spacing: 10) {
                    Button {
                        saveAndContinue()
                    } label: {
                        HStack {
                            if saving { ProgressView().padding(.trailing, 6) }
                            Text("Continuer")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(saving)
                    .padding(.horizontal)

                    Text("Tu peux continuer même si tu n’es pas sûr(e) de tes choix.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Hidden link to IdeaClarifyView
                NavigationLink(
                    destination: IdeaClarifyView(
                        selectedDomains: selectedDomains,
                        selectedSectors: selectedSectors,
                        selectedTrainingTypes: selectedTrainingTypes
                    )
                    .environmentObject(authVM),
                    isActive: $goToClarify
                ) { EmptyView() }
                .hidden()
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Mes idées d’orientation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { prefillFromProfileIfAny() }
        .alert(item: $authVM.errorMessage) { e in
            Alert(title: Text("Erreur"), message: Text(e.message), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - UI Blocks

    private func selectionGroup(
        title: String,
        options: [String],
        selection: Binding<[String]>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).padding(.horizontal)

            DisclosureGroup {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { opt in
                        Button {
                            toggle(opt, in: selection)
                        } label: {
                            HStack {
                                Image(systemName: selection.wrappedValue.contains(opt) ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(selection.wrappedValue.contains(opt) ? .accentColor : .secondary)
                                Text(opt)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)

                        Divider()
                            .padding(.leading, 44)
                            .opacity(opt == options.last ? 0 : 1)
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            } label: {
                Text("Choisir")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.bottom, 4)
        }
        .padding(.top, 4)
    }

    private func toggle(_ value: String, in binding: Binding<[String]>) {
        var current = binding.wrappedValue
        if let i = current.firstIndex(of: value) {
            current.remove(at: i)
        } else {
            current.append(value)
        }
        binding.wrappedValue = current
    }

    // MARK: - Data

    private func prefillFromProfileIfAny() {
        guard let dict = authVM.userProfile?.orientationChoices else { return }
        if let arr = dict["formation_domains"]?.value as? [String] { selectedDomains = arr }
        if let arr = dict["job_sectors"]?.value as? [String] { selectedSectors = arr }
        if let arr = dict["training_types"]?.value as? [String] { selectedTrainingTypes = arr }
    }

    private func saveAndContinue() {
        localError = nil
        saving = true

        let json: [String: Any] = [
            "formation_domains": selectedDomains,
            "job_sectors": selectedSectors,
            "training_types": selectedTrainingTypes
        ]

        authVM.updateUserFields(["orientation_choices": json]) { result in
            saving = false
            switch result {
            case .success:
                withAnimation { goToClarify = true }
            case .failure(let err):
                localError = err.localizedDescription
            }
        }
    }
}

// MARK: - Small Color helper


// MARK: - Preview
struct OrientationChoicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrientationChoicesView()
                .environmentObject(AuthViewModel1())
        }
    }
}
