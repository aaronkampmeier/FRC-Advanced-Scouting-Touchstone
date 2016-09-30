//
//  MatchOverviewViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 4/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewViewController: UIViewController, UITableViewDataSource {
	@IBOutlet weak var matchOverviewTable: UITableView!
	
	var dataSource: TeamListSegmentsDataSource? {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(MatchOverviewViewController.reload), name: "TeamSelectedChanged" as NSNotification.Name, object: nil)
		}
	}
	var matchTimeMarkers: [[TeamDataManager.TimeMarkerEvent]] = Array<Array<TeamDataManager.TimeMarkerEvent>>()
	var matchPerformances: [TeamMatchPerformance] = [] {
		didSet {
			matchTimeMarkers.removeAll()
			for performance in matchPerformances {
				matchTimeMarkers.append(dataManager.timeOverview(forMatchPerformance: performance))
			}
		}
	}
	
	let dataManager = TeamDataManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		matchOverviewTable.dataSource = self
		
		reload()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func reload() {
		matchPerformances = (dataSource?.currentMatchPerformances() ?? []).sorted() {
			return $0.0.match!.matchNumber!.doubleValue < $0.1.match!.matchNumber!.doubleValue
		}
		
		if let table = matchOverviewTable {
			table.reloadData()
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let matchPerformance = matchPerformances[section]
		let match = matchPerformance.match!
		return "Match \(match.matchNumber!)"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchTimeMarkers[section].count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return matchTimeMarkers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		let timeMarkers = matchTimeMarkers[(indexPath as NSIndexPath).section]
		cell.textLabel?.text = "\(round(timeMarkers[(indexPath as NSIndexPath).row].time*100)/100) sec"
		cell.detailTextLabel?.text = timeMarkers[(indexPath as NSIndexPath).row].type.description
		return cell
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
