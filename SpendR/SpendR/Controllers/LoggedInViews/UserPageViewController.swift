//
//  UserPageViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 22/11/23.
//

import UIKit

class UserPageViewController: ReusableHorizontalScrollView {

    @IBOutlet weak var currencyPopUpButton: UIButton!
    @IBOutlet weak var tagsScrollView: UIScrollView!

    let currencies: [String: String] = [
        "US Dollar": "$", "Euro": "€", "Japanese Yen": "¥", "British Pound": "£", "Australian Dollar": "A$", "Canadian Dollar": "C$", "Swiss Franc": "₣", "Chinese Yuan": "¥", "Indian Rupee": "₹", "Mexican Peso": "Mex$"]
    weak var delegate: homeScreenDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTagsScrollView()
        navigationController?.navigationBar.prefersLargeTitles = true
        setPopup()
      
    }

    @IBAction func addTag(_ sender: Any) {
        let newTag = UIStoryboard(name: "NewTag", bundle: nil).instantiateViewController(withIdentifier: "NewTag") as! NewTagViewController
        
        UsefullFunctions().presentNewPage(sender: self, destination: newTag)
    }

    @IBAction func logOut(_ sender: Any) {
        FirebaseOperations().logout(sender: self)
    }

    private func setupTagsScrollView() {
        guard let currentUser = UserManager.shared.getCurrentUser() else {
            return
        }

        createHorizontalScrollViewWithButtons(tags: currentUser.userTags, scrollView: tagsScrollView)
    }

    private func setPopup() {
        guard let userCurrency = UserManager.shared.getCurrentUser()?.properties.currency,
            let currencyEntry = currencies.first(where: { $0.value == userCurrency }) else {
                return
        }

        let optionClosure = { [weak self] (action: UIAction) in
            guard let self = self else { return }

            var user = UserManager.shared.getCurrentUser()

            user?.properties.currency = self.currencies[action.title] ?? ""
            user?.properties.currencyName = action.title

            UserManager.shared.setCurrentUser(user ?? User(properties: UserProperties(name: "", surname: "", email: "", currency: "", currencyName: ""), userTags: [], movements: []))

            FirebaseOperations().uploadUser(user: user!, vc: self)
                self.delegate?.setUpBalanceLabel()
                self.delegate?.didAddNewMovement()
        }

        var actions: [UIAction] = []

        let userCurrencyAction = UIAction(title: currencyEntry.key, handler: optionClosure)
        actions.append(userCurrencyAction)

        let otherCurrencies = currencies.filter { $0.key != currencyEntry.key }
        let sortedOtherCurrencies = otherCurrencies.sorted { $0.key < $1.key }

        for currency in sortedOtherCurrencies {
            let action = UIAction(title: currency.key, handler: optionClosure)
            actions.append(action)
        }

        currencyPopUpButton.menu = UIMenu(children: actions)
        currencyPopUpButton.showsMenuAsPrimaryAction = true
        currencyPopUpButton.changesSelectionAsPrimaryAction = true
    }

}
