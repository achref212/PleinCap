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

class AuthViewModel: ObservableObject {
    // 🔐 Authentication State
    @Published var isAuthenticated = false
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var errorMessage: String? = nil

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
    @Published var voie: String? = nil
    @Published var objectif: String? = nil
    @Published var specialites: [String]? = nil
    @Published var filiere: String? = nil

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
                    self.errorMessage = error.localizedDescription
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
                        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                        self.updateState(with: decoded)
                        completion(true)
                    } catch {
                        self.errorMessage = "Erreur de décodage"
                        completion(false)
                    }
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
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
                            let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                            self.updateState(with: decoded)
                            self.loginStatus = .success
                        } catch {
                            self.loginStatus = .failure
                            self.errorMessage = "Erreur lors du décodage des données."
                        }
                    case .failure(let error):
                        self.loginStatus = .failure
                        self.errorMessage = error.localizedDescription
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.loginStatus = nil
                    }
                }
            }
        }

    private func updateState(with decoded: TokenResponse) {
        self.accessToken = decoded.access_token
        self.userProfile = decoded.user
        self.isAuthenticated = true
        syncLocalFields(from: decoded.user)
    }

    // MARK: - Profile Management
    func fetchUserProfile(completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = "Token manquant"
            return
        }

        APIService.shared.getRequest(path: "/me", token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userProfile = profile
                        self.syncLocalFields(from: profile)
                        completion()
                    } catch {
                        self.errorMessage = "Erreur décodage profil"
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func syncLocalFields(from profile: UserProfile) {
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
                    self?.errorMessage = err.localizedDescription
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
                    self?.errorMessage = err.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // MARK: - Updates
    func updateObjectif(_ objectif: String, completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = "Token manquant"
            return
        }

        let body: [String: Any] = ["objectif": objectif]
        APIService.shared.patchRequest(path: "/me", body: body, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userProfile = user
                        self.syncLocalFields(from: user)
                        completion()
                    } catch {
                        self.errorMessage = "Erreur de décodage profil"
                    }
                case .failure(let err):
                    self.errorMessage = "Erreur mise à jour : \(err.localizedDescription)"
                }
            }
        }
    }

    func updateUserFields(_ fields: [String: Any], completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = "Token manquant"
            return
        }

        APIService.shared.patchRequest(path: "/me", body: fields, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userProfile = user
                        self.syncLocalFields(from: user)
                        completion()
                    } catch {
                        self.errorMessage = "Erreur de décodage profil"
                    }
                case .failure(let err):
                    self.errorMessage = "Erreur mise à jour : \(err.localizedDescription)"
                }
            }
        }
    }
    func updateExistingMoyenne(completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = "Token manquant"
            return
        }

        let moyenneToUpdate = MoyenneData(
            id: userProfile?.moyenne?.id, // Utilise l'id existant si dispo
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
                    completion()
                case .failure(let error):
                    self.errorMessage = "Erreur mise à jour moyenne : \(error.localizedDescription)"
                    print("❌ Erreur API moyenne : \(error.localizedDescription)")
                }
            }
        }
    }
    func submitMoyenne(completion: @escaping () -> Void) {
            guard let token = accessToken else {
                errorMessage = "Token manquant"
                return
            }

            let moyenne = MoyenneData(id: nil, specialty: specialty, notes: notes)
            APIService.shared.updateUserMoyenne(moyenne, token: token) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let updatedMoyenne):
                        self.specialty = updatedMoyenne.specialty
                        self.notes = updatedMoyenne.notes
                        completion()
                    case .failure(let err):
                        self.errorMessage = "Erreur moyenne : \(err.localizedDescription)"
                    }
                }
            }
        }


    func updateLocation(_ location: LocationData, completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = "Token manquant"
            return
        }

        APIService.shared.updateUserLocation(location, token: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let updatedProfile):
                    self.userProfile = updatedProfile
                    self.locationData = updatedProfile.location
                    completion()
                case .failure(let err):
                    self.errorMessage = "Erreur localisation : \(err.localizedDescription)"
                }
            }
        }
    }

    func fetchPlanAction(completion: @escaping () -> Void) {
            guard let token = accessToken else {
                errorMessage = "Token manquant"
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
                        self.errorMessage = "Erreur plan : \(err.localizedDescription)"
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
                    self.errorMessage = "Erreur Google Sign-In: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                guard let idToken = signInResult?.user.idToken?.tokenString else {
                    self.errorMessage = "Jeton Google invalide"
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
                                self.errorMessage = "Réponse invalide du serveur"
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
                            self.errorMessage = error.localizedDescription
                            self.registerStatus = .failure
                            completion(false)
                        }
                    }
                }
            }
        }
}



