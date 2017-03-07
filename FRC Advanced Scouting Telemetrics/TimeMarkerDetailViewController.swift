//
//  TimeMarkerDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/6/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TimeMarkerDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autoLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    
    var timeMarker: TimeMarker? {
        didSet {
            if let timeMarker = timeMarker {
                switch timeMarker.timeMarkerEventType {
                case .LoadedFuel:
                    titleLabel.text = "Fuel Loading"
                    
                    //Get the associated object
                    let fuelLoadings = timeMarker.localMatchPerformance?.fuelLoadings(forScoutID: timeMarker.scoutID!)
                    if let associatedFuelLoading = (fuelLoadings?.first {$0.time?.doubleValue == timeMarker.time?.doubleValue}) {
                        detailValues = [
                            ("Amount Loaded", ((associatedFuelLoading.associatedFuelIncrease?.doubleValue ?? 0) * (timeMarker.localMatchPerformance?.universal?.eventPerformance?.team.local.tankSize?.doubleValue ?? 0)).description)
                        ]
                    }
                default:
                    break
                }
            }
            
            detailTableView.reloadData()
        }
    }
    
    var detailValues = [(String, String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
