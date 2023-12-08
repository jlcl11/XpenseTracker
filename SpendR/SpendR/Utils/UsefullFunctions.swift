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
    
    func showWarningConfirmationAlert(title: String, message: String, viewController: UIViewController, dismissButtonTitle: String = "Cancel", executeButtonTitle: String = "Ok", executeAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: UIAlertAction.Style.default, handler: nil))
        
        let action = UIAlertAction(title: executeButtonTitle, style: UIAlertAction.Style.destructive) { _ in
            executeAction?() 
        }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showNewPage( sender: UIViewController, destination: UIViewController) {
        sender.show(destination, sender: sender)
    }
    
    func presentNewPage( sender: UIViewController, destination: UIViewController) {
        let navVC = UINavigationController(rootViewController: destination)
        sender.present(navVC, animated: true)
    }
}
