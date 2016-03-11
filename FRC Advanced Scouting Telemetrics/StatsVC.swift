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
			return 0
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
		
//		var overallSection: Bool = false
//		var includedMatchPerformances: [TeamMatchPerformance]
//		if indexPath.section == 0 {
//			overallSection = true
//			includedMatchPerformances = matchPerformances!
//		} else {
//			includedMatchPerformances = [matchPerformances![indexPath.section-1]]
//		}
//		
//		switch indexPath.row {
//		case 0:
//			let totalShots = includedMatchPerformances.reduce(0) {
//				return $0 + ($1.offenseShots?.count)!
//			}
//			cell.textLabel?.text = "Total Shots"
//			cell.detailTextLabel?.text = "\(totalShots)"
//		case 1:
//			let totalShots: Int = includedMatchPerformances.reduce(0) {currentCount,performance in
//				let madeShots = ((performance.offenseShots?.allObjects as! [Shot]).filter() {!($0.blocked?.boolValue)!}).count
//				return currentCount + madeShots
//			}
//			cell.textLabel?.text = "Made Shots"
//			cell.detailTextLabel?.text = "\(totalShots)"
//			break
//		case 2:
//			cell.textLabel?.text = "Defense Cross Times"
//			
//		default:
//			break
//		}
		
		
		return cell
	}
}

struct StatContext {
	let statCalculations: [StatCalculation]
	
	init(context: [TeamMatchPerformance]) {
		statCalculations = [.TotalPoints(context), .TotalShots(context), .TotalMadeShots(context), .TotalScales(context), .RankingPoints(context), .DefensesCrossed(context), .ShotAccuracy(context), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Portcullis), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.ChevalDeFrise), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Moat), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Ramparts), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Drawbridge), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.SallyPort), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.RockWall), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.RoughTerrain),  .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.LowBar), .AverageTimeInZone(context, .DefenseCourtyard), .AverageTimeInZone(context, .OffenseCourtyard), .AverageTimeInZone(context, .Neutral)]
	}
}

enum StatCalculation {
	case TotalShots([TeamMatchPerformance])
	case TotalMadeShots([TeamMatchPerformance])
	case TotalScales([TeamMatchPerformance])
	case RankingPoints([TeamMatchPerformance])
	case DefensesCrossed([TeamMatchPerformance])
	case ShotAccuracy([TeamMatchPerformance])
	case AverageDefenseCrossTime([TeamMatchPerformance], TeamDataManager.DefenseType)
	case AverageTimeInZone([TeamMatchPerformance], GameFieldZone)
	case TotalPoints([TeamMatchPerformance])
	
	//Calculations for all the stat types
	var value: Double {
		switch self {
		case .TotalShots(let context):
			return Double(context.reduce(0) {
				$0 + $1.offenseShots!.count
			})
		case .TotalMadeShots(let context):
			let totalMadeShots = context.reduce(0) {currentCount,performance in
				let madeShots = ((performance.offenseShots?.allObjects as! [Shot]).filter() {!($0.blocked?.boolValue)!}).count
				return currentCount + madeShots
			}
			return Double(totalMadeShots)
		case .TotalScales(let context):
			let total: Int = context.reduce(0) {
				if ($1.didScaleTower?.boolValue) ?? false {
					//They did scale the tower
					return $0 + 1
				} else {
					return $0
				}
			}
			return Double(total)
		case .RankingPoints(let context):
			//FIX THIS
			let total: Int = context.reduce(0) {cumulative,matchPerformance in
				var matchPerformanceTotal = 0
				let allianceColor = TeamDataManager.AllianceColor(rawValue: matchPerformance.allianceColor!.integerValue)!
				
				let redFinalScore = matchPerformance.match?.redFinalScore?.integerValue
				let blueFinalScore = matchPerformance.match?.blueFinalScore?.integerValue
				
				switch allianceColor {
				case .Red:
					//First add points for a capture
					if (matchPerformance.match?.redCapturedTower?.boolValue) ?? false {
						matchPerformanceTotal += 1
					}
					
					//Next get points for a breach
					if matchPerformance.match?.redDefensesBreached?.count >= 4 {
						matchPerformanceTotal += 1
					}
					
					//Fnally, check who won
					if redFinalScore > blueFinalScore {
						matchPerformanceTotal += 2
					} else if redFinalScore == blueFinalScore {
						matchPerformanceTotal += 1
					}
				case .Blue:
					if (matchPerformance.match?.blueCapturedTower?.boolValue) ?? false {
						matchPerformanceTotal += 1
					}
					if matchPerformance.match?.blueDefensesBreached?.count >= 4 {
						matchPerformanceTotal += 1
					}
					//Fnally, check who won
					if redFinalScore < blueFinalScore {
						matchPerformanceTotal += 2
					} else if redFinalScore == blueFinalScore {
						matchPerformanceTotal += 1
					}
				}
				
				return cumulative + matchPerformanceTotal
			}
			
			return Double(total)
		case .DefensesCrossed(let context):
			let total = context.reduce(0) {
				$0 + ($1.defenseCrossTimes?.count)!
			}
			return Double(total)
		case .ShotAccuracy(let context):
			return StatCalculation.TotalMadeShots(context).value / StatCalculation.TotalShots(context).value
		case .AverageDefenseCrossTime(let context, let defense):
			let totalPerformanceAverages: Double = context.reduce(0) {cumulative,matchPerformance in
				//First filter the defenseCrossTimes to only be for the specified defense
				let defenseCrossTimes: [DefenseCrossTime] = (matchPerformance.defenseCrossTimes?.filter() {defenseCrossTime in
					return (defenseCrossTime as! DefenseCrossTime).defense?.defenseName == defense.string
				}) as! [DefenseCrossTime]
				
				let matchPerformanceTotal = defenseCrossTimes.reduce(0) {counter, crossTime in
					return counter + (crossTime.time?.doubleValue)!
				}
				
				let average = matchPerformanceTotal / Double(defenseCrossTimes.count)
				
				return cumulative + average
			}
			
			let averageTime = totalPerformanceAverages / Double(context.count)
			return averageTime
		case .AverageTimeInZone(let context, let zone):
			return -1
		case .TotalPoints(let context):
			let total: Double = context.reduce(0) {cumulative,matchPerformance in
				var performanceTotal = 0.0
				switch TeamDataManager.AllianceColor(rawValue: (matchPerformance.allianceColor?.integerValue)!)! {
				case .Red:
					performanceTotal += (matchPerformance.match?.redFinalScore?.doubleValue) ?? 0
				case .Blue:
					performanceTotal += (matchPerformance.match?.blueFinalScore?.doubleValue) ?? 0
				}
				
				return cumulative + performanceTotal
			}
			
			return Double(total)
		}
	}
	
	var stringName: String {
		switch self {
		case .TotalShots(_):
			return "Total Shots"
		case .TotalMadeShots(_):
			return "Total Made Shots"
		case .TotalScales(_):
			return "Total Scales"
		case .RankingPoints(_):
			return "Ranking Points"
		case .DefensesCrossed(_):
			return "Defenses Crossed"
		case .ShotAccuracy(_):
			return "Shot Accuracy"
		case .AverageDefenseCrossTime(_, let defenseType):
			return "Average \(defenseType.string) Cross Time"
		case .AverageTimeInZone(_, let zone):
			return "Average Time in \(zone.rawValue)"
		case .TotalPoints(_):
			return "Total Points"
		}
	}
}

enum GameFieldZone: String {
	case OffenseCourtyard = "Offense Courtyard"
	case Neutral = "Neutral Zone"
	case DefenseCourtyard = "Defense Courtyard"
}