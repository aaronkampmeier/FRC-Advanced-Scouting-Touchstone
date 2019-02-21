//
//  CubeChartViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Charts

class StatChartViewController: UIViewController {
    var barChart: BarChartView!
    
    private var statistic: ScoutedTeamStat?
    private var scoutedTeam: ScoutedTeam?
    private var isPercent = false {
        didSet {
            if isPercent {
                barChart.leftAxis.axisMaximum = 1.1
            } else {
                barChart.leftAxis.resetCustomAxisMax()
            }
        }
    }
    
    var valueEntries = [BarChartDataEntry]() //The y-axis values
    var entries: [(matchNumber: Int, value: StatValue)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChart = BarChartView()
        self.view.addSubview(barChart)

        // Do any additional setup after loading the view.
        barChart.xAxis.valueFormatter = self
        barChart.delegate = self
        
        //Set up chart axis
        barChart.rightAxis.enabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelPosition = .bottom
        barChart.leftAxis.gridLineDashLengths = [4]
        barChart.leftAxis.axisMinimum = 0
        barChart.leftAxis.valueFormatter = self
        barChart.leftAxis.drawAxisLineEnabled = false
        
        barChart.legend.enabled = false
        barChart.doubleTapToZoomEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.highlighter = nil
        
        barChart.animate(yAxisDuration: 1, easingOption: .easeInOutQuart)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            barChart.frame.origin.x = view.safeAreaInsets.left
            barChart.frame.origin.y = view.safeAreaInsets.top
            barChart.frame.size.width = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
            barChart.frame.size.height = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 5
        } else {
            barChart.frame.origin.x = view.frame.origin.x
            barChart.frame.origin.y = view.frame.origin.y
            barChart.frame.size.width = view.bounds.width
            barChart.frame.size.height = view.bounds.height - 5
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        ///Load Data
//        valueEntries.removeAll()
//        matches.removeAll()
//
//        var index = 0
//        for matchPerformance in teamMatchPerformances {
//            var statValues = [Double]()
//            var isNoValue = false
//            for stat in stats {
//                switch matchPerformance.statValue(forStat: stat) {
//                case .Double(let val):
//                    statValues.append(val)
//                case .Percent(let val):
//                    statValues.append(val)
//                    isPercent = true
//                case .Integer(let val):
//                    statValues.append(Double(val))
//                case .NoValue:
//                    isNoValue = true
//                default:
//                    //Should not be here
//                    break
//                }
//            }
//
//            //If the match is not scouted, don't show it in the graph
//            if matchPerformance.scouted?.hasBeenScouted ?? false && !isNoValue {
//                //We have stat values put them in a stacked bar chart data entry
//                valueEntries.append(BarChartDataEntry(x: Double(index), y: statValues.first!))
//                matches.append(matchPerformance.match!)
//                index += 1
//            }
//        }
//
//        //Now we have all the BarChartDataEntries, create the data set
//        let chartDataSet = BarChartDataSet(values: valueEntries, label: "")
//        chartDataSet.colors = [UIColor(red: 0.16, green: 0.50, blue: 0.73, alpha: 1)]
////        chartDataSet.colors = ChartColorTemplates.vordiplom()
//        chartDataSet.valueFormatter = self
//        let chartData = BarChartData(dataSets: [chartDataSet])
//
//        barChart.data = chartData
//
//        //Set titles
//        //TODO: - Set the description
////        barChart.chartDescription?.text = "No Data"
////        if let teamMatchPerformance = teamMatchPerformances.first {
////            if let team = teamMatchPerformance.teamEventPerformance?.team {
////                if let event = teamMatchPerformance.match?.event {
////                    if valueEntries.count > 0 {
////                        barChart.chartDescription?.text = "Team \(team.teamNumber), Event \(event.key)"
////                    }
////                }
////            }
////        }
//        self.navigationItem.title = statistic?.name
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp(forStatistic stat: ScoutedTeamStat, andScoutedTeam scoutedTeam: ScoutedTeam) {
        self.statistic = stat
        self.scoutedTeam = scoutedTeam
        
        statistic?.compositePoints(forObject: scoutedTeam) {[weak self] entries in
            self?.entries = entries
            //Create all of the BarChartDataEntry objects
            for entry in entries {
                let value: Double
                switch entry.value {
                case .Double(let val):
                    value = val
                case .Integer(let val):
                    value = Double(val)
                case .Percent(let val):
                    value = val
                    self?.isPercent = true
                default:
                    assertionFailure()
                    return
                }
                self?.valueEntries.append(BarChartDataEntry(x: Double(entry.matchNumber), y: value))
            }
            
            //Now we have all the BarChartDataEntries, create the data set
            let chartDataSet = BarChartDataSet(values: self?.valueEntries, label: "")
            chartDataSet.colors = [UIColor(red: 0.16, green: 0.50, blue: 0.73, alpha: 1)]
            //        chartDataSet.colors = ChartColorTemplates.vordiplom()
            chartDataSet.valueFormatter = self
            let chartData = BarChartData(dataSets: [chartDataSet])
            
            self?.barChart.data = chartData
            
            self?.barChart.chartDescription?.text = "\(scoutedTeam.teamKey) in \(scoutedTeam.eventKey)"
            self?.navigationItem.title = self?.statistic?.name
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StatChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if let axis = axis {
            switch axis {
            case barChart.xAxis:
                //Convert from the x-axis double position to the name of the match
//                let match = matches[Int(value)]
//                return "Match \(match.matchNumber)"
                
                return "Match \(value)"
            case barChart.leftAxis:
                if isPercent {
                    return "\(value * 100)%"
                } else {
                    break
                }
            default:
                break
            }
        }
        
        return value.description
    }
}

extension StatChartViewController: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if isPercent {
            return "\((value * 100).description(roundedAt: 1))%"
        } else {
            return value.description
        }
    }
}

extension StatChartViewController: ChartViewDelegate {
    
}
