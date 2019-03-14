//
//  EventStatsGraphViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/4/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import UIKit
import Charts
import Crashlytics

class EventStatsGraphViewController: UIViewController {
    var barChart: BarChartView!
    
    var eventRanking: EventRanking?
    private var statsToGraph = [Statistic<ScoutedTeam>]()
    private var scoutedTeams: [ScoutedTeam]?
    let backgroundQueue = DispatchQueue(label: "EventStatsGraphingCalculation", qos: .userInitiated, target: nil)
    //Stashed stats is a dict with key of stat id and value of another dict of team key for key and stat value for value
    var stashedStats = [String:[String:StatValue]]() {
        didSet {
            //Must create multiple BarChartDataSets for grouped bar charts
            var barChartDataSets = [BarChartDataSet]()
            for (statIndex, stat) in statsToGraph.enumerated() {
                //Create a BarChartDataSet which takes in BarChartDataEntries
                var barChartDataEntries = [BarChartDataEntry]()
                for (index,team) in (self.eventRanking?.rankedTeams ?? []).enumerated() {
                    let value = stashedStats[stat.id]?[team?.teamKey ?? ""] ?? .NoValue
                    //Create a BarChartDataEntry
                    var statDouble: Double
                    var isNoValue: Bool = false
                    switch value {
                    case .Double(let val):
                        statDouble = val
                    case .Integer(let val):
                        statDouble = Double(val)
                    case .Percent(let val):
                        //TODO: Add in formatting for percents
                        statDouble = val
                    case .Bool(let val):
                        //TODO: Format for bools
                        statDouble = Double(val.hashValue)
                    case .String:
                        //TODO: Show warning for graphing strings
                        statDouble = 0
                        isNoValue = true
                    case .Error:
                        statDouble = 0
                        isNoValue = true
                    case .NoValue:
                        statDouble = 0
                        isNoValue = true
                    }
                    let entry = FASTBarChartDataEntry(x: Double(index), y: statDouble)
                    entry.isNoValue = isNoValue
                    barChartDataEntries.append(entry)
                }
                
                let dataSet = BarChartDataSet(values: barChartDataEntries, label: stat.name)
                dataSet.colors = [self.barColors[statIndex % self.barColors.count]]
                dataSet.valueFormatter = self
                barChartDataSets.append(dataSet)
            }
            
            let barChartData = BarChartData(dataSets: barChartDataSets)
            
            DispatchQueue.main.async {
                self.barWidth = (1 - self.groupSpace - (Double(barChartDataSets.count) * self.barSpace)) / Double(barChartDataSets.count) //So that the group space always equals 1
                barChartData.barWidth = self.barWidth
                self.groupWidth = barChartData.groupWidth(groupSpace: self.groupSpace, barSpace: self.barSpace) //Should be one
                
                barChartData.groupBars(fromX: -0.5, groupSpace: self.groupSpace, barSpace: self.barSpace)
                
                //Check the y min and if it's not below 0 than scale the y axis down
                var hasDataBelowZero = false
                for set in barChartDataSets {
                    if set.yMin < 0 {hasDataBelowZero = true}
                }
                
                if !hasDataBelowZero {
                    self.barChart.leftAxis.axisMinimum = 0
                } else {
                    self.barChart.leftAxis.resetCustomAxisMin()
                }
                
//                self.barChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.7, easingOption: .easeInOutQuart)
                
                self.barChart.data = barChartData
            }
        }
    }
    
//    let startSpace = 0.8
    let groupSpace = 0.12
    let barSpace = 0.02
//    let barWidth = 0.7
    var barWidth = 0.0
    
    var groupWidth: Double = 0
    
    var barColors = ChartColorTemplates.joyful()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barColors += ChartColorTemplates.colorful()

        // Do any additional setup after loading the view.
        barChart = BarChartView()
        view.addSubview(barChart)
        
        barChart.delegate = self
        
        barChart.doubleTapToZoomEnabled = false
        
        barChart.highlighter = nil
        
        barChart.xAxis.valueFormatter = self
        barChart.xAxis.labelPosition = .bottom
//        barChart.xAxis.centerAxisLabelsEnabled = true
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.setLabelCount(25, force: false)
//        barChart.xAxis.labelRotationAngle = -90
        barChart.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        barChart.xAxis.axisMinimum = -0.5
        barChart.xAxis.granularity = 1
        
        barChart.rightAxis.enabled = false
        barChart.leftAxis.gridLineDashLengths = [4]
        barChart.leftAxis.zeroLineWidth = 10
        barChart.leftAxis.drawAxisLineEnabled = false
        
        barChart.noDataText = "Select Stats to Graph"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func setUp(forEventKey eventKey: String) {
        //TODO: - Add a loading indicator and wait until both queries are completed before allowing access
        //Get the team ranking
        Globals.appDelegate.appSyncClient?.fetch(query: GetEventRankingQuery(key: eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "GetEventRanking-StatsGraph", result: result, error: error) {
                self?.eventRanking = result?.data?.getEventRanking?.fragments.eventRanking
            }
        })
        
        //Get the scouted teams
        Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-StatsGraph", result: result, error: error) {
                self?.scoutedTeams = result?.data?.listScoutedTeams?.map {$0!.fragments.scoutedTeam} ?? []
            } else {
            }
        })
    }
    
    override func viewWillLayoutSubviews() {
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
        barChart.chartDescription?.position = CGPoint(x: barChart.frame.width - 20, y: barChart.frame.height - 15)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectStatsPressed(_ sender: UIBarButtonItem) {
        //Show select stats vc
        let selectStatsVC = storyboard!.instantiateViewController(withIdentifier: "selectStatsVC") as! SelectStatsTableViewController
        let navController = UINavigationController(rootViewController: selectStatsVC)
        
        selectStatsVC.delegate = self
        
        navController.modalPresentationStyle = .popover
        
        navController.popoverPresentationController?.barButtonItem = sender
        navController.preferredContentSize = CGSize(width: 300, height: 650)
        
        present(navController, animated: true, completion: nil)
    }
    
    func loadGraph() {
        //TODO: - Make the loading async
        
        backgroundQueue.async {
            for (_, stat) in self.statsToGraph.enumerated() {
                
                for (_, rankedTeam) in (self.eventRanking?.rankedTeams ?? []).enumerated() {
                    //Get the scouted team
                    //Calculate it
                    if let scoutedTeam = self.scoutedTeams?.first(where: {$0.teamKey == rankedTeam?.teamKey}) {
                        stat.calculate(forObject: scoutedTeam) { (v) in
                            if let _ = self.stashedStats[stat.id] {
                                self.stashedStats[stat.id]![scoutedTeam.teamKey] = v
                            } else {
                                self.stashedStats[stat.id] = [scoutedTeam.teamKey:v]
                            }
                        }
                    } else {
                        if let _ = self.stashedStats[stat.id] {
                            self.stashedStats[stat.id]![rankedTeam?.teamKey ?? ""] = .NoValue
                        } else {
                            self.stashedStats[stat.id] = [rankedTeam?.teamKey ?? "":.NoValue]
                        }
                    }
                }
                
            }
        }
        
        if let key = eventRanking?.eventKey {
            barChart.chartDescription?.text = "Event \(key)"
        } else {
            barChart.chartDescription?.text = "No Event"
        }
        
        Globals.recordAnalyticsEvent(eventType: "opened_event_stats_graph", attributes: ["stats":statsToGraph.map({$0.name}).description], metrics: ["num_of_stats_graphed":Double(statsToGraph.count)])
    }
}

extension EventStatsGraphViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        //X-axis
        let groupNumber: Double
        groupNumber = value
        
        //Check it is a whole number
        if groupNumber - Double(Int(groupNumber)) == 0 {
            //It is whole number
            if (eventRanking?.rankedTeams?.count ?? 0 > Int(groupNumber)) {
                let teamKey = eventRanking?.rankedTeams?[Int(groupNumber)]?.teamKey
                return "\(teamKey?.trimmingCharacters(in: CharacterSet.letters) ?? "?")"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
}

class FASTBarChartDataEntry: BarChartDataEntry {
    var isNoValue = false
}

extension EventStatsGraphViewController: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let entry = entry as? FASTBarChartDataEntry {
            if entry.isNoValue {
                return "NA"
            } else {
                return value.description(roundedAt: 2)
            }
        } else {
            return value.description(roundedAt: 2)
        }
    }
}

extension EventStatsGraphViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}

extension EventStatsGraphViewController: SelectStatsDelegate {
    func currentlySelectedStats() -> [ScoutedTeamStat] {
        return statsToGraph
    }
    
    func selectStatsTableViewController(_ vc: SelectStatsTableViewController, didSelectStats selectedStats: [ScoutedTeamStat]) {
        self.statsToGraph = selectedStats
        loadGraph()
    }
}
