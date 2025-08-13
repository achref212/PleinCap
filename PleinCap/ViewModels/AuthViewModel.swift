//
//  AuthViewModel.swift
//  PFE_APP
//
//  Created by chaabani achref on 21/5/2025.
//  Updated on 31/7/2025 at 04:00 PM CET
//

import Foundation
import Combine
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class AuthViewModel: ObservableObject {
    @AppStorage("access_token") var rawToken: String = ""
    var accessToken: String? {
        get {
            rawToken.isEmpty ? nil : rawToken
        }
        set {
            rawToken = newValue ?? ""
        }
    }
    // 🔐 Authentication State
    @Published var isAuthenticated = false
    
    @Published var refreshToken: String? = nil
    @Published var userProfile: UserProfile0? = nil
    @Published var errorMessage: ErrorMessage? = nil
    // 🔑 Login/Registration Fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var nom = ""
    @Published var prenom = ""
    @Published var sexe = "H"
    @Published var dateNaissanceString = "2006-10-14" // String for UI input

    // 🎓 Educational Profile
    @Published var niveauScolaire: String? = nil
    @Published var voie: String?
    @Published var objectif: String?
    @Published var filiere: String?
    @Published var specialites: [String]?

    // 📊 Moyennes
        @Published var notes: [NoteData]? = nil // Array of notes for UI and sync
        @Published var specialty: [String]? = nil // Specialty list
    // 📍 Location & Info
    @Published var telephone: String? = nil
    @Published var budget: String? = nil
    @Published var locationData: LocationData? = nil // Full LocationData for sync

    // 🎓 Academy & Plan
    @Published var estBoursier: Bool? = nil
    @Published var planActionData: PlanActionData? = nil // Full PlanActionData for sync

    // ⚠️ Validation & Status
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil
    @Published var loginStatus: StatusType? = nil
    @Published var registerStatus: StatusType? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // MARK: - Validation
    func validateInputs() -> Bool {
        emailError = email.isEmpty ? "L’email est requis" : nil
        passwordError = password.isEmpty ? "Le mot de passe est requis" : nil
        return emailError == nil && passwordError == nil
    }

    func validateRegisterInputs() -> Bool {
        emailError = email.isEmpty ? "L’email est requis" : nil
        passwordError = password.isEmpty ? "Le mot de passe est requis" : nil
        confirmPasswordError = confirmPassword.isEmpty ? "Confirmation requise" : (confirmPassword != password ? "Les mots de passe ne correspondent pas" : nil)
        return emailError == nil && passwordError == nil && confirmPasswordError == nil
    }

    // MARK: - Authentication
    func startRegister(completion: @escaping (Bool) -> Void) {
        guard validateRegisterInputs(), let dateNaissance = dateFormatter.date(from: dateNaissanceString) else {
            registerStatus = .failure
            return completion(false)
        }

        registerStatus = .loading
        errorMessage = nil

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "nom": nom,
            "prenom": prenom,
            "sexe": sexe,
            "date_naissance": dateFormatter.string(from: dateNaissance)
        ]

        APIService.shared.postRequest(path: "/register", body: body) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.registerStatus = .success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.registerStatus = nil
                    }
                    completion(true)
                case .failure(let error):
                    self.registerStatus = .failure
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.registerStatus = nil
                    }
                    completion(false)
                }
            }
        }
    }

    func verifyCode(code: String, completion: @escaping (Bool) -> Void) {
        let body = ["email": email, "code": code]
        APIService.shared.postRequest(path: "/verify-registration", body: body) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let json):
                    do {
                        let data = try JSONSerialization.data(withJSONObject: json)
                        let decoded = try JSONDecoder().decode(TokenResponse0.self, from: data)
                        self.updateState(with: decoded)
                        completion(true)
                    } catch {
                        self.errorMessage = ErrorMessage(message: "Erreur de décodage")
                        completion(false)
                    }
                case .failure(let err):
                    self.errorMessage = ErrorMessage(message: err.localizedDescription)

                    completion(false)
                }
            }
        }
    }

    func login() {
            loginStatus = .loading
            errorMessage = nil

            let body: [String: Any] = ["email": email, "password": password]

            APIService.shared.postRequest(path: "/login", body: body) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let json):
                        do {
                            let data = try JSONSerialization.data(withJSONObject: json)
                            let decoded = try JSONDecoder().decode(TokenResponse0.self, from: data)
                            self.accessToken = decoded.access_token // ✅ Token sauvegardé
                            self.updateState(with: decoded)
                            self.loginStatus = .success
                        } catch {
                            self.loginStatus = .failure
                            self.errorMessage = ErrorMessage(message:"Erreur lors du décodage des données.")

                        }
                    case .failure(let error):
                        self.loginStatus = .failure
                        self.errorMessage = ErrorMessage(message:error.localizedDescription)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.loginStatus = nil
                    }
                }
            }
        }

    private func updateState(with decoded: TokenResponse0) {
        self.accessToken = decoded.access_token
        self.userProfile = decoded.user
        self.isAuthenticated = true
        syncLocalFields(from: decoded.user)
    }

    // MARK: - Profile Management
    func fetchUserProfile(completion: @escaping () -> Void) {
        guard let token = accessToken else {
            self.errorMessage = ErrorMessage(message: "Token manquant")

            return
        }

        APIService.shared.getRequest(path: "/me", token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let profile = try JSONDecoder().decode(UserProfile0.self, from: data)
                        self.userProfile = profile
                        self.syncLocalFields(from: profile)
                        completion()
                    } catch {
                        self.errorMessage = ErrorMessage(message: "Erreur décodage profil")

                    }
                case .failure(let error):
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }

    private func syncLocalFields(from profile: UserProfile0) {
        self.email = profile.email
        self.nom = profile.nom
        self.prenom = profile.prenom
        self.sexe = profile.sexe
        self.dateNaissanceString = dateFormatter.string(from: profile.dateNaissance)
        self.niveauScolaire = profile.niveauScolaire
        self.voie = profile.voie
        self.objectif = profile.objectif
        self.specialites = profile.specialites
        self.filiere = profile.filiere
        self.telephone = profile.telephone
        self.budget = profile.budget
        self.estBoursier = profile.estBoursier
        self.locationData = profile.location
        self.planActionData = profile.planActionId.flatMap { PlanActionData(id: $0, nom: "", steps: nil) } // Placeholder until full data fetched
    }

    func logout() {
        DispatchQueue.main.async {
            self.accessToken = nil
            self.isAuthenticated = false
            self.userProfile = nil
            self.email = ""
            self.password = ""
            self.errorMessage = nil
            self.niveauScolaire = nil
            self.voie = nil
            self.objectif = nil
            self.specialites = nil
            self.filiere = nil
            self.telephone = nil
            self.budget = nil
            self.estBoursier = nil
            self.locationData = nil
            self.planActionData = nil
        }
    }

    // MARK: - Password Management
    func forgotPassword(email: String, completion: @escaping (Bool) -> Void) {
        let body: [String: Any] = ["email": email]
        APIService.shared.postRequest(path: "/forgot-password", body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true)
                case .failure(let err):
                    
                    self!.errorMessage = ErrorMessage(message: err.localizedDescription)

                    completion(false)
                }
            }
        }
    }

    func resetPassword(email: String, code: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        let body: [String: Any] = ["email": email, "code": code, "new_password": newPassword]
        APIService.shared.postRequest(path: "/reset-password", body: body) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true)
                case .failure(let err):
                    self!.errorMessage = ErrorMessage(message: err.localizedDescription)

                    completion(false)
                }
            }
        }
    }

    // MARK: - Updates
    func updateObjectif(_ objectif: String, completion: @escaping () -> Void) {
        guard let token = accessToken else {
            self.errorMessage = ErrorMessage(message: "Token manquant")

            return
        }

        let body: [String: Any] = ["objectif": objectif]
        APIService.shared.patchRequest(path: "/me", body: body, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(UserProfile0.self, from: data)
                        self.userProfile = user
                        self.syncLocalFields(from: user)
                        completion()
                    } catch {
                        self.errorMessage = ErrorMessage(message:  "Erreur de décodage profil")

                    }
                case .failure(let err):
                    self.errorMessage = ErrorMessage(message:  "Erreur mise à jour : \(err.localizedDescription)")
                }
            }
        }
    }

//    func updateUserFields(_ fields: [String: Any], completion: @escaping () -> Void) {
//        guard let token = accessToken else {
//            errorMessage = "Token manquant"
//            return
//        }
//
//        APIService.shared.patchRequest(path: "/me", body: fields, token: token) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let data):
//                    do {
//                        let user = try JSONDecoder().decode(UserProfile.self, from: data)
//                        self.userProfile = user
//                        self.syncLocalFields(from: user)
//                        completion() // 🔴 CE CALL EST ESSENTIEL !!
//                    } catch {
//                        self.errorMessage = "Erreur de décodage profil"
//                    }
//                case .failure(let err):
//                    self.errorMessage = "Erreur mise à jour : \(err.localizedDescription)"
//                }
//            }
//        }
//    }
//    func updateExistingMoyenne(completion: @escaping () -> Void) {
//        guard let token = accessToken else {
//            errorMessage = "Token manquant"
//            return
//        }
//
//        let moyenneToUpdate = MoyenneData(
//            id: userProfile?.moyenne?.id, // Utilise l'id existant si dispo
//            specialty: specialty,
//            notes: notes
//        )
//
//        APIService.shared.updateExistingMoyenne(moyenneToUpdate, token: token) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let updatedMoyenne):
//                    self.userProfile?.moyenne = updatedMoyenne
//                    self.notes = updatedMoyenne.notes
//                    self.specialty = updatedMoyenne.specialty
//                    print("✅ Moyenne mise à jour")
//                    completion()
//                case .failure(let error):
//                    self.errorMessage = "Erreur mise à jour moyenne : \(error.localizedDescription)"
//                    print("❌ Erreur API moyenne : \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    func submitMoyenne(specialties: [String], completion: @escaping () -> Void) {
//        guard let token = accessToken else {
//            errorMessage = "Token manquant"
//            return
//        }
//
//        // 🔹 Génère des notes avec score = 0.0
//        let generatedNotes: [NoteData] = specialties.map { specialty in
//            return NoteData(subject: specialty, score: 0.0)
//        }
//
//        // 🔹 Crée l'objet Moyenne à envoyer
//        let moyenne = MoyenneData(
//            id: userProfile?.moyenne?.id,
//            specialty: specialties,
//            notes: generatedNotes
//        )
//
//        // 🔹 Envoie à l'API
//        APIService.shared.updateUserMoyenne(moyenne, token: token) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//
//                switch result {
//                case .success(let updatedMoyenne):
//                    self.specialty = updatedMoyenne.specialty
//                    self.notes = updatedMoyenne.notes
//                    completion()
//                case .failure(let err):
//                    self.errorMessage = "Erreur moyenne : \(err.localizedDescription)"
//                    print("❌ submitMoyenne failed:", err.localizedDescription)
//                }
//            }
//        }
//    }
    
//    func updateUserFields(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
//            guard let token = accessToken else {
//                self.errorMessage = ErrorMessage(message:"Token manquant")
//
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
//                return
//            }
//
//            APIService.shared.patchRequest(path: "/me", body: fields, token: token) { [weak self] result in
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//                    switch result {
//                    case .success(let data):
//                        do {
//                            let user = try JSONDecoder().decode(UserProfile.self, from: data)
//                            self.userProfile = user
//                            self.syncLocalFields(from: user)
//                            completion(.success(())) // Success case
//                        } catch {
//                            self.errorMessage = ErrorMessage(message: "Erreur de décodage profil")
//
//                            completion(.failure(error))
//                        }
//                    case .failure(let err):
//                        self.errorMessage = ErrorMessage(message:"Erreur mise à jour : \(err.localizedDescription)")
//                        completion(.failure(err))
//                    }
//                }
//            }
//        }
    private func requestTokenRefresh() {
            print("⚠️ Tentative de rafraîchissement du token...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.accessToken = "new_token" // Mock for testing
                print("🔑 Token rafraîchi : \(self.accessToken ?? "Échec")")
            }
        }
    private func loadAccessToken() {
            accessToken = UserDefaults.standard.string(forKey: "accessToken")
            print("🔍 Loaded access token: \(accessToken ?? "Nil")")
        }
    
    func updateUserFields(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        print("🕒 Attempting updateUserFields with fields: \(fields)")
        
        guard let token = accessToken else {
            errorMessage = ErrorMessage(message: "Token manquant. Veuillez vous reconnecter.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: fields, options: [])
            print("🔍 JSON envoyé : \(String(data: jsonData, encoding: .utf8) ?? "n/a")")

            APIService.shared.patchRequest1(path: "/me", body: jsonData, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        // Remove .iso8601 strategy to use UserProfile's custom decoding
                        do {
                            let user = try decoder.decode(UserProfile0.self, from: data)
                            self.userProfile = user
                            self.syncLocalFields(from: user)
                            completion(.success(()))
                        } catch {
                            self.errorMessage = ErrorMessage(message: "Erreur de décodage : \(error.localizedDescription)")
                            if let dataString = String(data: data, encoding: .utf8) {
                                print("🔍 Réponse brute : \(dataString)")
                            }
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        self.errorMessage = ErrorMessage(message: "Erreur backend : \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            errorMessage = ErrorMessage(message: "Erreur JSON : \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

        func submitMoyenne(specialties: [String], completion: @escaping (Result<Void, Error>) -> Void) {
            guard let token = accessToken else {
                errorMessage = ErrorMessage(message: "Token manquant")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
                return
            }

            let generatedNotes: [NoteData] = specialties.map { specialty in
                return NoteData(subject: specialty, score: 0.0)
            }

            let moyenne = MoyenneData(
                id: userProfile?.moyenne?.id,
                specialty: specialties,
                notes: generatedNotes
            )

            APIService.shared.updateUserMoyenne(moyenne, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let updatedMoyenne):
                        self.userProfile?.moyenne = updatedMoyenne
                        self.notes = updatedMoyenne.notes
                        self.specialty = updatedMoyenne.specialty
                        print("✅ Moyenne envoyée au backend")
                        completion(.success(()))
                    case .failure(let err):
                        self.errorMessage = ErrorMessage(message: "Erreur moyenne : \(err.localizedDescription)")
                        print("❌ submitMoyenne failed: \(err.localizedDescription)")
                        completion(.failure(err))
                    }
                }
            }
        }
        func updateExistingMoyenne(completion: @escaping (Result<Void, Error>) -> Void) {
            guard let token = accessToken else {
                self.errorMessage = ErrorMessage(message:"Token manquant")

                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
                return
            }

            let moyenneToUpdate = MoyenneData(
                id: userProfile?.moyenne?.id,
                specialty: specialty,
                notes: notes
            )

            APIService.shared.updateExistingMoyenne(moyenneToUpdate, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let updatedMoyenne):
                        self.userProfile?.moyenne = updatedMoyenne
                        self.notes = updatedMoyenne.notes
                        self.specialty = updatedMoyenne.specialty
                        print("✅ Moyenne mise à jour")
                        completion(.success(()))
                    case .failure(let error):
                        self.errorMessage = ErrorMessage(message: "Erreur mise à jour moyenne : \(error.localizedDescription)")

                        print("❌ Erreur API moyenne : \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }

//        func submitMoyenne(specialties: [String], completion: @escaping (Result<Void, Error>) -> Void) {
//            guard let token = accessToken else {
//                self.errorMessage = ErrorMessage(message: "Token manquant")
//
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
//                return
//            }
//
//            let generatedNotes: [NoteData] = specialties.map { specialty in
//                return NoteData(subject: specialty, score: 0.0)
//            }
//
//            let moyenne = MoyenneData(
//                id: userProfile?.moyenne?.id,
//                specialty: specialties, // Assuming specialty can be an array
//                notes: generatedNotes
//            )
//
//            APIService.shared.updateUserMoyenne(moyenne, token: token) { [weak self] result in
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//                    switch result {
//                    case .success(let updatedMoyenne):
//                        self.specialty = updatedMoyenne.specialty
//                        self.notes = updatedMoyenne.notes
//                        print("✅ Moyenne envoyée au backend")
//                        completion(.success(()))
//                    case .failure(let err):
//                        self.errorMessage = ErrorMessage(message: "Erreur moyenne : \(err.localizedDescription)")
//
//                        print("❌ submitMoyenne failed: \(err.localizedDescription)")
//                        completion(.failure(err))
//                    }
//                }
//            }
//        }
    
   
    func fetchPlanAction(completion: @escaping () -> Void) {
            guard let token = accessToken else {
                self.errorMessage = ErrorMessage(message:  "Token manquant")

                return
            }

            APIService.shared.getUserPlan(token: token) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let plan):
                        self.planActionData = plan
                        if let profile = self.userProfile{
                            let planId = plan.id
                            var updatedProfile = profile
                            updatedProfile.planActionId = planId
                            self.userProfile = updatedProfile
                        }
                        completion()
                    case .failure(let err):
                        self.errorMessage = ErrorMessage(message: "Erreur plan : \(err.localizedDescription)")

                    }
                }
            }
        }
    
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Bool) -> Void) {
            let clientID = "1066400972443-dulk5ktb27tpdi56579qjojcjrcf2d9b.apps.googleusercontent.com"
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { signInResult, error in
                if let error = error {
                    self.errorMessage = ErrorMessage(message: "Erreur Google Sign-In: \(error.localizedDescription)")

                    completion(false)
                    return
                }

                guard let idToken = signInResult?.user.idToken?.tokenString else {
                    self.errorMessage = ErrorMessage(message: "Jeton Google invalide")
                    completion(false)
                    return
                }

                APIService.shared.loginWithGoogle(googleAccessToken: idToken) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let json):
                            guard let access = json["access_token"] as? String,
                                  let refresh = json["refresh_token"] as? String,
                                  let userDict = json["user"] as? [String: Any] else {
                                self.errorMessage = ErrorMessage(message: "Réponse invalide du serveur")

                                completion(false)
                                return
                            }

                            // 🔐 Sauvegarder les données utilisateur
                            self.accessToken = access
                            self.refreshToken = refresh
                            self.email = userDict["email"] as? String ?? ""
                            self.nom = userDict["nom"] as? String ?? ""
                            self.prenom = userDict["prenom"] as? String ?? ""
                            self.niveauScolaire = userDict["niveau_scolaire"] as? String
                            self.objectif = userDict["objectif"] as? String
                            self.isAuthenticated = true // ✅ déclenche navigation
                            self.registerStatus = .success
                            completion(true)

                        case .failure(let error):
                            self.errorMessage = ErrorMessage(message: error.localizedDescription)

                            self.registerStatus = .failure
                            completion(false)
                        }
                    }
                }
            }
        }
}

struct AnyEncodable: Codable {
    private let value: Any

    init(_ value: Any) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let number as Int:
            try container.encode(number)
        case let number as Double:
            try container.encode(number)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyEncodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(Dictionary(uniqueKeysWithValues: dictionary.map { key, value in (key, AnyEncodable(value)) }))
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unsupported type for encoding"))
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoding to AnyEncodable is not supported. Use specific types for decoding.")
        
    
    }
}
