//
//  ViewController.swift
//  Chart
//
//  Created by 한우람 on 2021/07/07.
//

import UIKit
import Charts

class ViewController: UIViewController {

    @IBOutlet var barChart: BarChartView!

    @IBOutlet var graphBar: [BarGraph]!
    @IBOutlet var txtAmt: [UILabel]!
    
    var numEntry = 5
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onRefresh()
    }
    
    func onRefresh() {
        DispatchQueue.main.async {
            self.initBarChart()
            self.initGraph(menu1: 40, menu2: 60, menu3: 25, menu4: 45, menu5: 30)
        }
    }
    
    func initBarChart() {
        barChart.delegate = self
        barChart.maxVisibleCount = 0
        barChart.chartDescription?.enabled = false
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = true
        barChart.clipValuesToContentEnabled = true
        barChart.highlightFullBarEnabled = true
        barChart.highlightPerTapEnabled = true//barChart.highlighter = nil
        barChart.dragEnabled = false
        barChart.scaleYEnabled = false
        barChart.scaleXEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.doubleTapToZoomEnabled = false
        
        // 좌측 축 설정
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 100.0
//        barChart.leftAxis.spaceTop = 0.1
//        barChart.leftAxis.labelCount = 5
//        barChart.leftAxis.labelPosition = .outsideChart
//        barChart.leftAxis.labelFont = .systemFont(ofSize: 12)
//        barChart.leftAxis.labelTextColor = UIColor.blue
//        barChart.leftAxis.axisLineColor = UIColor.lightGray
//        barChart.leftAxis.axisLineWidth = 1
//        barChart.leftAxis.drawGridLinesEnabled = true
        barChart.leftAxis.enabled = false
//        barChart.leftAxis.valueFormatter = RightAxisValueFormatter().axisFormatter()
        
        // 하단 축 설정
        barChart.xAxis.setLabelCount(numEntry, force: false)
        barChart.xAxis.labelCount = numEntry
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.labelFont = .systemFont(ofSize: 12)
        barChart.xAxis.labelTextColor = UIColor.black
        barChart.xAxis.centerAxisLabelsEnabled = false
        barChart.xAxis.granularity = 1.0
        barChart.xAxis.granularityEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawLabelsEnabled = true
        barChart.xAxis.valueFormatter = BottomAxisValueFormatter()
        
        // 우측 축 설정
        barChart.rightAxis.axisMinimum = 0.0
        barChart.rightAxis.axisMaximum = 100.0
        barChart.rightAxis.spaceTop = 0.1
        barChart.rightAxis.labelCount = 5
        barChart.rightAxis.labelPosition = .outsideChart
        barChart.rightAxis.labelFont = .systemFont(ofSize: 12)
        barChart.rightAxis.labelTextColor = UIColor.gray
        barChart.rightAxis.axisLineColor = UIColor.lightGray
        barChart.rightAxis.axisLineWidth = 0
        barChart.rightAxis.drawGridLinesEnabled = true
        barChart.rightAxis.enabled = true
        barChart.rightAxis.valueFormatter = RightAxisValueFormatter().axisFormatter()

        // 범례 설정
        barChart.legend.horizontalAlignment = .center
        barChart.legend.verticalAlignment = .bottom
        barChart.legend.orientation = .horizontal
        barChart.legend.form = .square
        barChart.legend.formSize = 8.0
        barChart.legend.formToTextSpace = 5.0
        barChart.legend.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        barChart.legend.textColor = UIColor.black
        barChart.legend.yOffset = 5.0
        barChart.legend.xOffset = 5.0
        barChart.legend.xEntrySpace = 50
        barChart.legend.drawInside = false
        barChart.legend.enabled = false
        
        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: barChart.xAxis.valueFormatter!)
        marker.chartView = barChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        barChart.marker = marker
        barChart.drawMarkers = true
        
        let entries = self.generateEmptyBarChartDataEntries()
        dataSet(entries: entries)

        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {[unowned self] (timer) in
            
            // 바 그래프 강제 선택
            //let highlight = Highlight(x: Double(i), y: 0, dataSetIndex: 0)
            //barChart.highlightValue(highlight)
            
            let entries = self.generateRandomBarChartDataEntries()
            self.dataSet(entries: entries)
            self.barChart.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        }
        timer.fire()
    }

    /**
     * 그래프 그리기
     */
    func initGraph(menu1: Int, menu2: Int, menu3: Int, menu4: Int, menu5: Int, animated: Bool = true) {
        graphBar = graphBar.sorted(by: {$0.tag < $1.tag})
        let totalHeight = graphBar[0].superview?.bounds.height ?? 0
        for graphBar in graphBar {
            graphBar.frame.origin.y = totalHeight
            graphBar.frame.size.height = 0
            graphBar.heightConstraint.constant = 0
        }
        let maxHeight = totalHeight * 1.0
        let minHeight = totalHeight * 0.0
        let values = [menu1, menu2, menu3, (menu4 + menu5)]
        var maxValue = (values.max() ?? 1)
        if maxValue == 0 {
            maxValue = 1
        }
        let units = self.calculate(maxValue: maxValue, default: maxValue == 1 ? 100000 : 1 )
        maxValue = units.last?.toInt() ?? 0
        if maxValue == 0 {
            maxValue = 1
        }
        txtAmt = txtAmt.sorted(by: {$0.tag < $1.tag})
        for i in 0..<txtAmt.count {
            let lblUnit = txtAmt[i]
            lblUnit.text = self.withCommas(units[i], "")
        }
        
        UIView.animate(withDuration: animated ? 0.5 : 0) {
            for i in 0..<self.graphBar.count {
                let view = self.graphBar[i]
                var height = maxHeight * (CGFloat(values[i]) / CGFloat(maxValue))
                height = max(height, minHeight)
                view.frame.origin.y = totalHeight - height
                view.frame.size.height = height
                if i == 3 {
                    view.heightConstraint.constant = CGFloat(menu5)
                } else {
                    view.heightConstraint.constant = 0
                }
            }
        }
    }
    
    /**
     * 그래프 최대값 처리 로직
     */
    @discardableResult
    func calculate(maxValue: Int, count: Int = 5, default: Int = 50000, ratio: CGFloat = 0.5) -> [String] {
        var maxValue = maxValue
        let digit = String(format: "%d", UInt32(maxValue)).count
        let point1 = CGFloat(maxValue) / pow(CGFloat(10), CGFloat(digit))
        let point2 = CGFloat(maxValue) / pow(CGFloat(10), CGFloat(digit)) + 0.05
        var maximum = 0
        if point1 > 0.5 {
            maximum = Int(1.0 * pow(CGFloat(10), CGFloat(digit + 1)))
        } else {
            maximum = Int(CGFloat(Int(point2 * 10)) * pow(CGFloat(10), CGFloat(digit)))
            let unit = Int(ratio * pow(CGFloat(10), CGFloat(digit)))
            let maxUnit = maximum - unit
            maxValue = maxValue * 10
            if maxUnit == maxValue {
                maximum -= unit
            } else if maximum < maxValue {
                maximum += unit
            } else if maxUnit < maxValue {
            } else {
                maximum += unit
            }
        }
        maximum = Int(CGFloat(maximum) / CGFloat(10))
        if maximum < `default` {
            maximum = `default`
        }
        var values = [String]()
        for i in 1 ..< count + 1 {
            let value = String(format: "%d", Int(CGFloat(i) * CGFloat(maximum) / CGFloat(count)))
            values.append(value)
        }
        return values
    }
    
    @IBAction func onReload(_ sender: UIButton) {
        onRefresh()
    }
    
    /**
     * 콤마 붙이기
     */
     func withCommas(_ number: String?, _ default: String = "0") -> String {
        return number?.toInt().withCommas() ?? `default`
    }
}

extension ViewController: ChartViewDelegate {
    
    class RightAxisValueFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return "\(Int(value) + 1)"
        }
        
        func axisFormatter() -> IAxisValueFormatter {
            let axisFormatter = NumberFormatter()
            axisFormatter.minimumFractionDigits = 0
            axisFormatter.maximumFractionDigits = 1
            //axisFormatter.negativeSuffix = " $"
            //axisFormatter.positiveSuffix = " $"
            return DefaultAxisValueFormatter(formatter: axisFormatter)
        }
    }
    
    class BottomAxisValueFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return "\(Int(value) + 1)"
        }
    }
    
    class ValueFormatter: NSObject, IValueFormatter {
        public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            let correctValue = Int(value)
            print("correctValue: \(correctValue)")
            return String(correctValue)
        }
    }
    
    func generateEmptyBarChartDataEntries() -> [BarChartDataEntry] {
        var result: [BarChartDataEntry] = []
        for i in 0..<numEntry {
            var stackCount = 1
            if i == 4 {
                stackCount = 2
            }
            var yValues = [Double]()
            for _ in 0..<stackCount {
                yValues.append(0)
            }
            result.append(BarChartDataEntry(x: Double(i), yValues: yValues))
        }
        return result
    }
    
    func generateRandomBarChartDataEntries() -> [BarChartDataEntry] {
        var result: [BarChartDataEntry] = []
        for i in 0..<numEntry {
            var stackCount = 1
            if i == 4 {
                stackCount = 2
            }
            var yValues = [Double]()
            for _ in 0..<stackCount {
                let value = (Int(arc4random()) % Int(90 / stackCount)) + (10 / stackCount)
                let height: Double = Double(value)
                yValues.append(height)
            }
            result.append(BarChartDataEntry(x: Double(i), yValues: yValues, data: "데이터"))
        }
        return result
    }
    
    func dataSet(entries: [BarChartDataEntry]) {
        if let dataSet = self.barChart.data?.dataSets.first as? BarChartDataSet {
            dataSet.replaceEntries(entries)
            self.barChart.data?.notifyDataChanged()
            self.barChart.notifyDataSetChanged()
        } else {
            let dataSet = BarChartDataSet(entries: entries, label: "범례1")
            dataSet.drawIconsEnabled = false
            dataSet.drawValuesEnabled = true
            //dataSet.colors = ChartColorTemplates.material()
            dataSet.colors = [.red, .yellow, .green, .blue, .gray, .cyan]
            dataSet.stackLabels = ["범례1","범례2","범례3"]
            let data = BarChartData(dataSets: [dataSet])
            data.setDrawValues(true)
            data.setValueFont(.systemFont(ofSize: 12))
            data.setValueTextColor(.blue)
            data.setValueFormatter(ValueFormatter())
            data.highlightEnabled = true
            data.barWidth = 0.5
            self.barChart.fitBars = true
            self.barChart.data = data
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected")
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        NSLog("chartScaled")
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        NSLog("chartTranslated")
    }
}


extension String {
    
    var numberValue: NSNumber {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self) ?? 0
    }
    
    func toInt() -> Int {
        return self.numberValue.intValue//Int(self) ?? 0//(self as NSString).integerValue
    }
}

extension Int {
    
    func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
    
    /**
     * 세자리 수마다 콤마 붙이기
     */
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
