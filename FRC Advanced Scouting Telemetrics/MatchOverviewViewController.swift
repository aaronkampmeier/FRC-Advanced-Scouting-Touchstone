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
	
	var teamListController: TeamListController!
	var matchTimeMarkers: [[TeamDataManager.TimeMarkerEvent]] = Array<Array<TeamDataManager.TimeMarkerEvent>>()
	var matchPerformances: [TeamMatchPerformance] = [] {
		didSet {
			matchTimeMarkers.removeAll()
			for performance in matchPerformances {
				matchTimeMarkers.append(dataManager.timeOverview(forMatchPerformance: performance))
			}
			matchOverviewTable.reloadData()
		}
	}
	
	let dataManager = TeamDataManager()
	
	enum MatchPerformance {
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamListController = parentViewController as! TeamListController
		
		
		matchOverviewTable.dataSource = self
		matchOverviewTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		matchOverviewTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		matchPerformances = (teamListController.teamRegionalPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance] ?? []).sort() {
			return $0.0.match!.matchNumber!.doubleValue < $0.1.match!.matchNumber!.doubleValue
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let matchPerformance = matchPerformances[section]
		let match = matchPerformance.match!
		return "Match \(match.matchNumber!)"
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchTimeMarkers[section].count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return matchTimeMarkers.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
		let timeMarkers = matchTimeMarkers[indexPath.section]
		cell.textLabel?.text = "\(round(timeMarkers[indexPath.row].time*100)/100) sec"
		cell.detailTextLabel?.text = timeMarkers[indexPath.row].type.description
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
