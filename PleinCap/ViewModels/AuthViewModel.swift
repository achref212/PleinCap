//
//  AuthViewModel.swift
//  PFE_APP
//
//  Created by chaabani achref on 21/5/2025.
//


import Foundation
import Combine
import GoogleSignIn
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    // 🔐 Champs de connexion et inscription
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var nom = ""
    @Published var prenom = ""
    @Published var sexe = "H"
    @Published var dateNaissance = "2006-10-14"

    // 🎓 Profil pédagogique
    @Published var niveauScolaire: String? = nil
    @Published var voie: String? = nil
    @Published var userObjectif: String? = nil
    @Published var specialites: [String]? = nil
    @Published var filiere: [String]? = nil

    // 📊 Moyennes
    @Published var moyenneGenerale: Double? = nil
    @Published var moyenneFrancais: Double? = nil
    @Published var moyennePhilo: Double? = nil
    @Published var moyenneMath: Double? = nil
    @Published var moyenneSvt: Double? = nil
    @Published var moyennePhysique: Double? = nil
    @Published var moyenneAnglais: Double? = nil

    // 📍 Localisation & infos
    @Published var telephone: String? = nil
    @Published var adresse: String? = nil
    @Published var distance: String? = nil
    @Published var budget: String? = nil

    // 🎓 Académie
    @Published var academie: String? = nil
    @Published var estBoursier: Bool? = nil
    @Published var planAction: [String]? = nil

    // 🔐 Authentification
    @Published var isAuthenticated = false
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    @Published var userProfile: UserProfile? = nil
    @Published var errorMessage: String? = nil

    // ⚠️ Statuts & erreurs
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil
    @Published var loginStatus: StatusType? = nil
    @Published var registerStatus: StatusType? = nil

    private var cancellables = Set<AnyCancellable>()

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

    func startRegister(completion: @escaping (Bool) -> Void) {
        guard validateRegisterInputs() else {
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
            "date_naissance": dateNaissance
        ]

        APIService.shared.postRequest(path: "/register", body: body) { result in
            DispatchQueue.main.async {
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
                switch result {
                case .success(let json):
                    do {
                        let data = try JSONSerialization.data(withJSONObject: json)
                        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
                        self?.updateState(with: decoded)
                        self?.niveauScolaire = decoded.user.niveauScolaire
                        self?.userObjectif = decoded.user.objectif
                        completion(true)
                    } catch {
                        self?.errorMessage = "Erreur de décodage"
                        completion(false)
                    }
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
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
        self.niveauScolaire = decoded.user.niveauScolaire
        self.userObjectif = decoded.user.objectif
        self.specialites = decoded.user.specialites
        self.filiere = decoded.user.filiere
        self.academie = decoded.user.academie
        self.estBoursier = decoded.user.estBoursier
        self.budget = decoded.user.budget
        self.telephone = decoded.user.telephone
    }

    func fetchUserProfile() {
        guard let token = accessToken else { return }
        APIService.shared.getRequest(path: "/me", token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userProfile = profile
                    } catch {
                        self.errorMessage = "Erreur décodage profil"
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func logout() {
        DispatchQueue.main.async {
            self.accessToken = nil
            self.isAuthenticated = false
            self.userProfile = nil
            self.email = ""
            self.password = ""
            self.errorMessage = nil
        }
    }

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

    func resetPassword(email: String, code: String, newPassword: String,
                       completion: @escaping (Bool) -> Void) {
        let body: [String: Any] = [
            "email": email,
            "code": code,
            "new_password": newPassword
        ]
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
    func updateObjectif(_ objectif: String, completion: (() -> Void)? = nil) {
        guard let token = accessToken else {
            self.errorMessage = "Token manquant"
            return
        }

        let body: [String: Any] = ["objectif": objectif]

        APIService.shared.patchRequest(path: "/me", body: body, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userObjectif = user.objectif
                        self.userProfile = user
                        completion?()
                    } catch {
                        self.errorMessage = "Erreur de décodage profil"
                    }
                case .failure(let err):
                    self.errorMessage = "Erreur mise à jour : \(err.localizedDescription)"
                }
            }
        }
    }
    func updateUserFields(_ fields: [String: Any], completion: (() -> Void)? = nil) {
        guard let token = accessToken else {
            self.errorMessage = "Token manquant"
            return
        }

        APIService.shared.patchRequest(path: "/me", body: fields, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(UserProfile.self, from: data)
                        self.userProfile = user

                        // Met à jour les champs modifiés seulement
                        if let objectif = user.objectif { self.userObjectif = objectif }
                        if let niveau = user.niveauScolaire { self.niveauScolaire = niveau }
                       

                        completion?()
                    } catch {
                        self.errorMessage = "Erreur de décodage profil"
                    }
                case .failure(let err):
                    self.errorMessage = "Erreur mise à jour : \(err.localizedDescription)"
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
                        self.userObjectif = userDict["objectif"] as? String
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
