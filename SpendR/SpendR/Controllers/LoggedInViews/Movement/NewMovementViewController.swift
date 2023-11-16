//
//  NewMovementViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 1/11/23.
//

import UIKit

protocol homeScreenDelegate: class {
    func didAddNewMovement()
    func setUpBalanceLabel() 
}

class NewMovementViewController: ReusableHorizontalScrollView {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomeSwitch: UISwitch!
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var decriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var tags:[Tag] = []
    weak var delegate: homeScreenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @IBAction func incomeSwitch(_ sender: Any) {
        incomeSwitch.thumbTintColor = incomeSwitch.isOn ? .white : .red
    }
    
    @IBAction func saveMovement(_ sender: Any) {
        let movementTagsProperties = selectedTags.compactMap { tagName in
            return tags.first { $0.properties?.name == tagName }?.properties
        }
        let newMovement = Movement(properties: MovementProperties(name: nameTextField.text, description: decriptionTextView.text, amount: Double(amountTextField.text ?? "") ?? 0, date: datePicker.date, isIncome: incomeSwitch.isOn, tags: movementTagsProperties))
        if var currentUser = UserManager.shared.getCurrentUser() {
                currentUser.movements.append(newMovement)
            UserManager.shared.setCurrentUser(currentUser)
            FirebaseOperations().uploadUser(user: currentUser, vc: self)
            }
        self.dismiss(animated: true) {
            self.delegate?.setUpBalanceLabel()
            self.delegate?.didAddNewMovement()
           }
    }
    
    //MARK: View Setting
    private func setupView(){
        navigationController?.navigationBar.prefersLargeTitles = true
        selectedTags = []
        createHorizontalScrollViewWithButtons(tags: tags, scrollView: tagScrollView)
        
        let calendar = Calendar.current
            datePicker.maximumDate = Date()
            datePicker.minimumDate = calendar.date(byAdding: .year, value: -1, to: Date())
        decriptionTextView.delegate = self
        nameTextField.delegate = self
    }
}
