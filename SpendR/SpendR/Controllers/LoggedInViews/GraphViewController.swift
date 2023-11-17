import UIKit
import Charts

class GraphViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var graphView: UIView!

    var barChart = BarChartView()

    override func viewDidLoad() {
        super.viewDidLoad()

        barChart.delegate = self
        barChart.setScaleEnabled(true) // Permitir hacer zoom en el gráfico
        barChart.extraBottomOffset = 10.0 // Agregar espacio entre el eje X y la leyenda
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        barChart.frame = CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height)
        graphView.addSubview(barChart)

        guard let movements = UserManager.shared.getCurrentUser()?.movements else {
            return
        }

        var entries = [BarChartDataEntry]()

        for (index, movement) in movements.enumerated() {
            var yValue = movement.properties.amount ?? 0.0

            // Si el movimiento es un gasto, convertir el valor a negativo
            if let isIncome = movement.properties.isIncome, !isIncome {
                yValue = -yValue
            }

            // Utilizar la fecha como valor en el eje x
            if let date = movement.properties.date {
                entries.append(BarChartDataEntry(x: Double(index), y: yValue))
            }
        }

        // Ordenar las entradas por fecha ascendente
        entries.sort { $0.x < $1.x }

        let set = BarChartDataSet(entries: entries, label: "Amount")
        set.colors = gradientColors(numColors: 5) // Utilizar 5 colores degradados de rojo a verde
        set.valueTextColor = .label

        let data = BarChartData(dataSet: set)

        // Configurar el formato de las fechas en el eje x
        let xAxis = barChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: entries.map { String($0.x) }) // Mostrar índices en lugar de fechas
        xAxis.labelPosition = .bottom // Posicionar las etiquetas en la parte inferior
        xAxis.drawLabelsEnabled = true

        // Configurar el eje Y
        let leftAxis = barChart.leftAxis
        leftAxis.labelPosition = .outsideChart // Posicionar las etiquetas a la izquierda
        leftAxis.drawLabelsEnabled = true

        // Configurar la leyenda
        let legend = barChart.legend
        legend.textColor = .label
        legend.form = .square
        legend.formSize = 12.0
        legend.formToTextSpace = 5.0
        legend.horizontalAlignment = .left

        barChart.data = data
    }

    // Función para generar colores degradados de rojo a verde
    func gradientColors(numColors: Int) -> [UIColor] {
        var colors = [UIColor]()

        for i in 0..<numColors {
            let ratio = CGFloat(i) / CGFloat(numColors - 1)
            let color = UIColor(
                red: 1.0 - ratio,
                green: ratio,
                blue: 0.0,
                alpha: 1.0
            )
            colors.append(color)
        }

        return colors
    }

    // Método del delegado para manejar la selección de barras
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let barEntry = entry as? BarChartDataEntry {
            let index = Int(barEntry.x)
            print("Selected bar at index: \(index)")
        }
    }
}
