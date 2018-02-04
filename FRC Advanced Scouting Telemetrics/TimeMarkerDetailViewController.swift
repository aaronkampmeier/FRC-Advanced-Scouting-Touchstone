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
                case .EndedAutonomous:
                    titleLabel.text = "Ended Autonomous"
                    
                    detailValues = [("Time", timeMarker.time.description(roundedAt: 2))]
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
