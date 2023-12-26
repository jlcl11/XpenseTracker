//
//  FirebaseOperations.swift
//  SpendR
//
//  Created by José Luis Corral on 29/10/23.
//

import Foundation
import FirebaseAuth
import Firebase
import GoogleSignIn

class FirebaseOperations {

    private let db = Firestore.firestore()

    // MARK: LOGIN FUNCTIONS
    func loginWithEmailAndPassword(email: String, password: String, sender: UIViewController, destination: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let _error = error {
                UsefulFunctions.showAlert(title: "Something went wrong", message: _error.localizedDescription, viewController: sender)
            } else {
                self.goToHomeScreen(sender: sender)
            }
        }
    }

    private func fetchUserByEmail(email: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(email).getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists else {
                let userNotFoundError = NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                completion(.failure(userNotFoundError))
                return
            }

            do {
                let userProperties = try document.data(as: UserProperties.self)

                let userTags: [Tag] = userProperties.userTags?.map { Tag(properties: $0) } ?? []

                let movements: [Movement] = (document.get("movements") as? [[String: Any]])?.compactMap {
                    try? Firestore.Decoder().decode(MovementProperties.self, from: $0)
                }.map { Movement(properties: $0) } ?? []

                let user = User(properties: userProperties, userTags: userTags, movements: movements)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func googleLogin(sender: UIViewController, destination: UIViewController) {
        configGIDInstance(sender: sender, destination: destination)
        sharedInstanceSignIn(sender: sender, destination: destination)
    }

    private func configGIDInstance(sender: UIViewController, destination: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    private func sharedInstanceSignIn(sender: UIViewController, destination: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: sender) { [unowned self] result, error in
            if let error = error {
                UsefulFunctions.showAlert(title: "Something went wrong", message: error.localizedDescription, viewController: sender)
                return
            } else {
                if let _ = result {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.goToHomeScreen(sender: sender)
                    }
                }
            }
        }
    }

    private func setUpCredential(result: GIDSignInResult) -> AuthCredential {
        return GoogleAuthProvider.credential(withIDToken: setupGUser(result: result).idToken?.tokenString ?? "", accessToken: setupGUser(result: result).accessToken.tokenString)
    }

    private func setupGUser(result: GIDSignInResult) -> GIDGoogleUser {
        return result.user
    }

    private func goToHomeScreen(sender: UIViewController) {
        var userEmail: String?

        if let currentUser = Auth.auth().currentUser {
            userEmail = currentUser.email
        } else if let googleUser = GIDSignIn.sharedInstance.currentUser {
            userEmail = googleUser.profile?.email ?? ""
        }

        if let userEmail = userEmail {
            self.fetchUserByEmail(email: userEmail) { result in
                switch result {
                case .success(let user):
                    UserManager.shared.setCurrentUser(user)
                    let homeVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
                    UsefulFunctions.showNewPage(sender: sender, destination: homeVC)
                case .failure(let error):
                    UsefulFunctions.showAlert(title: "Something went wrong", message: error.localizedDescription, viewController: sender)
                }
            }
        } else {
            UsefulFunctions.showAlert(title: "User Not Authenticated", message: "The user is not authenticated.", viewController: sender)
        }
    }

    // MARK: SIGN UP FUNCTIONS

    func createUser(user: User, password: String, vc: UIViewController) {
        Auth.auth().createUser(withEmail: user.properties.email ?? "", password: password) { success, error in
            if let error = error {
                UsefulFunctions.showAlert(title: "Oh no!", message: error.localizedDescription, viewController: vc)
                return
            } else {
                self.uploadUser(user: user, vc: vc)
                UsefulFunctions.showAlert(title: "Welcome!", message: "You've been signed up successfully", viewController: vc)
            }
        }
    }

    func uploadUser(user: User, vc: UIViewController) {
        let userData = createUserData(from: user)

        db.collection("users").document("\(user.properties.email ?? "")").setData(userData) { error in
            if let error = error {
                UsefulFunctions.showAlert(title: "Oh oh!", message: error.localizedDescription, viewController: vc)
            }
        }
    }

    private func createUserData(from user: User) -> [String: Any] {
        let userTagsData = user.userTags.map { createTagData(from: $0) }
        let movementsData = user.movements.map { createMovementData(from: $0) }

        return [
            "name": user.properties.name ?? "",
            "surname": user.properties.surname ?? "",
            "email": user.properties.email ?? "",
            "userTags": userTagsData,
            "currency": user.properties.currency,
            "currencyName": user.properties.currencyName,
            "balance": user.properties.balance ?? 0,
            "movements": movementsData
        ]
    }

    private func createMovementData(from movement: Movement) -> [String: Any] {
        let tagsData = movement.tags.map { createTagData(from: $0) }

        return [
            "description": movement.properties.description ?? "",
            "name" : movement.properties.name ?? "",
            "amount": movement.properties.amount ?? 0,
            "date": Timestamp(date: movement.properties.date ?? Date()),
            "isIncome": movement.properties.isIncome ?? false,
            "tags": tagsData
        ]
    }

    private func createTagData(from tag: Tag) -> [String: Any] {
        return [
            "name": tag.properties?.name ?? "",
            "color": tag.properties?.color ?? 0,
            "iconName": tag.properties?.iconName ?? ""
        ]
    }

    func logout(sender: UIViewController) {
        func signOutAndPrintMessage(provider: String) {
            do {
                try Auth.auth().signOut()
                let login = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                UsefulFunctions.showNewPage(sender: sender, destination: login)
            } catch _ as NSError {
            }
        }

        if GIDSignIn.sharedInstance.currentUser != nil {
            do {
                try GIDSignIn.sharedInstance.signOut()
                signOutAndPrintMessage(provider: "Google Sign-In")
            } catch _ as NSError {
                signOutAndPrintMessage(provider: "Firebase")
            }
        } else {
            signOutAndPrintMessage(provider: "Firebase")
        }
    }

}
