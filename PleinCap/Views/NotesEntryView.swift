//
//  NotesEntryView.swift
//  PleinCap
//
//  Created by chaabani achref on 11/8/2025.
//

import SwiftUI

struct NoteRow: Identifiable, Hashable {
    let id = UUID()
    let subject: String
    var averageText: String = ""     // required, /20
    var rankText: String = ""        // optional, integer
}

struct NotesEntryView: View {
    @EnvironmentObject var authVM: AuthViewModel1

    @Binding var progress: Double
    var onSaved: (() -> Void)? = nil

    @State private var rows: [NoteRow] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            // header
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes et classements")
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "#2C4364"))
                Text("Entre ta moyenne (/20) pour chaque spécialité. Le classement est optionnel.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // card with fields
            ScrollView {
                VStack(spacing: 18) {
                    ForEach($rows) { $row in
                        NoteFieldCard(row: $row)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            }

            if let err = errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // save
            PrimaryGradientButton(title: isSaving ? "Enregistrement…" : "Enregistrer", enabled: canSave && !isSaving) {
                Task { await save() }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: bootstrapFromUser)
    }

    // MARK: - Bootstrap

    private func bootstrapFromUser() {
        // Take specialties from the user; fall back to empty.
        // If you also store existing notes, prefill them here.
        let specialites = authVM.specialites ?? []

        // If there are NO specialties, you can decide to show defaults:
        // let fallback = ["Français", "Maths"]
        // let subjects = specialites.isEmpty ? fallback : specialites
        let subjects = specialites

        rows = subjects.unique().map { NoteRow(subject: $0) }
    }

    // MARK: - Validation

    private var canSave: Bool {
        // every row must have valid average 0...20
        for r in rows {
            guard let avg = Double(r.averageText), (0...20).contains(avg) else { return false }
            if !r.rankText.isEmpty && Int(r.rankText) == nil { return false }
        }
        return !rows.isEmpty
    }

    // MARK: - Save

    private func save() async {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        // Build array of dictionaries: [{subject, average, rank?}]
        let payload: [[String: Any]] = rows.map { r in
            var d: [String: Any] = [
                "subject": r.subject,
                "average": Double(r.averageText) ?? 0.0
            ]
            if let rank = Int(r.rankText) { d["rank"] = rank }
            return d
        }

        await withCheckedContinuation { cont in
            authVM.updateUserFields(["notes": payload]) { result in
                switch result {
                case .success:
                    // bump progress and return
                    withAnimation { progress = max(progress, 0.4) }
                    onSaved?()
                    cont.resume()
                case .failure(let err):
                    errorMessage = "Impossible d’enregistrer: \(err.localizedDescription)"
                    cont.resume()
                }
            }
        }
    }
}

// MARK: - Row UI

private struct NoteFieldCard: View {
    @Binding var row: NoteRow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Subject + Average
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("\(row.subject) - Moyenne /20")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#1F3552"))
                    Text("*").foregroundColor(.red)
                }

                TextField("Ex: 14.5", text: $row.averageText)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(.systemBackground))
                    )
            }

            // Rank (optional)
            VStack(alignment: .leading, spacing: 6) {
                Text("Classement en \(row.subject)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1F3552"))

                TextField("Ex 5", text: $row.rankText)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(.systemBackground))
                    )

                Text("Une approximation est acceptée")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Helpers

private extension Array where Element == String {
    func unique() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
