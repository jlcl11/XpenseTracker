//
//  MovementDetailViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 11/11/23.
//

import UIKit

class MovementDetailViewController: ReusableHorizontalScrollView {
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var tagsScrollView: UIScrollView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var movement: Movement?
    weak var delegate: HomeScreenDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @IBAction func deleteMovement(_ sender: Any) {
        UsefulFunctions.showWarningConfirmationAlert(
            title: "Are you sure?",
            message: "You will delete this movement",
            viewController: self
        ) {
            self.deleteMovement()
        }
    }
    
    // MARK: - View Setting
    
    private func setupView() {
        title = movement?.properties.name
        configureIncomeLabel()
        datePicker.date = movement?.properties.date ?? Date()
        createHorizontalScrollViewWithButtons(tags: movement?.tags ?? [], scrollView: tagsScrollView)
        descriptionTextView.isEditable = false
        descriptionTextView.text = movement?.properties.description
    }
    
    private func configureIncomeLabel() {
        guard let amount = movement?.properties.amount, let currency = UserManager.shared.getCurrentUser()?.properties.currency else {
            return
        }
        incomeLabel.text = "\(amount) \(currency)"
        incomeLabel.textColor = movement?.properties.isIncome ?? false ? .green : .red
    }
    
//MARK: Movement deleting logic
    private func deleteMovement() {
        if var currentUser = UserManager.shared.getCurrentUser() {
            currentUser.movements.removeAll { $0 == self.movement }
            FirebaseOperations().uploadUser(user: currentUser, vc: self)
            UserManager.shared.setCurrentUser(currentUser)
            self.delegate?.didAddNewMovement()
            self.delegate?.setUpBalanceLabel()
            self.navigationController?.popViewController(animated: true)
        }
    }
}
