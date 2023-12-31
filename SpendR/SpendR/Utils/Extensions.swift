//
//  Extensions.swift
//  SpendR
//
//  Created by José Luis Corral on 29/10/23.
//

import Foundation
import UIKit
import Charts

// MARK: - Color RGB Initializer
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

            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            return nil
        }
    }
}

// MARK: - Measuring Strings Length
extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

// MARK: - UITableViewDelegate 
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = movementsTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }

        let movement = filteredMovements[indexPath.row]

        if let amount = movement.properties.amount, let currency = UserManager.shared.getCurrentUser()?.properties.currency, let iconName = movement.tags.first?.properties?.iconName, let name = movement.properties.name {
            cell.priceLabel.textColor = movement.properties.isIncome ?? false ? .systemGreen : .red
            cell.priceLabel.text = "\(amount) \(currency)"
            cell.iconImage.image = UIImage(systemName: iconName)
            cell.iconImage.tintColor = movement.tags.first?.color
            cell.titleLabel.text = name
        } else {
            cell.priceLabel.text = ""
        }

        if let date = movement.properties.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.subtitleLabel.text = dateFormatter.string(from: date)
        } else {
            cell.subtitleLabel.text = "Ejemplo"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: SS
        let movementDetailVC = UIStoryboard(name: "MovementDetail", bundle: nil).instantiateViewController(withIdentifier: "MovementDetail") as! MovementDetailViewController
        movementDetailVC.movement = filteredMovements[indexPath.row]
        movementDetailVC.delegate = self
        UsefulFunctions.showNewPage(sender: self, destination: movementDetailVC)
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovements = filterMovementsByTagsAndSearchText(searchText: searchText, selectedTags: selectedTags)

        if filteredMovements.isEmpty && selectedTags.isEmpty {
            filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        } else if filteredMovements.isEmpty && !selectedTags.isEmpty {
            filterMovementsByTags()
        }

        movementsTableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()

        if filteredMovements.isEmpty && selectedTags.isEmpty {
            filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        } else if filteredMovements.isEmpty && !selectedTags.isEmpty {
            filterMovementsByTags()
        }

        sortMovements()
        movementsTableView.reloadData()
    }
    
    private func filterMovementsByTagsAndSearchText(searchText: String, selectedTags: Set<String>) -> [Movement] {
        let movementsBasedOnTags = selectedTags.isEmpty ? (UserManager.shared.getCurrentUser()?.movements ?? []) : (UserManager.shared.getCurrentUser()?.movements.filter { movement in
            let movementTags = movement.tags.compactMap { $0.properties?.name }
            return !selectedTags.isDisjoint(with: Set(movementTags))
        } ?? [])

        if searchText.isEmpty {
            return movementsBasedOnTags
        } else {
            return movementsBasedOnTags.filter { movement in
                let movementName = movement.properties.name ?? ""
                return movementName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - HomeScreenDelegate
extension HomeViewController: HomeScreenDelegate {

    func setUpScrollView() {
        let userTags = UserManager.shared.getCurrentUser()?.userTags ?? []
        removeButtonsFromScrollView(self.scrollView)
        createHorizontalScrollViewWithButtons(tags: userTags, scrollView: scrollView)
    }

    func setUpBalanceLabel()  {
        var balance: Double = 0
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


// MARK: - New Movement TextView Delegate
extension NewMovementViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        let characterLimit = 500

        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        return newText.count <= characterLimit
    }
}

// MARK: - New Movement TextField Delegate
extension NewMovementViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let characterLimit = 15
        return newText.count <= characterLimit
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Movement Properties Equatable
extension MovementProperties: Equatable {
    static func ==(lhs: MovementProperties, rhs: MovementProperties) -> Bool {
        return lhs.description == rhs.description &&
            lhs.amount == rhs.amount &&
            lhs.date == rhs.date &&
            lhs.isIncome == rhs.isIncome &&
            lhs.tags == rhs.tags
    }
}

// MARK: - GraphView Configuration
extension GraphViewController: ChartViewDelegate {

    func setupBarChart() {
        layoutBarChart()
    }

    func layoutBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height)
        graphView.addSubview(barChart)
        entries = generateChartDataEntries()
        barChart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let data = createBarChartData(with: entries)
        configureXAxis()
        configureYAxis()
        configureLegend()
        updateChartWithData(data)
    }

    func generateChartDataEntries() -> [BarChartDataEntry] {
        return filteredMovements.enumerated().map { index, movement in
            let yValue = calculateYValue(for: movement)
            return BarChartDataEntry(x: Double(index), y: yValue)
        }.sorted { $0.x < $1.x }
    }

    func calculateYValue(for movement: Movement) -> Double {
        var yValue = movement.properties.amount ?? 0.0
        if let isIncome = movement.properties.isIncome, !isIncome {
            yValue = -yValue
        }
        return yValue
    }

    func createBarChartData(with entries: [BarChartDataEntry]) -> BarChartData {
        let set = BarChartDataSet(entries: entries, label: "Amount")
        set.colors = gradientColors(values: entries.map { $0.y })
        set.valueTextColor = .label
        return BarChartData(dataSet: set)
    }

    func configureXAxis() {
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawLabelsEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values: getXAxisLabels())
    }

    func getXAxisLabels() -> [String] {
        var xAxisLabels: [String] = []
        for (index, movement) in filteredMovements.enumerated() {
            guard let movementDate = movement.properties.date else { continue }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            let label = dateFormatter.string(from: movementDate)
            if index % 2 == 0 {
                xAxisLabels.append(label)
            } else {
                xAxisLabels.append("")
            }
        }
        return xAxisLabels
    }

    func configureYAxis() {
        let leftAxis = barChart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawLabelsEnabled = true
    }

    func configureLegend() {
        let legend = barChart.legend
        legend.textColor = .label
        legend.form = .square
        legend.formSize = 12.0
        legend.formToTextSpace = 5.0
        legend.horizontalAlignment = .left
    }
}
