//
//  HomeViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 30/10/23.
//

import UIKit

class HomeViewController: UIViewController {
    enum SortCriteria {
        case date
        case amount
    }

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movementsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var loggedUser: User?
    var currentSortCriteria: SortCriteria = .date
    var isAscendingOrder: Bool = true
    var selectedTags: Set<String> = []
    var filteredMovements: [Movement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        viewSetting()
    }
    
    // MARK: Filtering
    
    @IBAction func sortByDateOrValue(_ sender: Any) {
        currentSortCriteria = (sender as AnyObject).selectedSegmentIndex == 0 ? .date : .amount

        sortMovements()
    }
    
    @IBAction func sortByAscendingOrDescending(_ sender: Any) {
        isAscendingOrder = (sender as AnyObject).selectedSegmentIndex == 0
        sortMovements()
    }
    
    
    func sortMovements() {
        switch currentSortCriteria {
        case .date:
            if isAscendingOrder {
                filteredMovements.sort { $0.properties.date ?? Date() < $1.properties.date ?? Date() }
            } else {
                filteredMovements.sort { $0.properties.date ?? Date() > $1.properties.date ?? Date() }
            }
        case .amount:
            if isAscendingOrder {
                filteredMovements.sort { $0.properties.amount ?? 0.0 < $1.properties.amount ?? 0.0 }
            } else {
                filteredMovements.sort { $0.properties.amount ?? 0.0 > $1.properties.amount ?? 0.0 }
            }
        }
        
        movementsTableView.reloadData()
    }
    
    private func filterMovementsByTags() {
        filteredMovements = selectedTags.isEmpty ? (loggedUser?.movements ?? []) : (loggedUser?.movements.filter { movement in
            let movementTags = movement.tags.compactMap { $0.properties?.name }
            return !selectedTags.isDisjoint(with: Set(movementTags))
        } ?? [])
        
        movementsTableView.reloadData()
    }
    
    // MARK: View Setting
    
    private func viewSetting() {
        setUpView()
        setUpTableView()
        createHorizontalScrollViewWithButtons()
        searchBar.delegate = self
    }
    
    private func setUpView() {
        title = "Welcome \(loggedUser?.properties.name ?? "")"
        balanceLabel.text = "\(loggedUser?.properties.balance ?? 0) \(loggedUser?.properties.currency ?? "")"
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backButtonTitle = "Home"
        balanceLabel.textColor = (loggedUser?.properties.balance ?? 0 > 0) ? .systemGreen : (loggedUser?.properties.balance ?? 0 < 0) ? .red : .black
    }

    private func setUpTableView() {
        movementsTableView.delegate = self
        movementsTableView.dataSource = self
        movementsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        movementsTableView.reloadData()
        filteredMovements = loggedUser?.movements ?? []
    }
    
    // MARK: Horizontal buttons setup
    
    private func createHorizontalScrollViewWithButtons() {
        var xOffset: CGFloat = 10.0
        var tagNames: [String] = []
        
        if let userTags = loggedUser?.userTags { tagNames = userTags.compactMap { $0.properties?.name } }
        
        for tagName in tagNames {
            let button = UIButton(type: .system)
            let buttonWidth = tagName.width(withConstrainedHeight: 40, font: UIFont.systemFont(ofSize: 17.0))
            button.frame = CGRect(x: xOffset, y: 0, width: buttonWidth + 20.0, height: 40)
         
            setDefaultHorizontalButtons(button: button, tagName: tagName)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            xOffset += buttonWidth + 30.0
        }
        
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }
    
    private func setColoredHorizontalButtons( button: UIButton, tag: Tag) {
        button.layer.backgroundColor = tag.color?.cgColor
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    private func setDefaultHorizontalButtons ( button: UIButton, tagName: String) {
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.setTitleColor(.gray, for: .normal)
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 20.0
        button.backgroundColor = UIColor.clear
        button.setTitle(tagName, for: .normal)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        guard let tagName = sender.titleLabel?.text else { return }
        
        if selectedTags.contains(tagName) {
            selectedTags.remove(tagName)
        } else {
            selectedTags.insert(tagName)
        }
        
        updateButtonAppearance(sender)
        filterMovementsByTags()
    }
    
    private func updateButtonAppearance(_ button: UIButton) {
        guard let tagName = button.titleLabel?.text else { return }
        if let tag = loggedUser?.userTags.first(where: { $0.properties?.name == tagName }) {
            selectedTags.contains(tagName) ? setColoredHorizontalButtons(button: button, tag: tag) : setDefaultHorizontalButtons(button: button, tagName: tagName)
        }
    }
}
