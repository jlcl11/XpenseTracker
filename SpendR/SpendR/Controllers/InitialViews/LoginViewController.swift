//
//  LoginViewController.swift
//  SpendR
//
//  Created by José Luis Corral López on 20/9/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebaseFuncs: FirebaseOperations = FirebaseOperations()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    //MARK: IBACtions
   
    @IBAction func logInButton(_ sender: Any) {
        login()
    }
    
    @IBAction func googleSignInButton(_ sender: Any) {
        googleLogin()
    }
    
    @IBAction func goToSignInButton(_ sender: Any) {
        navigateToSignUp()
    }
    
    // MARK: - Private Functions
    
    private func login() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        firebaseFuncs.loginWithEmailAndPassword(email: email, password: password, sender: self, destination: HomeViewController())
    }

    private func googleLogin() {
        firebaseFuncs.googleLogin(sender: self, destination: SignUpViewController())
    }

    private func navigateToSignUp() {
        let signUpVC = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController
        UsefulFunctions.showNewPage(sender: self, destination: signUpVC)
    }
}
