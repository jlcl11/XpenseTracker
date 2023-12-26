//
//  UserPageViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 22/11/23.
//

import SwiftUI
import UIKit
import SymbolPicker

//MARK: SwiftUI View
class CounterModel: ObservableObject {
    @Published var icon: String = "pencil"
}

struct SymbolPickerView: View {
    @State private var iconPickerPresented = false
    @ObservedObject var counterModel = CounterModel()
    @ObservedObject var userPageViewController: UserPageViewController

    var body: some View {
        Button {
            iconPickerPresented = true
        } label: {
            HStack {
                Image(systemName: counterModel.icon)
                    .resizable().frame(width: 35, height: 30)
            }
            .foregroundColor(userPageViewController.buttonColor)
        }
        .sheet(isPresented: $iconPickerPresented) {
            SymbolPicker(symbol: $counterModel.icon)
        }
    }
}

//MARK: Viewcontroller
class UserPageViewController: ReusableHorizontalScrollView, ObservableObject{

    @IBOutlet weak var currencyPopUpButton: UIButton!
    @IBOutlet weak var tagsScrollView: UIScrollView!
    @IBOutlet weak var newTagView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var swiftUIViewContainer: UIView!

    let currencies: [String: String] = [
        "US Dollar": "$", "Euro": "€", "Japanese Yen": "¥", "British Pound": "£", "Australian Dollar": "A$", "Canadian Dollar": "C$", "Swiss Franc": "₣", "Chinese Yuan": "¥", "Indian Rupee": "₹", "Mexican Peso": "Mex$"]
    weak var delegate: HomeScreenDelegate?
    var swiftUIHostingController: UIHostingController<SymbolPickerView>?
    @Published var buttonColor: Color = .blue

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    //MARK: IBActions
    @IBAction func addTag(_ sender: Any) {
        newTagView.isHidden.toggle()
        newTagView.isHidden = newTagView.isHidden ? true : false
    }

    @IBAction func saveTag(_ sender: Any) {
        if let mySwiftUIView = swiftUIHostingController?.rootView {
            let cancellable = mySwiftUIView.counterModel.$icon.sink { value in
                var user = UserManager.shared.getCurrentUser()
                let tag = Tag(properties: TagProperties(iconName: value, color: self.colorWell.selectedColor?.rgb(), name: self.nameTextField.text))
                user?.userTags.append(tag)
                UserManager.shared.setCurrentUser(user ?? User(properties: UserProperties(name: "", surname: "", email: "", currency: "", currencyName: ""), userTags: [], movements: []))
                self.removeButtonsFromScrollView(self.tagsScrollView)
                self.createHorizontalScrollViewWithButtons(tags: user?.userTags ?? [] , scrollView: self.tagsScrollView)
                self.delegate?.setUpScrollView()
                FirebaseOperations().uploadUser(user: user ?? User(properties: UserProperties(name: "", surname: "", email: "", currency: "", currencyName: ""), userTags: [], movements: []), vc: self)
               }
               cancellable.cancel()
               newTagView.isHidden.toggle()
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        UsefulFunctions.showWarningConfirmationAlert(title: "Are you sure?", message: "You will log out", viewController: self){
            FirebaseOperations().logout(sender: self)
        }
    }
    
    //MARK: View setting
    func setupView(){
        setupTagsScrollView()
        navigationController?.navigationBar.prefersLargeTitles = true
        setPopup()
        colorWell.addTarget(self, action: #selector(colorWellChangedColor(_:)), for: .valueChanged)
        newTagView.isHidden = true
        setupSymbolPicker()
        buttonAction = { button in
            UsefulFunctions.showWarningConfirmationAlert(title: "Are you sure?", message: "You will delete this tag and all the movements that tag contains", viewController: self){
                self.deleteTag(button: button)
            }
        }
    }
    
    private func setupSymbolPicker() {
        let symbolPickerView = SymbolPickerView(userPageViewController: self)
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
    
    //MARK: Viewcontroller logic
    private func deleteTag(button: UIButton) {
        guard let tagName = button.titleLabel?.text else { return }
       
        if let index = self.classTags.firstIndex(where: { $0.properties?.name == tagName }) {
            
            guard var currentUser = UserManager.shared.getCurrentUser() else {
                return
            }
           
            currentUser.userTags.remove(at: index)
            currentUser.movements = currentUser.movements.filter { movement in
                !movement.tags.contains { $0.properties?.name == tagName }
            }
            
            self.removeButtonsFromScrollView(self.tagsScrollView)
            createHorizontalScrollViewWithButtons(tags: currentUser.userTags, scrollView: tagsScrollView)
            UserManager.shared.setCurrentUser(currentUser)
            FirebaseOperations().uploadUser(user: currentUser, vc: self)
            delegate?.setUpScrollView()
            delegate?.setUpBalanceLabel()
            delegate?.didAddNewMovement()
        }
    }
    
    @objc func colorWellChangedColor(_ sender: UIButton) {
          colorLabel.textColor = colorWell.selectedColor
        let swiftUIColor = Color(colorWell.selectedColor ?? .black)
          buttonColor = swiftUIColor
      }
}
