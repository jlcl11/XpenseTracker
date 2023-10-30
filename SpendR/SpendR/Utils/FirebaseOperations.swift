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
                  if let _eror = error{
                      UsefullFunctions().showAlert(title: "Something went wrong", message: _eror.localizedDescription, viewController: sender)
                  }else{
                      UsefullFunctions().showNewPage(sender: sender, destination: destination)
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
            if let signInResult = result { signIn(credential: setUpCredential(result: signInResult), sender: sender, destination: destination) } else {}
        }
    }

    private func signIn(credential: AuthCredential, sender: UIViewController, destination: UIViewController) {
        Auth.auth().signIn(with: credential) { result, error in
            UsefullFunctions().showNewPage(sender: sender, destination: destination)
        }
    }

    private func setUpCredential(result: GIDSignInResult) -> AuthCredential {
        return  GoogleAuthProvider.credential(withIDToken: setupGUser(result: result).idToken?.tokenString ?? "",
                                                        accessToken: setupGUser(result: result).accessToken.tokenString)
    }

    private func setupGUser(result: GIDSignInResult) -> GIDGoogleUser  {
        return result.user
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

    private func uploadUser(user: User, vc: UIViewController) {
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
            "owner": movement.properties.owner ?? "",
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
