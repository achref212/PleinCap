//
//  NotesEntryView.swift
//  PleinCap
//
//  Created by chaabani achref on 11/8/2025.
//

import SwiftUI

// MARK: - Sanitizer (same contract as the rest of the app)


struct NoteRow: Identifiable, Hashable {
    let id = UUID()
    let subject: String                 // display label (can be sanitized already)
    var averageText: String = ""        // required (/20)
    var rankText: String = ""           // optional (Int)
}

struct NotesEntryView: View {
    @EnvironmentObject var authVM: AuthViewModel1
    @Environment(\.dismiss) private var dismiss

    @Binding var progress: Double
    var onSaved: (() -> Void)? = nil    // optional callback

    @State private var rows: [NoteRow] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            // Header
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

            // Fields
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

            // Save
            PrimaryGradientButton(
                title: isSaving ? "Enregistrement…" : "Appliquer",
                enabled: canSave && !isSaving
            ) {
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
        // Use user's specialties; keep as-is for display.
        let subjects = (authVM.specialites ?? []).unique()
        rows = subjects.map { NoteRow(subject: $0) }

        // If you already store notes, you could prefill here by reading authVM.userProfile?.notes
        // and matching on subject_key/subject_label.
    }

    // MARK: - Validation

    private func normalizedDouble(_ text: String) -> Double? {
        let t = text.replacingOccurrences(of: ",", with: ".")
                     .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(t)
    }

    private var canSave: Bool {
        guard !rows.isEmpty else { return false }
        for r in rows {
            guard let avg = normalizedDouble(r.averageText), (0.0...20.0).contains(avg) else { return false }
            if !r.rankText.isEmpty && Int(r.rankText) == nil { return false }
        }
        return true
    }

    // MARK: - Save

    private func save() async {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        // Build payload. We keep both a human label and a backend-safe key.
        let payload: [[String: Any]] = rows.map { r in
            var dict: [String: Any] = [
                "subject_label": r.subject,
                "subject_key": r.subject.sanitizedFR,
                "average": normalizedDouble(r.averageText) ?? 0.0
            ]
            if let rk = Int(r.rankText) { dict["rank"] = rk }
            return dict
        }

        await withCheckedContinuation { cont in
            authVM.updateUserFields(["notes": payload]) { result in
                switch result {
                case .success:
                    withAnimation { progress = max(progress, 0.40) }
                    onSaved?()
                    // pop back to NotesIntroView
                    dismiss()
                    cont.resume()
                case .failure(let err):
                    errorMessage = "Impossible d’enregistrer : \(err.localizedDescription)"
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

                TextField("Ex: 5", text: $row.rankText)
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
