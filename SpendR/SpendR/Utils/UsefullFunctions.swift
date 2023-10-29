//
//  UsefullFunctions.swift
//  SpendR
//
//  Created by José Luis Corral López on 21/9/23.
//

import Foundation
import UIKit

class UsefullFunctions {
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showNewPage( sender: UIViewController, destination: UIViewController) {
        
    }
}
