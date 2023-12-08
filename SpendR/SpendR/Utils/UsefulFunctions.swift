//
//  UsefullFunctions.swift
//  SpendR
//
//  Created by José Luis Corral López on 21/9/23.
//

import Foundation
import UIKit

class UsefulFunctions {

    //MARK: Alerts
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    static func showWarningConfirmationAlert(title: String, message: String, viewController: UIViewController, dismissButtonTitle: String = "Cancel", executeButtonTitle: String = "Ok", executeAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil))

        let action = UIAlertAction(title: executeButtonTitle, style: .destructive) { _ in
            executeAction?()
        }
        alert.addAction(action)

        viewController.present(alert, animated: true, completion: nil)
    }

    //MARK: Navigation
    static func showNewPage(sender: UIViewController, destination: UIViewController) {
        sender.show(destination, sender: sender)
    }

    static func presentNewPage(sender: UIViewController, destination: UIViewController) {
        let navVC = UINavigationController(rootViewController: destination)
        sender.present(navVC, animated: true)
    }
}
