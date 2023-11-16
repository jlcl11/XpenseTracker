//
//  HomeViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 30/10/23.
//

import UIKit

class HomeViewController: ReusableHorizontalScrollView  {
    enum SortCriteria {
        case date
        case amount
    }
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movementsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var currentSortCriteria: SortCriteria = .date
    var isAscendingOrder: Bool = true
    var filteredMovements: [Movement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
    }
    
    @IBAction func addMovementButton(_ sender: Any) {
        let newMovement = UIStoryboard(name: "NewMovement", bundle: nil).instantiateViewController(withIdentifier: "NewMovement") as! NewMovementViewController
        newMovement.tags = UserManager.shared.getCurrentUser()?.userTags ?? []
        newMovement.delegate = self
        UsefullFunctions().presentNewPage(sender: self, destination: newMovement)
    }
    
    // MARK: View Setting
    
    private func viewSetting() {
        setUpView()
        setUpTableView()
        createHorizontalScrollViewWithButtons(tags: UserManager.shared.getCurrentUser()?.userTags ?? [], scrollView: scrollView)
        buttonAction = { button in
            self.filterMovementsByTags()
              }
        searchBar.delegate = self
    }
    
    private func setUpView() {
        title = "Welcome \(UserManager.shared.getCurrentUser()?.properties.name ?? "")"
        setUpBalanceLabel()
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backButtonTitle = "Home"
    }

    private func setUpTableView() {
        movementsTableView.delegate = self
        movementsTableView.dataSource = self
        movementsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        movementsTableView.reloadData()
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
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
        filteredMovements = selectedTags.isEmpty ? (UserManager.shared.getCurrentUser()?.movements ?? []) : (UserManager.shared.getCurrentUser()?.movements.filter { movement in
            let movementTags = movement.tags.compactMap { $0.properties?.name }
            return !selectedTags.isDisjoint(with: Set(movementTags))
        } ?? [])
        
        movementsTableView.reloadData()
    }
    
    func filterMovementsByTagsAndSearchText(searchText: String) -> [Movement] {
        let movementsBasedOnTags = selectedTags.isEmpty ? (UserManager.shared.getCurrentUser()?.movements ?? []) : (UserManager.shared.getCurrentUser()?.movements.filter { movement in
            let movementTags = movement.tags.compactMap { $0.properties?.name }
            return !selectedTags.isDisjoint(with: Set(movementTags))
        } ?? [])
        
        if searchText.isEmpty {
            return movementsBasedOnTags
        } else {
            return movementsBasedOnTags.filter { movement in
                return movement.properties.description?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}
