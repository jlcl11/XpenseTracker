//
//  NewMovementViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 1/11/23.
//

import UIKit

class NewMovementViewController: ReusableHorizontalScrollView {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomeSwitch: UISwitch!
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var decriptionTextView: UITextView!
    
    var tags:[Tag] = []
    
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

        let newMovement = Movement(properties: MovementProperties(description: decriptionTextView.text, amount: Double(amountTextField.text ?? "") ?? 0, date: datePicker.date, isIncome: incomeSwitch.isOn, tags: movementTagsProperties))
        print(newMovement)
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
    }
}
