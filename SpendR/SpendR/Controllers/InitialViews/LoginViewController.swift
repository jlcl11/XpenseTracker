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
   
    @IBAction func logInButton(_ sender: Any) {
        firebaseFuncs.loginWithEmailAndPassword(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", sender: self, destination: HomeViewController())
    }
    
    @IBAction func googleSignInButton(_ sender: Any) {
        firebaseFuncs.googleLogin(sender: self, destination: SignUpViewController())
    }
    
    @IBAction func goToSignInButton(_ sender: Any) {
        
        let signUpVC = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController

        UsefullFunctions().showNewPage(sender: self, destination: signUpVC)
    }
    
}
