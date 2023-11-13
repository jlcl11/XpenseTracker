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
    @IBOutlet weak var deteleMovement: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var movement:Movement?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
    }
    
    @IBAction func deleteMovementButton(_ sender: Any) {
        if let currentUser = UserManager.shared.getCurrentUser(),
             let movementToRemove = movement {
             
             currentUser.movements.removeAll { $0 == movementToRemove }
        
         }
    }
    
    private func viewSetting() {
        title = movement?.properties.description
        incomeLableConfiguration()
        datePicker.date = movement?.properties.date ?? Date()
        createHorizontalScrollViewWithButtons(tags: movement?.tags ?? [], scrollView: tagsScrollView)
        descriptionTextView.isEditable = false
    }
    
    func incomeLableConfiguration() {
        if let amount = movement?.properties.amount, let currency = UserManager.shared.getCurrentUser()?.properties.currency {
            incomeLabel.text = "\(amount) \(currency)"
        }
        incomeLabel.textColor = movement?.properties.isIncome ?? false ? .green : .red
    }
}
