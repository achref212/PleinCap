//
//  DirectoryViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 10/8/2025.
//

import Foundation
import Combine

@MainActor
final class DirectoryViewModel: ObservableObject {
    // Data
    @Published var academies: [Academie] = []
    @Published var etablissements: [Etablissement] = []          // raw
    @Published var filteredEtablissements: [Etablissement] = []  // after search/filters

    // Selection
    @Published var selectedAcademie: Academie? = nil
    @Published var selectedEtablissement: Etablissement? = nil

    // UI state
    @Published var isLoading = false
    @Published var errorMessage: ErrorMessage? = nil

    // Filters / search
    @Published var searchText: String = "" { didSet { applyFiltersAndResetPage() } }
    @Published var cityFilter: String? = nil { didSet { applyFiltersAndResetPage() } }
    @Published var trackFilter: String? = nil { didSet { applyFiltersAndResetPage() } }

    // Pagination (defaults to 4 per your request)
    @Published var pageSize: Int = 4 { didSet { clampPage() } }
    @Published var currentPage: Int = 0 { didSet { clampPage() } }

    // Derived page items
    var currentPageItems: [Etablissement] {
        guard !filteredEtablissements.isEmpty else { return [] }
        let start = currentPage * pageSize
        let end = min(start + pageSize, filteredEtablissements.count)
        return (start < end) ? Array(filteredEtablissements[start..<end]) : []
    }
    var totalPages: Int {
        guard !filteredEtablissements.isEmpty else { return 0 }
        return Int(ceil(Double(filteredEtablissements.count) / Double(pageSize)))
    }

    // Service
    private let service: DirectoryService

    // MARK: - Init
    /// Inject `authVM` if you want the service to carry an access token automatically.
    init(authVM: AuthViewModel1? = nil) {
        if let authVM = authVM {
            self.service = DirectoryService(tokenProvider: { authVM.accessToken })
        } else {
            self.service = DirectoryService()
        }
    }

    // MARK: - Public API

    func fetchAcademies() {
        isLoading = true; errorMessage = nil
        Task {
            do {
                let items = try await service.listAcademies()
                self.academies = items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorMessage(message: self.humanize(error))
            }
        }
    }

    /// Load all établissements (no filter) – you can call this if you show a global list.
    func fetchAllEtablissements() {
        isLoading = true; errorMessage = nil
        Task {
            do {
                let items = try await service.listEtablissements()
                self.etablissements = items.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
                self.applyFiltersAndResetPage()
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorMessage(message: self.humanize(error))
            }
        }
    }

    /// Load établissements for a specific académie.
    func fetchEtablissements(in academie: Academie) {
        selectedAcademie = academie
        isLoading = true; errorMessage = nil
        Task {
            do {
                let items = try await service.listEtablissements(id: academie.id)
                self.etablissements = items.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
                self.applyFiltersAndResetPage()
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorMessage(message: self.humanize(error))
            }
        }
    }

    /// Simple client-side search/filter without another call.
    func applyFiltersAndResetPage() {
        filteredEtablissements = service.filter(
            etablissements,
            city: cityFilter,
            track: trackFilter,
            query: searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        currentPage = 0
    }

    // Pagination controls
    func nextPage() { guard currentPage + 1 < totalPages else { return }; currentPage += 1 }
    func previousPage() { guard currentPage > 0 else { return }; currentPage -= 1 }
    func setPage(_ page: Int) { guard page >= 0, page < totalPages else { return }; currentPage = page }

    // Persist the selected établissement (+ optional académie name) to the user profile.
    func persistSelection(to authVM: AuthViewModel1, completion: ((Bool) -> Void)? = nil) {
        guard let etab = selectedEtablissement else {
            self.errorMessage = ErrorMessage(message: "Aucun établissement sélectionné.")
            completion?(false)
            return
        }
        var payload: [String: Any] = [
            "etablissement": etab.etablissement ?? etab.displayName
        ]
        if let acad = selectedAcademie?.name {
            payload["academie"] = acad
        }
        authVM.updateUserFields(payload) { result in
            switch result {
            case .success:
                completion?(true)
            case .failure(let err):
                self.errorMessage = ErrorMessage(message: "Échec de la mise à jour: \(err.localizedDescription)")
                completion?(false)
            }
        }
    }

    // MARK: - Helpers

    private func clampPage() {
        if totalPages == 0 { currentPage = 0; return }
        if currentPage >= totalPages { currentPage = max(totalPages - 1, 0) }
        if currentPage < 0 { currentPage = 0 }
    }

    private func humanize(_ error: Error) -> String {
        if let api = error as? APIError {
            switch api {
            case .invalidURL:       return "URL invalide."
            case .noData:           return "Aucune donnée reçue."
            case .invalidResponse:  return "Réponse serveur invalide."
            case .decodingError:    return "Erreur de décodage des données."
            case .unauthorized:     return "Non autorisé. Merci de vous reconnecter."
            case .serverError:      return "Erreur serveur. Réessayez plus tard."
            case .invalidPayload:   return "Contenu de la requête invalide."
            }
        }
        return error.localizedDescription
    }
}
