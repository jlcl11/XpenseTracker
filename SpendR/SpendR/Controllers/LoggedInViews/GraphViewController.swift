import UIKit
import Charts

class GraphViewController: ReusableHorizontalScrollView, ChartViewDelegate {
    
    // TODO: Arreglar el scrollview y las fechas de la gráfica
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var notEnoughMovementsLabel: UILabel!
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
        setupInitialData()
        setupBarChart()
        updateGraphView()
    }

    private func setupInitialData() {
        filteredMovements = UserManager.shared.getCurrentUser()?.movements ?? []
        barChart.delegate = self
        barChart.setScaleEnabled(true)
        barChart.extraBottomOffset = 10.0
    }

    private func updateGraphView() {
        entries = generateChartDataEntries()

        guard entries.count >= 2 else {
            graphView.isHidden = true
            notEnoughMovementsLabel.isHidden = false
            return
        }
        movementView.isHidden = true
        graphView.isHidden = false
        notEnoughMovementsLabel.isHidden = true
        
        let data = createBarChartData(with: entries)
        configureXAxis()
        configureYAxis()
        configureLegend()
        updateChartWithData(data)
    }

    private func updateChartWithData(_ data: BarChartData) {
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

    // MARK: - Bar Chart Setup

    private func setupBarChart() {
        layoutBarChart()
    }

    private func layoutBarChart() {
        barChart.frame = CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height)
        graphView.addSubview(barChart)
        entries = generateChartDataEntries()
        let data = createBarChartData(with: entries)
        configureXAxis()
        configureYAxis()
        configureLegend()
        updateChartWithData(data)
    }

    private func generateChartDataEntries() -> [BarChartDataEntry] {
        return filteredMovements.enumerated().map { index, movement in
            let yValue = calculateYValue(for: movement)
            return BarChartDataEntry(x: Double(index), y: yValue)
        }.sorted { $0.x < $1.x }
    }

    private func calculateYValue(for movement: Movement) -> Double {
        var yValue = movement.properties.amount ?? 0.0
        if let isIncome = movement.properties.isIncome, !isIncome {
            yValue = -yValue
        }
        return yValue
    }

    private func createBarChartData(with entries: [BarChartDataEntry]) -> BarChartData {
        let set = BarChartDataSet(entries: entries, label: "Amount")
        set.colors = gradientColors(values: entries.map { $0.y })
        set.valueTextColor = .label
        return BarChartData(dataSet: set)
    }

    private func configureXAxis() {
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawLabelsEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values: getXAxisLabels())
    }

    private func getXAxisLabels() -> [String] {
        var xAxisLabels: [String] = []
        for (index, movement) in filteredMovements.enumerated() {
            guard let movementDate = movement.properties.date else { continue }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            let label = dateFormatter.string(from: movementDate)
            if index % 2 == 0 {
                xAxisLabels.append(label)
            } else {
                xAxisLabels.append("") // Opcional: Puedes usar una cadena vacía para saltar la etiqueta
            }
        }
        return xAxisLabels
    }

    private func configureYAxis() {
        let leftAxis = barChart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.drawLabelsEnabled = true
    }

    private func configureLegend() {
        let legend = barChart.legend
        legend.textColor = .label
        legend.form = .square
        legend.formSize = 12.0
        legend.formToTextSpace = 5.0
        legend.horizontalAlignment = .left
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
