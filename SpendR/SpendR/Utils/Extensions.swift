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
        
        if let amount = movement.properties.amount, let currency = self.loggedUser?.properties.currency, let iconName = movement.tags.first?.properties?.iconName, let description = movement.properties.description {
            cell.priceLabel.textColor = amount.isLess(than: 0) ? .red : .systemGreen
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
}

// MARK: Setting Up the Search bar

extension HomeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovements = loggedUser?.movements.filter { movement in
            return movement.properties.description?.localizedCaseInsensitiveContains(searchText) ?? false
        } ?? loggedUser!.movements

        if filteredMovements.isEmpty { filteredMovements = loggedUser?.movements ?? []}
        movementsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        filteredMovements = loggedUser?.movements ?? loggedUser!.movements
        sortMovements()
        
        movementsTableView.reloadData()
    }

}

