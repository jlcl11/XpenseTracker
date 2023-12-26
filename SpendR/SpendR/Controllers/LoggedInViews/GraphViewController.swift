//
//  HomeViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 30/10/23.
//

import UIKit
import Charts

class GraphViewController: ReusableHorizontalScrollView {
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var movementView: UIView!
    @IBOutlet weak var movementNameLabel: UILabel!
    @IBOutlet weak var movementAmountLabel: UILabel!
    @IBOutlet weak var movementDatePicker: UIDatePicker!
    @IBOutlet weak var movementTagScrollView: UIScrollView!
    
    var barChart = BarChartView()
    var filteredMovements: [Movement] = []
    var entries: [BarChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setUpView()
    }
    
    //MARK: View setting
    private func setUpView() {
        setupInitialData()
        setupBarChart()
        updateGraphView()
    }
    
    private func setupInitialData() {
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        barChart.delegate = self
        movementView.isHidden = true
        barChart.setScaleEnabled(true)
        barChart.extraBottomOffset = 10.0
    }

     func updateGraphView() {
        entries = generateChartDataEntries()

        guard entries.count >= 2 else {
            graphView.isHidden = true
            UsefulFunctions.showAlert(title: "Warning", message: "There aren't enough movements to display, add more", viewController: self)
            return
        }
        movementView.isHidden = true
        graphView.isHidden = false
        
        let data = createBarChartData(with: entries)
        configureXAxis()
        configureYAxis()
        configureLegend()
        updateChartWithData(data)
    }

     func updateChartWithData(_ data: BarChartData) {
        barChart.data = data
        barChart.notifyDataSetChanged()
    }

    // MARK: - Actions

    @IBAction func seeMovementsFromYesterday(_ sender: Any) {
        movementView.isHidden = true
        filterMovements(from: Date(), byAdding: .hour, value: -24)
    }

    @IBAction func seeMovementsFromLastWeek(_ sender: Any) {
        movementView.isHidden = true
        filterMovements(from: Date(), byAdding: .day, value: -7)
    }

    @IBAction func seeMovementsFromLastMonth(_ sender: Any) {
        movementView.isHidden = true
        filterMovements(from: Date(), byAdding: .month, value: -1)
    }

    @IBAction func seeMovementsFromLastYear(_ sender: Any) {
        movementView.isHidden = true
        filterMovements(from: Date(), byAdding: .year, value: -1)
    }

    @IBAction func seeAllMovements(_ sender: Any) {
        movementView.isHidden = true
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        updateGraphView()
    }

    private func filterMovements(from currentDate: Date, byAdding component: Calendar.Component, value: Int) {
        guard let filteredDate = Calendar.current.date(byAdding: component, value: value, to: currentDate) else { return }
        filteredMovements = UserManager.shared.getCurrentUser()?.movements.filter { movement in
            return movement.properties.date ?? Date() > filteredDate && movement.properties.date ?? Date() <= currentDate
        } ?? []
        updateGraphView()
    }

     

    // MARK: - Helper Methods

    func gradientColors(values: [Double]) -> [UIColor] {
        return values.map { value in
            let normalizedValue = (value - values.min()!) / (values.max()! - values.min()!)
            return UIColor(
                red: 1.0 - CGFloat(normalizedValue),
                green: CGFloat(normalizedValue),
                blue: 0.0,
                alpha: 1.0
            )
        }
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let barEntry = entry as? BarChartDataEntry {
            let index = Int(barEntry.x)
            setupMovementView(index: index)
        }
    }

    func setupMovementView(index: Int) {
        movementView.isHidden = false
        movementNameLabel.text = filteredMovements[index].properties.name
        if let amount = filteredMovements[index].properties.amount, let currency = UserManager.shared.getCurrentUser()?.properties.currency {
            movementAmountLabel.text = "\(String(describing: amount)) \(currency)"
        }
        movementDatePicker.isEnabled = false
        movementDatePicker.date = filteredMovements[index].properties.date ?? Date()
        removeButtonsFromScrollView(movementTagScrollView)
        createHorizontalScrollViewWithButtons(tags: filteredMovements[index].tags, scrollView: movementTagScrollView)
    }
}
