//
//  UserPageViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 22/11/23.
//

import SwiftUI
import UIKit
import SymbolPicker

struct SymbolPickerView: View {
    @State private var iconPickerPresented = false
    @State var icon = "pencil"
    @State var iconName = ""

    var body: some View {
        Button {
            iconPickerPresented = true
        } label: {
            HStack {
                Image(systemName: icon)
            }
        }
        .sheet(isPresented: $iconPickerPresented) {
            SymbolPicker(symbol: $icon)
        }
        .onChange(of: icon) { newIcon in
            iconName = newIcon
            print(iconName)
        }
    }
}


class UserPageViewController: ReusableHorizontalScrollView {

    @IBOutlet weak var currencyPopUpButton: UIButton!
    @IBOutlet weak var tagsScrollView: UIScrollView!
    @IBOutlet weak var newTagView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var swiftUIViewContainer: UIView!

    let currencies: [String: String] = [
        "US Dollar": "$", "Euro": "€", "Japanese Yen": "¥", "British Pound": "£", "Australian Dollar": "A$", "Canadian Dollar": "C$", "Swiss Franc": "₣", "Chinese Yuan": "¥", "Indian Rupee": "₹", "Mexican Peso": "Mex$"]
    weak var delegate: homeScreenDelegate?
    var swiftUIHostingController: UIHostingController<SymbolPickerView>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func addTag(_ sender: Any) {
        newTagView.isHidden.toggle()
        newTagView.isHidden = newTagView.isHidden ? true : false
    }
    
    @IBAction func saveTag(_ sender: Any) {
        if let mySwiftUIView = swiftUIHostingController?.rootView {
            let tag = Tag(properties: TagProperties(iconName: mySwiftUIView.icon,color: colorWell.selectedColor?.rgb(), name: nameTextField.text))
            print(tag)
            newTagView.isHidden.toggle()
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        FirebaseOperations().logout(sender: self)
    }
    
    @objc func colorWellChangedColor(_ sender: UIButton) {
        colorLabel.textColor = colorWell.selectedColor
    }
    
    func setupView(){
        setupTagsScrollView()
        navigationController?.navigationBar.prefersLargeTitles = true
        setPopup()
        colorWell.addTarget(self, action: #selector(colorWellChangedColor(_:)), for: .valueChanged)
        newTagView.isHidden = true
        setupSymbolPicker()
    }
    
    private func setupSymbolPicker() {
        let symbolPickerView = SymbolPickerView()
        swiftUIHostingController = UIHostingController(rootView: symbolPickerView)
        addChild(swiftUIHostingController!)
        swiftUIViewContainer.addSubview(swiftUIHostingController!.view)
        swiftUIHostingController!.view.translatesAutoresizingMaskIntoConstraints = false
        swiftUIHostingController!.view.topAnchor.constraint(equalTo: swiftUIViewContainer.topAnchor).isActive = true
        swiftUIHostingController!.view.leadingAnchor.constraint(equalTo: swiftUIViewContainer.leadingAnchor).isActive = true
        swiftUIHostingController!.view.trailingAnchor.constraint(equalTo: swiftUIViewContainer.trailingAnchor).isActive = true
        swiftUIHostingController!.view.bottomAnchor.constraint(equalTo: swiftUIViewContainer.bottomAnchor).isActive = true
        swiftUIHostingController!.didMove(toParent: self)
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
