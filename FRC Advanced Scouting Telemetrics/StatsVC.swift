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
	
	var statContexts: [StatContext] = [StatContext]()
	
	var matchPerformances: [TeamMatchPerformance]? {
		get {
			let sortedPerformances = (teamListController?.teamRegionalPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance])?.sort() {let (first,second) = $0; return first.match?.matchNumber?.integerValue < second.match?.matchNumber?.integerValue}
			return sortedPerformances
		}
	}
	
	var currentTeamCache: TeamListController.TeamCache? {
		get {
			return teamListController?.selectedTeamCache
		}
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		teamListController = (parentViewController as! TeamListController)
		
		statsTable.dataSource = self
		statsTable.delegate = self
		statsTable.allowsSelection = false
		
		NSNotificationCenter.defaultCenter().addObserverForName("Different Team Selected", object: nil, queue: nil) {
			_ in self.loadStats(); self.statsTable.reloadData()
		}
		
		//Set the inset
		statsTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		statsTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		loadStats()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loadStats()
	}
	
	func loadStats() {
		statContexts.removeAll()
		if let selectedTeamCache = teamListController?.selectedTeamCache {
			statContexts.append(StatContext(context: selectedTeamCache.team))
			statContexts[0].name = "Team Specific"
			if let performance = teamListController?.teamRegionalPerformance {
				statContexts.append(StatContext(context: performance))
				statContexts[1].name = "Regional Specific"
				statContexts.append(StatContext(context: performance.matchPerformances!.allObjects as! [TeamMatchPerformance]))
				statContexts[2].name = "Overall Matches"
				for matchPerformance in matchPerformances! {
					var context = StatContext(context: [matchPerformance])
					context.name = "Match \(matchPerformance.match?.matchNumber ?? -1)"
					statContexts.append(context)
				}
			}
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return statContexts.count
		
//		if let performances = matchPerformances {
//			//Set up all the stat contexts
//			statContexts.removeAll()
//			statContexts.append(StatContext(context: performances))
//			
//			for performance in performances {
//				statContexts.append(StatContext(context: [performance]))
//			}
//			
//			return statContexts.count
//		} else {
//			if let cache = currentTeamCache {
//				statContexts.removeAll()
//				statContexts.append((cache.statContextCache.statContext))
//				
//				return 1
//			} else {
//				return 0
//			}
//		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (statContexts[section].possibleStats.count)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return statContexts[section].name ?? "Statistics"
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
		
		cell.textLabel?.text = statContexts[indexPath.section].possibleStats[indexPath.row].description
		cell.detailTextLabel?.text = "\(statContexts[indexPath.section].possibleStats[indexPath.row].value)"
		
		return cell
	}
}