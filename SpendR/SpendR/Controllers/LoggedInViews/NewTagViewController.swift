//
//  NewTagViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 29/11/23.
//

import UIKit
import SwiftUI
import SymbolPicker

class NewTagViewController: UIViewController {
    
    @IBOutlet weak var nametextField: UITextField!

    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var symbolPicker: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        colorWell.addTarget(self, action: #selector(colorWellChangedColor(_:)), for: .valueChanged)

    }
    
    @objc func colorWellChangedColor(_ sender: UIButton) {
        colorLabel.textColor = colorWell.selectedColor
    }
   
    @IBAction func saveTag(_ sender: Any) {
    }
}
