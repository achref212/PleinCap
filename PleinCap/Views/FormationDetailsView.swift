import SwiftUI

// MARK: - Formation Details (self-contained)

struct FormationDetailsView: View {
    let formationId: Int

    @StateObject private var viewModel = FormationViewModel()
    @State private var showError = false

    private var heroImageName: String {
        // Put 10 placeholders in Assets or rename below
        let names = ["hero1","hero2","hero3","hero4","hero5","hero6","hero7","hero8","hero9","hero10"]
        return names[abs(formationId) % names.count]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                if let f = viewModel.selectedFormation {
                    // HEADER
                    HeroHeader(formation: f, imageName: heroImageName)
                        .padding(.horizontal)

                    // TITLE + RESUME
                    VStack(alignment: .leading, spacing: 12) {
                        TitleWithSideLineLocal(title: f.titre, subtitle: f.etablissement)
                        if let resume = f.resumeProgramme, !resume.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(resume)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    // SECTIONS
                    SectionTitle("Informations Générales")
                        .padding(.horizontal)

                    SectionCard {
                        GroupTitle("Durées & Niveau")
                        InfoRow1(title: "Durée formation", value: f.duree)
                        // Example default for Licence
                        InfoRow1(title: "Durée totale du cursus", value: (f.typeFormation == "Licence") ? "5 ans (Licence + Master)" : nil)
                    }
                    .padding(.horizontal)

                    SectionCard {
                        GroupTitle("Programme & Débouchés")
                        InfoRow1(title: "Résumé du programme", value: f.resumeProgramme)
                        InfoRow1(title: "Débouchés pro", value: f.debouchesMetiers?.joined(separator: ", "))
                        InfoRow1(title: "Débouchés études", value: f.poursuiteEtudes)
                        InfoRow1(title: "Domaines / secteurs", value: f.debouchesSecteurs?.joined(separator: ", "))
                    }
                    .padding(.horizontal)

                    SectionTitle("Informations Personnalisées")
                        .padding(.horizontal)

                    SectionCard {
                        GroupTitle("Organisation pédagogique")
                        InfoRow1(title: "Taille des groupes", value: nil)
                        InfoRow1(title: "Degré d’autonomie", value: nil)
                        InfoRow1(title: "Part théorique", value: nil)
                        InfoRow1(title: "Part pratique", value: nil)
                        InfoRow1(title: "Charge de travail", value: nil)
                    }
                    .padding(.horizontal)

                    SectionCard {
                        GroupTitle("Parcours & accompagnement")
                        InfoRow1(title: "Stage / immersion pro", value: f.apprentissage)
                        InfoRow1(title: "En apprentissage", value: f.apprentissage)
                        InfoRow1(title: "Type de formation", value: f.typeFormation)
                        InfoRow1(title: "Type d’établissement", value: f.typeEtablissement)
                    }
                    .padding(.horizontal)

                    SectionCard {
                        GroupTitle("Ouverture & compatibilité")
                        InfoRow1(title: "Taux d’insertion pro", value: f.tauxInsertion)
                        InfoRow1(title: "Localisation", value: f.lieu?.ville)
                        InfoRow1(title: "Caractéristiques RIASEC", value: nil)
                    }
                    .padding(.horizontal)

                    if let link = f.lienOnisep, let url = URL(string: link) {
                        Link(destination: url) {
                            Text("Voir sur ONISEP")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#17C1C1"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "#17C1C1"), lineWidth: 2)
                                )
                        }
                        .padding(.horizontal)
                    }
                } else if viewModel.isLoading {
                    ProgressView("Chargement…")
                        .padding(.top, 60)
                } else {
                    Text("Aucune donnée à afficher.")
                        .foregroundColor(.secondary)
                        .padding(.top, 60)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Détails Formation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadIfNeeded() }
        .onReceive(viewModel.$errorMessage) { err in
            showError = (err != nil)
        }
        .alert("Erreur",
               isPresented: $showError,
               actions: { Button("OK") { viewModel.errorMessage = nil } },
               message: { Text(viewModel.errorMessage?.message ?? "Une erreur est survenue.") })
    }

    private func loadIfNeeded() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            if viewModel.selectedFormation == nil {
                viewModel.selectedFormation = Self.mockFormation(id: formationId)
            }
            return
        }
        #endif
        if viewModel.selectedFormation?.id != formationId {
            viewModel.fetchFormation(id: formationId)
        }
    }
}

// MARK: - Header

private struct HeroHeader: View {
    let formation: Formation
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 210)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(22)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    TagPill(text: formation.lieu?.ville ?? "—", systemImage: "mappin.and.ellipse")
                    TagPill(text: priceString(formation.prixAnnuel), systemImage: "eurosign")
                    TagPill(text: formation.duree ?? "—", systemImage: "clock")
                }
                HStack(spacing: 10) {
                    TagPill(text: "contrôlée par l’État")
                    TagPill(text: (formation.formationControleeParEtat ?? false) ? "Public" : "Privé")
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 6) {
                Text(formation.titre)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                Text(formation.etablissement)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.95))
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .padding([.leading, .bottom], 14)
        }
    }

    private func priceString(_ v: Double?) -> String {
        guard let v = v else { return "N/A" }
        if v == 0 { return "Gratuite" }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "€ "
        return f.string(from: NSNumber(value: v)) ?? "\(Int(v)) €"
    }
}

// MARK: - Local UI helpers

private struct TitleWithSideLineLocal: View {
    let title: String
    let subtitle: String?
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle().fill(Color(hex: "#17C1C1")).frame(width: 4).cornerRadius(2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3.bold())
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
}

private struct SectionTitle: View {
    let text: String
    init(_ t: String) { text = t }
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color(hex: "#17C1C1")).frame(width: 4).cornerRadius(2)
            Text(text).font(.title3.bold())
        }
    }
}

private struct GroupTitle: View {
    let text: String
    init(_ t: String) { text = t }
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(Color(hex: "#1F3552"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}

private struct SectionCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
    }
}

private struct TagPill: View {
    let text: String
    var systemImage: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            if let s = systemImage { Image(systemName: s).font(.caption2) }
            Text(text)
        }
        .font(.caption.bold())
        .foregroundColor(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Capsule().fill(Color.black.opacity(0.35)))
    }
}

private struct InfoRow1: View {
    let title: String
    let value: String?
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill").font(.system(size: 6)).foregroundColor(.secondary)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(title + " :")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(hex: "#1F3552"))
                Text(value?.nilIfBlank ?? "—")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }
}

//extension Color {
//    init(hex: String) {
//        var hexVal = hex
//        if hexVal.hasPrefix("#") { hexVal.removeFirst() }
//        var int: UInt64 = 0
//        Scanner(string: hexVal).scanHexInt64(&int)
//        let r = Double((int >> 16) & 0xFF) / 255.0
//        let g = Double((int >> 8) & 0xFF) / 255.0
//        let b = Double(int & 0xFF) / 255.0
//        self.init(red: r, green: g, blue: b)
//    }
//}

// MARK: - Preview (no network, no env objects)

#if DEBUG
private extension FormationDetailsView {
    static func mockFormation(id: Int) -> Formation {
        Formation(
            id: id,
            timestamp: "2025-08-14T10:00:00Z",
            url: "https://example.com",
            titre: "Licence en Droit",
            etablissement: "Université Paris 1 Panthéon-Sorbonne",
            typeFormation: "Licence",
            typeEtablissement: "Université",
            formationControleeParEtat: true,
            apprentissage: "Oui",
            prixAnnuel: 0,
            salaireMoyen: 29000,
            poursuiteEtudes: "Master, écoles spécialisées",
            tauxInsertion: "78%",
            lienOnisep: "https://www.onisep.fr/",
            resumeProgramme: "Formation pluridisciplinaire intégrant droit, économie et relations internationales.",
            duree: "3 ans",
            formationSelective: false,
            tauxPassage2eAnnee: "65%",
            accesFormation: nil,
            preBacAdmissionPercentage: 0.62,
            femalePercentage: 0.58,
            newBacStudentsCount: 120,
            totalAdmittedCount: 240,
            complementaryPhaseAcceptancePercentage: 0.22,
            tauxReussite3_4Ans: "62%",
            lieu: .init(ville: "Paris", region: "Île-de-France", departement: "75", academy: "Paris", gpsCoordinates: nil),
            salaireBornes: .init(min: 26000, max: 38000),
            badges: [Badge(badge: "Public")],
            filieresBac: ["Générale"],
            specialitesFavorisees: ["HGGSP", "SES"],
            matieresEnseignees: ["Droit civil", "Droit constitutionnel", "Économie"],
            debouchesMetiers: ["Juriste", "Assistant juridique"],
            debouchesSecteurs: ["Public", "Banque"],
            tsTauxParBac: nil,
            intervallesAdmis: nil,
            criteresCandidature: nil,
            boursiers: .init(tauxMinimumBoursiers: "25%", pourcentageBoursiersNeoBacheliers: 0.27),
            profilsAdmis: nil,
            promoCharacteristics: .init(newBacStudentsCount: 120, femalePercentage: 0.58, totalAdmittedCount: 240),
            postFormationOutcomes: .init(poursuiventEtudes: "58%", enEmploi: "30%", autreSituation: "12%"),
            voieGenerale: .init(filieres: ["Générale"], specialities: ["SES", "HGGSP"]),
            voiePro: nil,
            voieTechnologique: .init(filieres: ["STMG"], specialities: ["Droit & Éco"])
        )
    }
}

// convenience init for preview code
extension Voie {
    init(filieres: [String]?, specialities: [String]?) {
        self.filieres = filieres
        self.specialities = specialities
    }
}

#Preview("Formation Details View") {
    NavigationStack {
        FormationDetailsView(formationId: 1)
    }
    .environment(\.colorScheme, .light)
}
#endif
