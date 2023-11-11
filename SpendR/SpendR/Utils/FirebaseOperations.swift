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
    // All the needed functions used in the Login Screen
    
    func loginWithEmailAndPassword(email: String, password: String, sender: UIViewController, destination: UIViewController) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let _error = error {
                UsefullFunctions().showAlert(title: "Something went wrong", message: _error.localizedDescription, viewController: sender)
            } else {
                self.goToHomeScreen(sender: sender)
            }
        }
    }
    
    private func fetchUserByEmail(email: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(email).getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = documentSnapshot, document.exists else {
                let userNotFoundError = NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
                completion(.failure(userNotFoundError))
                return
            }

            do {
                let userProperties = try document.data(as: UserProperties.self)

                var userTags: [Tag] = []
                if let tagPropertiesArray = userProperties.userTags {
                    for tagProperties in tagPropertiesArray {
                        userTags.append(Tag(properties: tagProperties))
                    }
                }

                var movements: [Movement] = []
                if let movementsDataArray = document.get("movements") as? [[String: Any]] {
                    for movementData in movementsDataArray {
                        if let movementProperties = try? Firestore.Decoder().decode(MovementProperties.self, from: movementData) {
                            var tags: [Tag] = []
                            if let tagPropertiesArray = movementProperties.tags {
                                for tagProperties in tagPropertiesArray {
                                    tags.append(Tag(properties: tagProperties))
                                }
                            }

                            let movement = Movement(properties: movementProperties)
                            movements.append(movement)
                        }
                    }
                }

                let user = User(properties: userProperties, userTags: userTags, movements: movements)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func googleLogin(sender: UIViewController, destination: UIViewController)  {
        configGIDInstance(sender: sender, destination: destination)
        sharedInstanceSignIn(sender: sender, destination: destination)
    }

    private func configGIDInstance(sender: UIViewController, destination: UIViewController)  {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    private func sharedInstanceSignIn(sender: UIViewController, destination: UIViewController)  {
        GIDSignIn.sharedInstance.signIn(withPresenting: sender) { [unowned self] result, error in
          guard error == nil else { UsefullFunctions().showAlert(title: "Something went wrong", message: error?.localizedDescription ?? "", viewController: sender)
              return
          }
            if result != nil { goToHomeScreen(sender: sender) } else {}
        }
    }


    private func setUpCredential(result: GIDSignInResult) -> AuthCredential {
        return  GoogleAuthProvider.credential(withIDToken: setupGUser(result: result).idToken?.tokenString ?? "",
                                                        accessToken: setupGUser(result: result).accessToken.tokenString)
    }

    private func setupGUser(result: GIDSignInResult) -> GIDGoogleUser  {
        return result.user
    }
    
    private func goToHomeScreen(sender: UIViewController) {
        self.fetchUserByEmail(email: Auth.auth().currentUser?.email ?? "") { result in
            switch result {
            case .success(let user):
                UserManager.shared.setCurrentUser(user)  // Configura el usuario en UserManager
                let signUpVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! HomeViewController
                UsefullFunctions().showNewPage(sender: sender, destination: signUpVC)
            case .failure(let error):
                UsefullFunctions().showAlert(title: "Something went wrong", message: error.localizedDescription, viewController: sender)
            }
        }
    }
    

// MARK: SIGN UP FUNCTIONS
    // All the needed functions and variables used in the Sign Up Screen
    
    func createUser( user: User, password: String, vc: UIViewController) {
        Auth.auth().createUser(withEmail: user.properties.email ?? "", password: password){ success, error in
            if let error = error {
                UsefullFunctions().showAlert(title: "Oh no!", message: error.localizedDescription, viewController: vc)
                return
            }else {
                self.uploadUser(user: user, vc: vc)
            }
        }
    }

    func uploadUser(user: User, vc: UIViewController) {
        let userData = createUserData(from: user)
        
        db.collection("users").document("\(user.properties.email ?? "")").setData(userData) { error in
            if let error = error {
                UsefullFunctions().showAlert(title: "Oh oh!", message: error.localizedDescription, viewController: vc)
            } else {
                UsefullFunctions().showAlert(title: "Welcome!", message: "You've been signed up successfully", viewController: vc)
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
}
