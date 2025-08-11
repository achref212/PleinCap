import SwiftUI

// MARK: - Sanitizer (same contract you’re using elsewhere)
extension String {
    /// Remove French diacritics and apostrophes for backend-safe keys.
    var sanitizedFR1: String {
        let folded = self.folding(options: [.diacriticInsensitive],
                                  locale: Locale(identifier: "fr_FR"))
        return folded
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "'", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - View

struct OrientationChoicesView: View {
    @EnvironmentObject var authVM: AuthViewModel1

    // Local selections (display strings; accents kept for UX)
    @State private var selectedDomains: [String] = []
    @State private var selectedSectors: [String] = []
    @State private var selectedTrainingTypes: [String] = []

    // UI state
    @State private var saving = false
    @State private var goToClarify = false
    @State private var localError: String?
    @State private var progress: Double = 0.20

    // MARK: - Options (display labels)
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
            VStack(spacing: 20) {
                ProgressBarView(progress: $progress)
                    .padding(.top)
                ImageWithCaptionView(imageName: "orientation", caption: "Mes idées d’orientation")

                VStack(spacing: 18) {
                    HStack(spacing: 10) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 4, height: 28)
                            .cornerRadius(2)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Affinons ce qui t’intéresse")
                                .font(.title3.bold())
                                .foregroundColor(Color(hex: "#2C4364"))
                            Text("Tu peux cocher plusieurs réponses et changer plus tard.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 6)

                    AccordionChecklist(
                        title: "Domaines de formation",
                        options: domainOptions,
                        selection: $selectedDomains
                    )
                    AccordionChecklist(
                        title: "Métiers / Secteurs d’activité",
                        options: sectorOptions,
                        selection: $selectedSectors
                    )
                    AccordionChecklist(
                        title: "Types de formation",
                        options: trainingOptions,
                        selection: $selectedTrainingTypes
                    )
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                )
                .padding(.horizontal)

                if let err = localError {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                PrimaryGradientButton(title: saving ? "Enregistrement…" : "Continuer", enabled: !saving) {
                    saveAndContinue()
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Mes idées d’orientation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { prefillFromProfileIfAny() }
        .alert(item: $authVM.errorMessage) { e in
            Alert(title: Text("Erreur"), message: Text(e.message), dismissButton: .default(Text("OK")))
        }
        .background(
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
        )
    }

    // MARK: - Data

    /// Map saved (sanitized) values back to displayed labels so checkboxes are preselected.
    private func prefillFromProfileIfAny() {
        guard let dict = authVM.userProfile?.orientationChoices else { return }

        if let arr = (dict["formation_domains"]?.value as? [String]) ?? (dict["formation_domains"] as? [String]) {
            let saved = Set(arr.map { $0.sanitizedFR1 })
            selectedDomains = domainOptions.filter { saved.contains($0.sanitizedFR1) }
        }

        if let arr = (dict["job_sectors"]?.value as? [String]) ?? (dict["job_sectors"] as? [String]) {
            let saved = Set(arr.map { $0.sanitizedFR1 })
            selectedSectors = sectorOptions.filter { saved.contains($0.sanitizedFR1) }
        }

        if let arr = (dict["training_types"]?.value as? [String]) ?? (dict["training_types"] as? [String]) {
            let saved = Set(arr.map { $0.sanitizedFR1 })
            selectedTrainingTypes = trainingOptions.filter { saved.contains($0.sanitizedFR1) }
        }
    }

    private func saveAndContinue() {
        localError = nil
        saving = true

        func sanitizedUnique(_ list: [String]) -> [String] {
            var seen = Set<String>()
            var out: [String] = []
            for v in list.map({ $0.sanitizedFR1 }) {
                if seen.insert(v).inserted { out.append(v) }
            }
            return out
        }

        let payload: [String: Any] = [
            "orientation_choices": [
                "formation_domains": sanitizedUnique(selectedDomains),
                "job_sectors": sanitizedUnique(selectedSectors),
                "training_types": sanitizedUnique(selectedTrainingTypes)
            ]
        ]

        authVM.updateUserFields(payload) { result in
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

// MARK: - Accordion + Checkbox UI

private struct AccordionChecklist: View {
    let title: String
    let options: [String]
    @Binding var selection: [String]

    @State private var isOpen = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isOpen.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isOpen ? 0 : -90))
                        .foregroundColor(Color(hex: "#17C1C1"))
                        .font(.system(size: 16, weight: .semibold))
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color(hex: "#2C4364"))
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { opt in
                        CheckboxRow(
                            title: opt,
                            checked: selection.contains(opt)
                        ) {
                            toggle(opt)
                        }
                        Divider()
                            .padding(.leading, 44)
                            .opacity(opt == options.last ? 0 : 1)
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func toggle(_ value: String) {
        if let idx = selection.firstIndex(of: value) {
            selection.remove(at: idx)
        } else {
            selection.append(value)
        }
    }
}

private struct CheckboxRow: View {
    let title: String
    let checked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(checked ? Color(hex: "#17C1C1") : Color(hex: "#17C1C1").opacity(0.6), lineWidth: 2)
                    .background(checked ? Color(hex: "#E0FBFB") : Color.clear)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(checked ? Color(hex: "#17C1C1") : .clear)
                    )

                Text(title)
                    .foregroundColor(Color(hex: "#1F3552"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct OrientationChoicesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrientationChoicesView()
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.light)

        NavigationStack {
            OrientationChoicesView()
                .environmentObject(AuthViewModel1())
        }
        .preferredColorScheme(.dark)
    }
}
