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
    
    // MARK: LOGIN FUNCS
    // All the needed functions used in the Login Page
    
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



}
