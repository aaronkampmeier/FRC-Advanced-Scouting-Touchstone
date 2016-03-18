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
			_ in self.statsTable.reloadData()
		}
		
		//Set the inset
		statsTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		statsTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
    }
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let performances = matchPerformances {
			//Set up all the stat contexts
			statContexts.removeAll()
			statContexts.append(StatContext(context: performances))
			
			for performance in performances {
				statContexts.append(StatContext(context: [performance]))
			}
			
			return statContexts.count
		} else {
			if let cache = currentTeamCache {
				statContexts.removeAll()
				statContexts.append((cache.statContextCache?.statContext)!)
				
				return 1
			} else {
				return 0
			}
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (statContexts.first?.statCalculations.count)!
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
		
		cell.textLabel?.text = statContexts[indexPath.section].statCalculations[indexPath.row].stringName
		cell.detailTextLabel?.text = "\(statContexts[indexPath.section].statCalculations[indexPath.row].value)"
		
		return cell
	}
}