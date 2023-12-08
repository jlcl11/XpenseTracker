//
//  NewMovementViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 1/11/23.
//

import UIKit

protocol HomeScreenDelegate: class {
    func didAddNewMovement()
    func setUpBalanceLabel()
    func setUpScrollView()
}

class NewMovementViewController: ReusableHorizontalScrollView {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var incomeSwitch: UISwitch!
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var tags: [Tag] = []
    weak var delegate: HomeScreenDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: IBAactions
    @IBAction func incomeSwitchValueChanged(_ sender: Any) {
        updateIncomeSwitchAppearance()
    }
    @IBAction func saveMovement(_ sender: Any) {
        saveNewMovement()
    }
    
    // MARK: - View Settings
    
    private func setupView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        selectedTags = []
        createHorizontalScrollViewWithButtons(tags: tags, scrollView: tagScrollView)
        
        let calendar = Calendar.current
        datePicker.maximumDate = Date()
        datePicker.minimumDate = calendar.date(byAdding: .year, value: -1, to: Date())
        descriptionTextView.delegate = self
        nameTextField.delegate = self
    }
    
    private func updateIncomeSwitchAppearance() {
        incomeSwitch.thumbTintColor = incomeSwitch.isOn ? .white : .red
    }
    
    private func dismissView() {
        self.dismiss(animated: true) {
            self.delegate?.setUpBalanceLabel()
            self.delegate?.didAddNewMovement()
        }
    }
    
    //MARK: - Movement saving
    private func saveNewMovement() {
        let movementTagsProperties = selectedTags.compactMap { tagName in
            return tags.first { $0.properties?.name == tagName }?.properties
        }
        let newMovement = Movement(
            properties: MovementProperties(
                name: nameTextField.text,
                description: descriptionTextView.text,
                amount: Double(amountTextField.text ?? "") ?? 0,
                date: datePicker.date,
                isIncome: incomeSwitch.isOn,
                tags: movementTagsProperties
            )
        )
        
        if var currentUser = UserManager.shared.getCurrentUser() {
            currentUser.movements.append(newMovement)
            UserManager.shared.setCurrentUser(currentUser)
            FirebaseOperations().uploadUser(user: currentUser, vc: self)
        }
        
        dismissView()
    }

}
