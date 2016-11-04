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
	
	var dataSource: TeamListSegmentsDataSource? {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(StatsVC.loadStats), name: NSNotification.Name("TeamSelectedChanged"), object: nil)
		}
	}
	
	var statContexts: [StatContext] = [StatContext]()
	
	var matchPerformances: [TeamMatchPerformance]? {
		get {
			let sortedPerformances = (dataSource?.currentMatchPerformances())?.sorted() {let (first,second) = $0; return (first.match?.matchNumber?.intValue)! < (second.match?.matchNumber?.intValue)!}
			return sortedPerformances
		}
	}
	
	var currentTeam: Team? {
		get {
			return dataSource?.currentTeam()
		}
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		statsTable.dataSource = self
		statsTable.delegate = self
		statsTable.allowsSelection = false
		
		loadStats()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func loadStats() {
		statContexts.removeAll()
		if let selectedTeam = currentTeam {
			statContexts.append(StatContext(context: selectedTeam))
			statContexts[0].name = "Team Specific"
			if let performance = dataSource?.currentRegionalPerformance() {
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
		statsTable?.reloadData()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return statContexts.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (statContexts[section].possibleStats.count)
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return statContexts[section].name ?? "Statistics"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		cell.textLabel?.text = statContexts[(indexPath as NSIndexPath).section].possibleStats[(indexPath as NSIndexPath).row].description
		cell.detailTextLabel?.text = "\(statContexts[(indexPath as NSIndexPath).section].possibleStats[(indexPath as NSIndexPath).row].value)"
		
		return cell
	}
}
