//
//  AuthViewModelV2.swift
//  PleinCap
//
//  Created by chaabani achref on 8/8/2025.
//


import Foundation
import SwiftUI
import Combine
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel1: ObservableObject {

    // MARK: - Tokens (same storage key as before)
    @AppStorage("access_token") private var rawToken: String = ""
    @AppStorage("refresh_token") private var rawRefresh: String = ""

    var accessToken: String? {
        get { rawToken.isEmpty ? nil : rawToken }
        set { rawToken = newValue ?? "" }
    }
    var refreshToken: String? {
        get { rawRefresh.isEmpty ? nil : rawRefresh }
        set { rawRefresh = newValue ?? "" }
    }

    // MARK: - State
    @Published var isAuthenticated = false
    @Published var userProfile: UserProfile? = nil                // ⬅️ updated to new model
    @Published var plan: PlanActionResponse? = nil                // ⬅️ new full plan model
    @Published var planActionData: PlanActionData? = nil          // ⬅️ legacy mirror (minimal) for old UI
    @Published var errorMessage: ErrorMessage? = nil

    // MARK: - Forms (kept same)
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var nom = ""
    @Published var prenom = ""
    @Published var sexe = "H"
    @Published var dateNaissanceString = "2006-10-14"

    // MARK: - Profile fields (kept same)
    @Published var niveauScolaire: String? = nil
    @Published var voie: String?
    @Published var objectif: String?
    @Published var filiere: String?
    @Published var specialites: [String]?

    // If you still keep these in the app:
    @Published var telephone: String? = nil
    @Published var budget: String? = nil
    @Published var estBoursier: Bool? = nil
    @Published var locationData: LocationData? = nil // optional: map from adresse/lat/lon if your UI needs it

    // MARK: - Status flags (kept same)
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil
    @Published var loginStatus: StatusType? = nil
    @Published var registerStatus: StatusType? = nil

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    // MARK: - Validation (same)
    func validateInputs() -> Bool {
        emailError = email.isEmpty ? "L’email est requis" : nil
        passwordError = password.isEmpty ? "Le mot de passe est requis" : nil
        return emailError == nil && passwordError == nil
    }

    func validateRegisterInputs() -> Bool {
        emailError = email.isEmpty ? "L’email est requis" : nil
        passwordError = password.isEmpty ? "Le mot de passe est requis" : nil
        confirmPasswordError = confirmPassword.isEmpty
            ? "Confirmation requise"
            : (confirmPassword != password ? "Les mots de passe ne correspondent pas" : nil)
        return emailError == nil && passwordError == nil && confirmPasswordError == nil
    }

    // MARK: - Register (STEP 1) -> /register
    func startRegister(completion: @escaping (Bool) -> Void) {
        guard validateRegisterInputs(), let birth = dateFormatter.date(from: dateNaissanceString) else {
            registerStatus = .failure
            completion(false)
            return
        }

        registerStatus = .loading
        errorMessage = nil

        Task {
            do {
                let payload = NetworkManager.SignupPayload(
                    email: email,
                    password: password,
                    nom: nom,
                    prenom: prenom,
                    sexe: sexe,
                    date_naissance: dateFormatter.string(from: birth)
                )
                try await NetworkManager.shared.signupUser(payload)
                registerStatus = .success
                // clear status like before
                Task { try? await Task.sleep(nanoseconds: 2_500_000_000); self.registerStatus = nil }
                completion(true)
            } catch {
                registerStatus = .failure
                errorMessage = ErrorMessage(message: error.localizedDescription)
                Task { try? await Task.sleep(nanoseconds: 2_500_000_000); self.registerStatus = nil }
                completion(false)
            }
        }
    }

    // MARK: - Register (STEP 2) -> /verify-registration
    func verifyCode(code: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let tokenResp = try await NetworkManager.shared.confirmSignup(email: email, code: code)
                applyTokenResponse(tokenResp)
                completion(true)
            } catch {
                errorMessage = ErrorMessage(message: error.localizedDescription)
                completion(false)
            }
        }
    }

    // MARK: - Login -> /login
    func login() {
        loginStatus = .loading
        errorMessage = nil

        Task {
            do {
                let tokenResp = try await NetworkManager.shared.signinUser(email: email, password: password)
                applyTokenResponse(tokenResp)
                loginStatus = .success
            } catch {
                loginStatus = .failure
                errorMessage = ErrorMessage(message: error.localizedDescription)
            }
            Task { try? await Task.sleep(nanoseconds: 2_500_000_000); self.loginStatus = nil }
        }
    }

    // MARK: - Fetch /me
    func fetchUserProfile(completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = ErrorMessage(message: "Token manquant")
            return
        }
        Task {
            do {
                let me = try await NetworkManager.shared.fetchCurrentUser(token: token)
                self.userProfile = me
                self.syncLocalFields(from: me)
                completion()
            } catch {
                errorMessage = ErrorMessage(message: error.localizedDescription)
            }
        }
    }

    // MARK: - Update /me (partial)
    func updateObjectif(_ objectif: String, completion: @escaping () -> Void) {
        _ = updateUserFields(["objectif": objectif]) { _ in completion() }
    }

    func updateUserFields(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = accessToken else {
            errorMessage = ErrorMessage(message: "Token manquant. Veuillez vous reconnecter.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token manquant"])))
            return
        }

        Task {
            do {
                let updated = try await NetworkManager.shared.updateUserProfile(partial: fields, token: token)
                self.userProfile = updated
                self.syncLocalFields(from: updated)
                completion(.success(()))
            } catch {
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Plan -> /me/plan-action (new model), keep legacy mirror
    func fetchPlanAction(completion: @escaping () -> Void) {
        guard let token = accessToken else {
            errorMessage = ErrorMessage(message: "Token manquant")
            return
        }

        Task {
            do {
                let p = try await NetworkManager.shared.fetchUserPlan(token: token)
                self.plan = p

                // Mirror to old minimal model so old UI still compiles
                self.planActionData = PlanActionData(id: p.id, nom: p.nom, steps: nil)

                // also mirror plan_action_id into user for convenience
                if var u = self.userProfile {
                    u.planActionId = p.id
                    self.userProfile = u
                }
                completion()
            } catch {
                errorMessage = ErrorMessage(message: "Erreur plan : \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Password Management
    func forgotPassword(email: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await NetworkManager.shared.requestPasswordReset(email: email)
                completion(true)
            } catch {
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
                completion(false)
            }
        }
    }

    func resetPassword(email: String, code: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await NetworkManager.shared.confirmPasswordReset(email: email, code: code, newPassword: newPassword)
                completion(true)
            } catch {
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
                completion(false)
            }
        }
    }

    // MARK: - Google Sign-In (same UX, new service call)
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Bool) -> Void) {
        let clientID = "1066400972443-dulk5ktb27tpdi56579qjojcjrcf2d9b.apps.googleusercontent.com" // ← your working clientID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

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

            Task {
                do {
                    let tokenResp = try await NetworkManager.shared.signinWithGoogle(idToken: idToken)
                    self.applyTokenResponse(tokenResp)
                    self.registerStatus = .success
                    completion(true)
                } catch {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                    self.registerStatus = .failure
                    completion(false)
                }
            }
        }
    }

    // MARK: - Logout (same effect)
    func logout() {
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false
        userProfile = nil
        plan = nil
        planActionData = nil

        email = ""; password = ""; confirmPassword = ""
        nom = ""; prenom = ""; sexe = "H"
        dateNaissanceString = "2006-10-14"

        niveauScolaire = nil; voie = nil; objectif = nil; filiere = nil
        specialites = nil; telephone = nil; budget = nil; estBoursier = nil
        locationData = nil

        errorMessage = nil
        loginStatus = nil
        registerStatus = nil
    }

    // MARK: - Helpers
    private func applyTokenResponse(_ t: TokenResponse) {
        self.accessToken = t.access_token
        self.refreshToken = t.refresh_token
        self.userProfile = t.user
        self.isAuthenticated = true
        self.syncLocalFields(from: t.user)
    }

    private func syncLocalFields(from profile: UserProfile) {
        self.email = profile.email
        self.nom = profile.nom
        self.prenom = profile.prenom
        self.sexe = profile.sexe
        self.dateNaissanceString = DateParsers.birthdateFormatter.string(from: profile.dateNaissance)

        self.niveauScolaire = profile.niveauScolaire
        self.voie = profile.voie
        self.objectif = profile.objectif
        self.specialites = profile.specialites

        self.filiere = profile.filiere
        self.telephone = profile.telephone
        self.budget = profile.budget
        self.estBoursier = profile.estBoursier

        // Optional: map to your LocationData model if your UI expects it
        if let lat = profile.latitude, let lon = profile.longitude {
            self.locationData = LocationData(
                adresse: profile.adresse ?? "",
                distance: (profile.distance ?? 0.0),
                etablissement: profile.etablissement ?? "",
                academie: profile.academie ?? ""
            )
            // If your LocationData holds latitude/longitude, add them accordingly in your model.
        }
    }
}


