//
//  SignUpViewController.swift
//  SpendR
//
//  Created by José Luis Corral López on 25/9/23.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var currencyPopUpButton: UIButton!
    
    let currencies: [String: String] = [
        "US Dollar": "$", "Euro": "€", "Japanese Yen": "¥", "British Pound": "£", "Australian Dollar": "A$", "Canadian Dollar": "C$", "Swiss Franc": "₣", "Chinese Yuan": "¥", "Indian Rupee": "₹", "Mexican Peso": "Mex$"]
    
    //MARK: IBActions
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrencyPopup()
    }
 
    @IBAction func saveUser(_ sender: Any) {
        saveNewUser()
    }
    
    // MARK: User saving
    
    private func saveNewUser() {
        let newUser = User(
            properties: UserProperties(
                name: nameTextField.text,
                surname: surnameTextField.text,
                email: emailTextField.text,
                currency: currencies[currencyPopUpButton.titleLabel?.text ?? ""] ?? "",
                currencyName: currencyPopUpButton.title(for: .normal) ?? ""
            ),
            userTags: [],
            movements: []
        )
        
        if validateInput() {
            FirebaseOperations().createUser(user: newUser, password: passwordTextField.text ?? "", vc: self)
        }
    }
    
    private func validateInput() -> Bool {
        guard let name = nameTextField.text, let surname = surnameTextField.text,
              let email = emailTextField.text, let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            return false
        }
        
        if name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            showAlert(title: "Oh no!", message: "You've left an empty field")
            return false
        }
        
        if password != confirmPassword {
            showAlert(title: "Oh no!", message: "Passwords do not match")
            return false
        }
        
        return true
    }

    //MARK: View Setting
    private func setCurrencyPopup() {
        let optionClosure = { (action: UIAction) in }
        
        var actions: [UIAction] = []
        for currency in currencies {
            actions.append(UIAction(title: currency.key, handler: optionClosure))
        }
        
        currencyPopUpButton.menu = UIMenu(children: actions)
        currencyPopUpButton.showsMenuAsPrimaryAction = true
        currencyPopUpButton.changesSelectionAsPrimaryAction = true
    }

    private func showAlert(title: String, message: String) {
        UsefulFunctions.showAlert(title: title, message: message, viewController: self)
    }
}
