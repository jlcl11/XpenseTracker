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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPopup()
    }
 
    @IBAction func saveUser(_ sender: Any) {
        
        let newUser = User(properties: UserProperties(name: nameTextField.text, surname: surnameTextField.text, email: emailTextField.text, currency: currencies[currencyPopUpButton.titleLabel?.text ?? ""] ?? "", currencyName: currencyPopUpButton.title(for: .normal) ?? ""), userTags: [], movements: [])
        if validateInput() {
            FirebaseOperations().createUser(user: newUser, password: passwordTextField.text ?? "", vc: self)
        }
        
        
    }
    
    func validateInput() -> Bool {
        if nameTextField.text?.isEmpty ?? true || surnameTextField.text?.isEmpty ?? true || emailTextField.text?.isEmpty ?? true || passwordTextField.text?.isEmpty ?? true || confirmPasswordTextField.text?.isEmpty ?? true {
            UsefullFunctions().showAlert(title: "Oh no!", message: "You've left an empty field", viewController: self)
            return false
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            UsefullFunctions().showAlert(title: "Oh no!", message: "Passwords do not match", viewController: self)
            return false
        }
        
        return true
    }

    func setPopup () {
        let optionClosure = {(action: UIAction) in }
        
        var actions: [UIAction] = []
        for currency in currencies {
            actions.append(UIAction(title: currency.key, handler: optionClosure))
        }
        
        currencyPopUpButton.menu = UIMenu(children:actions)
        currencyPopUpButton.showsMenuAsPrimaryAction = true
        currencyPopUpButton.changesSelectionAsPrimaryAction = true
    }
}
