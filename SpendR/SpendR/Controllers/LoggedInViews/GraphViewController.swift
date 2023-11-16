import UIKit
import Charts

class GraphViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var graphView: UIView!

    var lineChart = LineChartView()

    override func viewDidLoad() {
        super.viewDidLoad()

        lineChart.delegate = self
        lineChart.setScaleEnabled(true) // Permitir hacer zoom en el gráfico
        lineChart.extraBottomOffset = 10.0 // Agregar espacio entre el eje X y la leyenda
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        lineChart.frame = CGRect(x: 0, y: 0, width: graphView.frame.size.width, height: graphView.frame.size.height)
        graphView.addSubview(lineChart)

        guard let movements = UserManager.shared.getCurrentUser()?.movements else {
            return
        }

        var entries = [ChartDataEntry]()

        for (index, movement) in movements.enumerated() {
            var yValue = movement.properties.amount ?? 0.0

            // Si el movimiento es un gasto, convertir el valor a negativo
            if let isIncome = movement.properties.isIncome, !isIncome {
                yValue = -yValue
            }

            // Utilizar la fecha como valor en el eje x
            if let date = movement.properties.date {
                entries.append(ChartDataEntry(x: date.timeIntervalSince1970, y: yValue))
            }
        }

        // Ordenar las entradas por fecha ascendente
        entries.sort { $0.x < $1.x }

        let set = LineChartDataSet(entries: entries, label: "Amount")
        set.colors = gradientColors(numColors: 5) // Utilizar 5 colores degradados de rojo a verde
        set.valueTextColor = .label

        let data = LineChartData(dataSet: set)

        // Configurar el formato de las fechas en el eje x
        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelPosition = .bottom // Posicionar las etiquetas en la parte inferior
        xAxis.drawLabelsEnabled = true

        // Configurar el eje Y
        let leftAxis = lineChart.leftAxis
        leftAxis.labelPosition = .outsideChart // Posicionar las etiquetas a la izquierda
        leftAxis.drawLabelsEnabled = true

        // Configurar la leyenda
        let legend = lineChart.legend
        legend.textColor = .label
        legend.form = .square
        legend.formSize = 12.0
        legend.formToTextSpace = 5.0
        legend.horizontalAlignment = .left

        lineChart.data = data
    }

    // Clase para formatear las fechas en el eje x
    class DateValueFormatter: NSObject, AxisValueFormatter {
        private let dateFormatter = DateFormatter()

        override init() {
            super.init()
            dateFormatter.dateFormat = "yyyy"
        }

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let date = Date(timeIntervalSince1970: value)
            return dateFormatter.string(from: date)
        }
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
}
