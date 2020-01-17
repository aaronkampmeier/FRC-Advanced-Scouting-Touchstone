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
            if let barChart = barChart {
                if isPercent {
                    barChart.leftAxis.axisMaximum = 1.1
                } else {
                    barChart.leftAxis.resetCustomAxisMax()
                }
            }
        }
    }
    
    var valueEntries = [BarChartDataEntry]() //The y-axis values
    var entries: [(matchNumber: Int, value: StatValue)] = []
    
    private let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)
    
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
        
        if #available(iOS 13.0, *) {
            barChart.xAxis.gridColor = UIColor.systemGray2
            barChart.xAxis.axisLineColor = UIColor.opaqueSeparator
            barChart.xAxis.labelTextColor = UIColor.label
            
            barChart.leftAxis.gridColor = UIColor.systemGray2
            barChart.leftAxis.axisLineColor = UIColor.opaqueSeparator
            barChart.leftAxis.labelTextColor = UIColor.label
            barChart.leftAxis.zeroLineColor = UIColor.systemBlue
            
            barChart.legend.textColor = UIColor.label
            
            barChart.noDataTextColor = UIColor.label
            barChart.borderColor = UIColor.systemGray
            
            barChart.chartDescription?.textColor = UIColor.label
        }
        
        barChart.animate(yAxisDuration: 1, easingOption: .easeInOutQuart)
        
        if isPercent {
            barChart.leftAxis.axisMaximum = 1.1
        } else {
            barChart.leftAxis.resetCustomAxisMax()
        }
        
        viewIsLoadedSemaphore.signal()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let statsLoaderQueue = DispatchQueue(label: "Background stats loader", qos: .userInitiated, target: nil)
    func setUp(forStatistic stat: ScoutedTeamStat, andScoutedTeam scoutedTeam: ScoutedTeam) {
        self.statistic = stat
        self.scoutedTeam = scoutedTeam
        
        statistic?.compositePoints(forObject: scoutedTeam) {[weak self] entries in
            self?.statsLoaderQueue.async {
                self?.viewIsLoadedSemaphore.wait()
                self?.viewIsLoadedSemaphore.signal()
                
                self?.entries = entries
                //Create all of the BarChartDataEntry objects
                var index = 0
                for entry in entries {
                    let value: Double
                    switch entry.value {
                    case .Double(let val):
                        value = val
                    case .Integer(let val):
                        value = Double(val)
                    case .Percent(let val):
                        value = val
                        DispatchQueue.main.async {
                            self?.isPercent = true
                        }
                    case .NoValue:
                        index += 1
                        continue
                    default:
                        assertionFailure()
                        continue
                    }
                    self?.valueEntries.append(BarChartDataEntry(x: Double(index), y: value))
                    index += 1
                }
                
                DispatchQueue.main.async {
                    //Now we have all the BarChartDataEntries, create the data set
                    let chartDataSet = BarChartDataSet(entries: self?.valueEntries, label: "")
                    chartDataSet.colors = [UIColor(red: 0.16, green: 0.50, blue: 0.73, alpha: 1)]
                    //        chartDataSet.colors = ChartColorTemplates.vordiplom()
                    if #available(iOS 13.0, *) {
                        chartDataSet.valueColors = [UIColor.label]
                    }
                    chartDataSet.valueFormatter = self
                    let chartData = BarChartData(dataSets: [chartDataSet])
                    
                    self?.barChart.data = chartData
                    
                    self?.barChart.chartDescription?.text = "\(scoutedTeam.teamKey) in \(scoutedTeam.eventKey)"
                    self?.navigationItem.title = self?.statistic?.name
                }
            }
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
                
                let entry = entries[Int(value)]
                return "Match \(Int(entry.matchNumber))"
            case barChart.leftAxis:
                if isPercent {
                    return "\((value * 100).description(roundedAt: 2))%"
                } else {
                    return value.description(roundedAt: 2)
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
