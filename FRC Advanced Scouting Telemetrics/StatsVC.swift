//
//  StatsVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class StatsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var statsTable: UITableView!
	
	var teamListController: TeamListController?
    let dataManager = TeamDataManager()
	
	var matchPerformances: [TeamMatchPerformance]? {
		get {
			return teamListController?.teamRegionalPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance]
		}
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		teamListController = (parentViewController as! TeamListController)
		
		statsTable.dataSource = self
		statsTable.delegate = self
		statsTable.allowsSelection = false
		
		NSNotificationCenter.defaultCenter().addObserverForName("Different Team Selected", object: nil, queue: nil) {
			_ in self.statsTable.reloadData()
		}
    }
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if matchPerformances != nil {
			return matchPerformances!.count+1
		} else {
			return 0
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Overall"
		default:
			return "Match \(matchPerformances![section-1].match!.matchNumber!)"
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
		
		var overallSection: Bool = false
		var includedMatchPerformances: [TeamMatchPerformance]
		if indexPath.section == 0 {
			overallSection = true
			includedMatchPerformances = matchPerformances!
		} else {
			includedMatchPerformances = [matchPerformances![indexPath.section-1]]
		}
		
		switch indexPath.row {
		case 0:
			let totalShots = includedMatchPerformances.reduce(0) {
				return $0 + ($1.offenseShots?.count)!
			}
			cell.textLabel?.text = "Total Shots"
			cell.detailTextLabel?.text = "\(totalShots)"
		case 1:
			let totalShots: Int = includedMatchPerformances.reduce(0) {currentCount,performance in
				let madeShots = ((performance.offenseShots?.allObjects as! [Shot]).filter() {($0.blocked?.boolValue)!}).count
				return currentCount + madeShots
			}
			cell.textLabel?.text = "Made Shots"
			cell.detailTextLabel?.text = "\(totalShots)"
			break
		case 2:
			cell.textLabel?.text = "Defense Cross Times"
			
		default:
			break
		}
		return cell
	}
}

struct Statistics {
	let statistics: [String:(TeamMatchPerformance) -> Double] = [
		"Total Shots": {
			matchPerformance in
			let numOfShots = matchPerformance.offenseShots?.count
			return Double(numOfShots!)
		}, "Defense Cross Time": {
			matchPerformance in
			return 0
		}
	]
}