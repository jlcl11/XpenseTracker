//
//  NewMovementViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 1/11/23.
//

import UIKit

class NewMovementViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var incomeSwitch: UISwitch!
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var decriptionTextView: UITextView!
    
    var tags:[Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func incomeSwitch(_ sender: Any) {
        incomeSwitch.thumbTintColor = incomeSwitch.isOn ? .white : .red
    }
    
    @IBAction func saveMovement(_ sender: Any) {
    }
}
