//
//  FormationViewModel.swift
//  PleinCap
//
//  Created by chaabani achref on 5/8/2025.
//

// FormationViewModel.swift
import Foundation
import Combine

class FormationViewModel: ObservableObject {
    @Published var formations: [Formation] = []
    @Published var selectedFormation: Formation? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: ErrorMessage? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    var uniqueEtablissements: [String] {
            Array(Set(formations.map { $0.etablissement })).sorted()
        }
    func fetchFormations(skip: Int = 0, limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchFormations(skip: skip, limit: limit) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let formations):
                    self?.formations = formations
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: "Failed to load formations: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchFormation(id: Int) {
        isLoading = true
        errorMessage = nil
        selectedFormation = nil // Reset before fetching
        
        networkService.fetchFormation(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let formation):
                    self?.selectedFormation = formation
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: "Failed to load formation \(id): \(error.localizedDescription)")
                }
            }
        }
    }
    func fetchFormations(completion: @escaping (Result<[Formation], Error>) -> Void) {
            isLoading = true
            errorMessage = nil
            
            networkService.fetchFormations() { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let formations):
                        self?.formations = formations
                        completion(.success(formations))
                    case .failure(let error):
                        self?.errorMessage = ErrorMessage(message: "Failed to load formations: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
    }
        
    func clearSelectedFormation() {
        selectedFormation = nil
    }
}
