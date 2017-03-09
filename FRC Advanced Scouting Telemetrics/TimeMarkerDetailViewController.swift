//
//  TimeMarkerDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/6/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TimeMarkerDetailViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autoLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    
    fileprivate var timeMarker: TimeMarker? {
        didSet {
            detailValues = []
            if let timeMarker = timeMarker {
                switch timeMarker.timeMarkerEventType {
                case .LoadedFuel:
                    titleLabel.text = "Fuel Loading"
                    
                    //Get the associated object
                    let fuelLoadings = timeMarker.localMatchPerformance?.fuelLoadings(forScoutID: timeMarker.scoutID!)
                    if let associatedFuelLoading = (fuelLoadings?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Location",associatedFuelLoading.location),
                            ("Amount Loaded", ((associatedFuelLoading.associatedFuelIncrease?.doubleValue ?? 0) * (timeMarker.localMatchPerformance?.universal?.eventPerformance?.team.local.tankSize?.doubleValue ?? 0)).description(roundedAt: 2))
                        ]
                        
                        autoLabel.isHidden = !(associatedFuelLoading.isAutonomous?.boolValue ?? false)
                    }
                case .ScoredFuel:
                    titleLabel.text = "Fuel Scoring"
                    
                    let fuelScorings = timeMarker.localMatchPerformance?.fuelScorings(forScoutID: timeMarker.scoutID!)
                    if let fuelScoring = (fuelScorings?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Accuracy", (fuelScoring.accuracy?.doubleValue ?? 0).description(roundedAt: 2)),
                            ("Amount Shot", ((fuelScoring.amountShot?.doubleValue ?? 0) * (timeMarker.localMatchPerformance?.universal?.eventPerformance?.team.local.tankSize?.doubleValue ?? 0)).description(roundedAt: 2)),
                            ("Goal", (fuelScoring.goalType().description))
                        ]
                        
                        autoLabel.isHidden = !(fuelScoring.isAutonomous?.boolValue ?? false)
                    }
                case .LoadedGear:
                    titleLabel.text = "Gear Loading"
                    
                    let gearLoadings = timeMarker.localMatchPerformance?.gearLoadings(forScoutID: timeMarker.scoutID!)
                    if let gearLoading = (gearLoadings?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Location", gearLoading.location)
                        ]
                        
                        autoLabel.isHidden = !(gearLoading.isAutonomous?.boolValue ?? false)
                    }
                case.ScoredGear:
                    titleLabel.text = "Gear Scoring"
                    
                    let gearScorings = timeMarker.localMatchPerformance?.gearMountings(forScoutID: timeMarker.scoutID!)
                    if let gearScoring = (gearScorings?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Peg", gearScoring.pegNumber?.intValue.description)
                        ]
                        
                        autoLabel.isHidden = !(gearScoring.isAutonomous?.boolValue ?? false)
                    }
                case .Defended:
                    titleLabel.text = "Defense/Blocking"
                    
                    let defenses = timeMarker.localMatchPerformance?.defendings(forScoutID: timeMarker.scoutID!)
                    if let defending = (defenses?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Type", defending.type),
                            ("Duration", (defending.duration?.doubleValue ?? 0).description(roundedAt: 2)),
                            ("Was Successful", defending.successful)
                        ]
                        
                        autoLabel.isHidden = true
                    }
                case .EndedAutonomous:
                    titleLabel.text = "Ended Autonomous"
                    
                    detailValues = [("Time", timeMarker.time?.doubleValue.description(roundedAt: 2))]
                    autoLabel.isHidden = true
                default:
                    break
                }
            }
            
            detailTableView.reloadData()
        }
    }
    
    var detailValues = [(String, String?)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timeMarker = timeMarkerToLoad
        
        detailTableView.dataSource = self
    }
    
    fileprivate var timeMarkerToLoad: TimeMarker?
    func load(forTimeMarker timeMarker: TimeMarker) {
        timeMarkerToLoad = timeMarker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell")
        
        let detailValue = detailValues[indexPath.row]
        (cell?.viewWithTag(1) as! UILabel).text = detailValue.0
        (cell?.viewWithTag(2) as! UILabel).text = detailValue.1
        
        return cell!
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
