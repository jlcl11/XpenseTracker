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
        setupView()
    }
    
    // MARK: - IBActions
    
    @IBAction func addNewMovement(_ sender: Any) {
        presentNewMovementPage()
    }
    
    @IBAction func goToGraphPage(_ sender: Any) {
        presentGraphPage()
    }
    
    @IBAction func goToUserPage(_ sender: Any) {
        presentUserPage()
    }
    
    // MARK: - View Setting
    
    private func setupView() {
        setTitleAndNavigation()
        setUpBalanceLabel()
        setupTableView()
        createHorizontalScrollViewWithButtons(tags: UserManager.shared.getCurrentUser()?.userTags ?? [], scrollView: scrollView)
        buttonAction = { button in
            self.filterMovementsByTags()
        }
        searchBar.delegate = self
    }
    
    private func setTitleAndNavigation() {
        title = "Welcome \(UserManager.shared.getCurrentUser()?.properties.name ?? "")"
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backButtonTitle = "Home"
    }

    private func setupTableView() {
        movementsTableView.delegate = self
        movementsTableView.dataSource = self
        movementsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        movementsTableView.reloadData()
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
    }
    
    // MARK: - Filtering
    
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
            filteredMovements.sort(by: { (first, second) in
                return isAscendingOrder ? (first.properties.date ?? Date()) < (second.properties.date ?? Date()) : (first.properties.date ?? Date()) > (second.properties.date ?? Date())
            })
        case .amount:
            filteredMovements.sort(by: { (first, second) in
                return isAscendingOrder ? (first.properties.amount ?? 0.0) < (second.properties.amount ?? 0.0) : (first.properties.amount ?? 0.0) > (second.properties.amount ?? 0.0)
            })
        }
        
        movementsTableView.reloadData()
    }
    
    func filterMovementsByTags() {
        filteredMovements = selectedTags.isEmpty ? (UserManager.shared.getCurrentUser()?.movements ?? []) : (UserManager.shared.getCurrentUser()?.movements.filter { movement in
            let movementTags = movement.tags.compactMap { $0.properties?.name }
            return !selectedTags.isDisjoint(with: Set(movementTags))
        } ?? [])
        
        movementsTableView.reloadData()
    }
    
    // MARK: - Navigation
    
    private func presentNewMovementPage() {
        let newMovement = UIStoryboard(name: "NewMovement", bundle: nil).instantiateViewController(withIdentifier: "NewMovement") as! NewMovementViewController
        newMovement.tags = UserManager.shared.getCurrentUser()?.userTags ?? []
        newMovement.delegate = self
        UsefulFunctions.presentNewPage(sender: self, destination: newMovement)
    }
    
    private func presentGraphPage() {
        let graphController = UIStoryboard(name: "Graph", bundle: nil).instantiateViewController(withIdentifier: "Graph") as! GraphViewController
        UsefulFunctions.showNewPage(sender: self, destination: graphController)
    }
    
    private func presentUserPage() {
        let userPage = UIStoryboard(name: "UserPage", bundle: nil).instantiateViewController(withIdentifier: "UserPage") as! UserPageViewController
        userPage.delegate = self
        UsefulFunctions.showNewPage(sender: self, destination: userPage)
    }
}
