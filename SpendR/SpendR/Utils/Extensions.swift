//
//  Extensions.swift
//  SpendR
//
//  Created by José Luis Corral on 29/10/23.
//

import Foundation
import UIKit
 
// MARK: Color rgb initializer
extension UIColor {

    convenience init(rgb: Int) {
            let iBlue = rgb & 0xFF
            let iGreen =  (rgb >> 8) & 0xFF
            let iRed =  (rgb >> 16) & 0xFF
            let iAlpha =  (rgb >> 24) & 0xFF
            self.init(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255,
                      blue: CGFloat(iBlue)/255, alpha: CGFloat(iAlpha)/255)
        }
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

// MARK: Meassuring Strings length
extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

//MARK: Setting up the TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = movementsTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        
        let movement = filteredMovements[indexPath.row]
        
        if let amount = movement.properties.amount, let currency = UserManager.shared.getCurrentUser()?.properties.currency, let iconName = movement.tags.first?.properties?.iconName, let description = movement.properties.description {
            cell.priceLabel.textColor = movement.properties.isIncome ?? false ? .systemGreen : .red
            cell.priceLabel.text = "\(amount) \(currency)"
            cell.iconImage.image = UIImage(systemName: iconName)
            cell.iconImage.tintColor = movement.tags.first?.color
            cell.titleLabel.text = description
        } else {
            cell.priceLabel.text = ""
        }
        
        if let date = movement.properties.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.subtitleLabel.text = dateFormatter.string(from: date)
        } else {
            cell.subtitleLabel.text = "Ejemplo"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movementDetailVC = UIStoryboard(name: "MovementDetail", bundle: nil).instantiateViewController(withIdentifier: "MovementDetail") as! MovementDetailViewController
        movementDetailVC.movement = filteredMovements[indexPath.row]
        movementDetailVC.delegate = self
        UsefullFunctions().showNewPage(sender: self, destination: movementDetailVC)
    }
}

// MARK: Setting Up the Search bar

extension HomeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovements = filterMovementsByTagsAndSearchText(searchText: searchText)
        
        if filteredMovements.isEmpty { filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? [] }
        
        movementsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        if filteredMovements.isEmpty { filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []}
        sortMovements()
        
        movementsTableView.reloadData()
    }
}

//MARK: Home screen Delegate
extension HomeViewController: homeScreenDelegate {
    func setUpBalanceLabel()  {
        var balance:Double = 0
        if let movements = UserManager.shared.getCurrentUser()?.movements {
            for movement in movements {
                balance += (movement.properties.isIncome ?? false) ? (movement.properties.amount ?? 0) : -(movement.properties.amount ?? 0)
            }
        }
        var user: User = UserManager.shared.getCurrentUser() ?? User(properties: UserProperties(name: "", surname: "", email: "", currency: "", currencyName: ""), userTags: [], movements: [])
        user.properties.balance = balance
        UserManager.shared.setCurrentUser(user)
        
        balanceLabel.textColor = (UserManager.shared.getCurrentUser()?.properties.balance ?? 0 > 0) ? .systemGreen : (UserManager.shared.getCurrentUser()?.properties.balance ?? 0 < 0) ? .red : .black
        guard let currency = UserManager.shared.getCurrentUser()?.properties.currency else {
            return
        }

        balanceLabel.text = "\(balance) \(currency)"
    }
    
    func didAddNewMovement() {
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        sortMovements()
    }
}

// MARK: New movement text delegate
extension NewMovementViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text as NSString
            let newText = currentText.replacingCharacters(in: range, with: text)
            let characterLimit = 100
        return newText.count <= characterLimit
        }
}

//MARK: Movement properties equatable

extension MovementProperties: Equatable {
    // Implementa la función == para comparar dos instancias de MovementProperties
    static func ==(lhs: MovementProperties, rhs: MovementProperties) -> Bool {
        return lhs.description == rhs.description &&
            lhs.amount == rhs.amount &&
            lhs.date == rhs.date &&
            lhs.isIncome == rhs.isIncome &&
            lhs.tags == rhs.tags
    }
}
