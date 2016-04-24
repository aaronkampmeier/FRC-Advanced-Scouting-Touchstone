//
//  Statistics.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

private let dataManager = TeamDataManager()

struct StatContext {
	var matchPerformanceStatistics: [StatCalculation]
	var regionalPerformanceStatistics: [StatCalculation]
	var teamStatistics: [StatCalculation]
	
	var possibleStats: [StatCalculation] {
		return teamStatistics + regionalPerformanceStatistics + matchPerformanceStatistics
	}

	init(context: [TeamMatchPerformance]) {
		matchPerformanceStatistics = []
		teamStatistics = []
		regionalPerformanceStatistics = []
		setMatchPerformanceStatistics(context)
	}
	
	init(context: [Team]) {
		matchPerformanceStatistics = []
		teamStatistics = []
		regionalPerformanceStatistics = []
		setTeamStatistics(context)
	}
	
	init(context: [TeamRegionalPerformance]) {
		matchPerformanceStatistics = []
		teamStatistics = []
		regionalPerformanceStatistics = []
		setRegionalPerformanceStatistics(context)
	}
	
	mutating func setRegionalPerformanceStatistics(context: [TeamRegionalPerformance]) {
		regionalPerformanceStatistics = [.OPR(context), .DPR(context), .CCWM(context)]
	}
	
	mutating func setMatchPerformanceStatistics(context: [TeamMatchPerformance]) {
		matchPerformanceStatistics = [.TotalPoints(context), .TotalShots(context), .TotalMadeShots(context), .TotalHighGoals(context), .TotalMadeHighGoals(context), .TotalLowGoals(context), .TotalMadeLowGoals(context), .ShotAccuracy(context, TeamDataManager.ShotGoal.Both), .TotalScales(context), .RankingPoints(context), .DefensesCrossed(context), .AverageTimeInZone(context, .DefenseCourtyard), .AverageTimeInZone(context, .OffenseCourtyard), .AverageTimeInZone(context, .Neutral), .CycleTime(context), .TotalContacts(context), .TotalContactsDisruptingShots(context), .TotalGamesWithTimeInSection(context, .DefenseCourtyard, 30)]
		
		for defenseType in TeamDataManager.DefenseType.allDefenses {
			matchPerformanceStatistics.append(.TotalCrossingsForDefense(context, defenseType))
		}
	}
	
	mutating func setTeamStatistics(context: [Team]) {
		teamStatistics = [.VisionTracking(context), .Height(context), .Weight(context), .TotalAutonomousDefenses(context)]
	}
}

enum StatCalculation {
	case TotalShots([TeamMatchPerformance])
	case TotalMadeShots([TeamMatchPerformance])
	case TotalScales([TeamMatchPerformance])
	case RankingPoints([TeamMatchPerformance])
	case DefensesCrossed([TeamMatchPerformance])
	case ShotAccuracy([TeamMatchPerformance], TeamDataManager.ShotGoal)
	case AverageTimeInZone([TeamMatchPerformance], GameFieldZone)
	case TotalPoints([TeamMatchPerformance])
	
	//New ones
	case VisionTracking([Team])
	case Height([Team])
	case Weight([Team])
	case TotalAutonomousDefenses([Team])
	case TotalHighGoals([TeamMatchPerformance])
	case TotalLowGoals([TeamMatchPerformance])
	case TotalMadeHighGoals([TeamMatchPerformance])
	case TotalMadeLowGoals([TeamMatchPerformance])
	case TeamNumber(Team)
	case TotalCrossingsForDefense([TeamMatchPerformance], TeamDataManager.DefenseType)
	case CycleTime([TeamMatchPerformance])
	case TotalContacts([TeamMatchPerformance])
	case TotalContactsDisruptingShots([TeamMatchPerformance])
	case TotalGamesWithTimeInSection([TeamMatchPerformance], GameFieldZone, NSTimeInterval)
	case OPR([TeamRegionalPerformance])
	case DPR([TeamRegionalPerformance])
	case CCWM([TeamRegionalPerformance])
	
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
			let total: Int = context.reduce(0) {cumulative,matchPerformance in
				let allianceColor = TeamDataManager.AllianceColor(rawValue: matchPerformance.allianceColor!.integerValue)!
				switch allianceColor {
				case .Red:
					return cumulative + (matchPerformance.match?.redRankingPoints?.integerValue ?? 0)
				case .Blue:
					return cumulative + (matchPerformance.match?.blueRankingPoints?.integerValue ?? 0)
				}
			}
			
			return Double(total)
		case .DefensesCrossed(let context):
			let total = context.reduce(0) {
				$0 + ($1.defenseCrossTimes?.count)!
			}
			return Double(total)
		case .ShotAccuracy(let context, let goal):
			if goal == .Both {
				return StatCalculation.TotalMadeShots(context).value / StatCalculation.TotalShots(context).value
			} else if goal == .High {
				return StatCalculation.TotalMadeHighGoals(context).value / StatCalculation.TotalHighGoals(context).value
			} else {
				return StatCalculation.TotalMadeLowGoals(context).value / StatCalculation.TotalLowGoals(context).value
			}
		case .AverageTimeInZone(let performances, let zone):
			let times = timesInZone(performances, zone: zone)
			let averageTime = times.reduce(0, combine: {$0 + $1}) / Double(times.count)
			return averageTime
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
		case .VisionTracking(let teams):
			let total = teams.reduce(0) {cumulative, team in
				return team.visionTrackingRating?.integerValue ?? 0 + cumulative
			}
			return Double(total)
		case .Height(let teams):
			let total = teams.reduce(0) {cumulative, team in
				return team.height?.integerValue ?? 0 + cumulative
			}
			return Double(total)
		case .Weight(let teams):
			let total = teams.reduce(0) {cumulative, team in
				return team.robotWeight?.integerValue ?? 0 + cumulative
			}
			return Double(total)
		case .TotalAutonomousDefenses(let teams):
			let total = teams.reduce(0) {cumulative, team in
				return team.autonomousDefensesAbleToCross?.count ?? 0 + cumulative
			}
			return Double(total)
		case .TotalHighGoals(let performances):
			let total = performances.reduce(0) {cumulative, performance in
				let shots = performance.offenseShots?.filter() {shot in
					return (shot as! Shot).highGoal?.boolValue ?? false
				}
				return shots?.count ?? 0 + cumulative
			}
			return Double(total)
		case .TotalLowGoals(let performances):
			let total = performances.reduce(0) {cumulative, performance in
				let shots = performance.offenseShots?.filter() {shot in
					let isHighGoalShot = (shot as! Shot).highGoal?.boolValue
					if let isHighGoalShot = isHighGoalShot {
						return !isHighGoalShot
					} else {
						return false
					}
				}
				return shots?.count ?? 0 + cumulative
			}
			return Double(total)
		case .TotalMadeHighGoals(let performances):
			let total = performances.reduce(0) {cumulative, performance in
				let shots = performance.offenseShots?.filter() {shot in
					return (shot as! Shot).highGoal?.boolValue ?? false
				}
				let madeShots = shots?.filter() {shot in
					return !((shot as! Shot).blocked?.boolValue ?? true)
				}
				return madeShots?.count ?? 0 + cumulative
			}
			return Double(total)
		case .TotalMadeLowGoals(let performances):
			let total = performances.reduce(0) {cumulative, performance in
				let shots = performance.offenseShots?.filter() {shot in
					let isHighGoalShot = (shot as! Shot).highGoal?.boolValue
					if let isHighGoalShot = isHighGoalShot {
						return !isHighGoalShot
					} else {
						return false
					}
				}
				let madeShots = shots?.filter() {shot in
					return !((shot as! Shot).blocked?.boolValue ?? true)
				}
				return madeShots?.count ?? 0 + cumulative
			}
			return Double(total)
		case .TeamNumber(let team):
			return Double(team.teamNumber ?? "") ?? 0
		case .TotalCrossingsForDefense(let performances, let defenseType):
			let total: Int = performances.reduce(0) {cumulative, performance in
				let defenseCrossTimes = (performance.defenseCrossTimes?.allObjects as! [DefenseCrossTime]).filter() {defenseCrossTime in
					return defenseCrossTime.defense?.defenseType == defenseType
				}
				return defenseCrossTimes.count
			}
			return Double(total)
		case .CycleTime(let performances):
			var cycleTimes: [NSTimeInterval] = []
			for performance in performances {
				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
				
				var shotBeforeAt: NSTimeInterval?
				var hasCrossedDefenseSinceLastTime = false
				for event in timeOverview {
					if event.type == .AttemptedShot {
						if let previousShotTime = shotBeforeAt {
							if hasCrossedDefenseSinceLastTime {
								cycleTimes.append(event.time - previousShotTime)
								hasCrossedDefenseSinceLastTime = false
							} else {
								shotBeforeAt = event.time
							}
						} else {
							shotBeforeAt = event.time
						}
					} else if event.type == .CrossedDefense {
						if shotBeforeAt != nil {
							hasCrossedDefenseSinceLastTime = true
						}
					}
				}
			}
			let averageCycleTime = cycleTimes.reduce(0, combine: {$0 + $1}) / Double(cycleTimes.count)
			return averageCycleTime
		case .TotalContacts(let performances):
			let total: Int = performances.reduce(0) {cumulative, performance in
				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
				let contacts = timeOverview.filter() {marker in
					return marker.type == .Contact
				}
				return contacts.count + cumulative
			}
			return Double(total)
		case .TotalContactsDisruptingShots(let performances):
			let total: Int = performances.reduce(0) {cumulative, performance in
				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
				let contactsDisrupting = timeOverview.filter() {marker in
					return marker.type == .ContactDisruptingShot
				}
				return contactsDisrupting.count + cumulative
			}
			return Double(total)
		case .TotalGamesWithTimeInSection(let performances, let zone ,let lengthOfTime):
			let filtered = performances.filter() {performance in
				let times = timesInZone([performance], zone: zone)
				for time in times {
					if time >= lengthOfTime {return true}
				}
				return false
			}
			return Double(filtered.count)
		default:
			return 0
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
		case .AverageTimeInZone(_, let zone):
			return "Average Time in \(zone.rawValue)"
		case .TotalPoints(_):
			return "Total Points"
		case .VisionTracking(_):
			 return "Vision Tracking Rating"
		case .Height(_):
			return "Height"
		case .Weight(_):
			return "Weight"
		case .TotalAutonomousDefenses(_):
			return "Total Autonomous Defenses"
		case .TotalHighGoals(_):
			return "Total High Goals"
		case .TotalMadeHighGoals(_):
			return "Total Made High Goals"
		case .TotalLowGoals(_):
			return "Total Low Goals"
		case .TotalMadeLowGoals(_):
			return "Total Made Low Goals"
		case .TeamNumber(_):
			return "Team Number"
		case .TotalCrossingsForDefense(_, let defenseType):
			return "Total \(defenseType) Crossings"
		case .CycleTime(_):
			return "Cycle Time"
		case .TotalContacts(_):
			return "Total Contacts"
		case .TotalContactsDisruptingShots(_):
			return "Total Contacts Disrupting Shots"
		case .TotalGamesWithTimeInSection(_, let zone, let time):
			return "Games With More Than \(time)sec in \(zone)"
		case .OPR(_):
			return "OPR"
		case .DPR(_):
			return "DPR"
		case .CCWM(_):
			return "CCWM"
		}
	}
}

private func timesInZone(performances: [TeamMatchPerformance], zone: GameFieldZone) -> [NSTimeInterval] {
	var timesInZone = [NSTimeInterval]()
	for performance in performances {
		let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
		
		var enteredTime: NSTimeInterval?
		for marker in timeOverview {
			if marker.type == .MovedToOffenseCourtyard || marker.type == .MovedToDefenseCourtyard || marker.type == .MovedToNeutral {
				if (marker.type == .MovedToOffenseCourtyard && zone == .OffenseCourtyard) || (marker.type == .MovedToDefenseCourtyard && zone == .DefenseCourtyard) || (marker.type == .MovedToNeutral && zone == .Neutral) {
					//The marker is for the zone we are measuring
					enteredTime = marker.time
				} else {
					if let enteredTime = enteredTime {
						timesInZone.append(marker.time - enteredTime)
					}
					
					enteredTime = nil
				}
			}
		}
	}
	return timesInZone
}

enum GameFieldZone: String, CustomStringConvertible {
	case OffenseCourtyard = "Offense Courtyard"
	case Neutral = "Neutral Zone"
	case DefenseCourtyard = "Defense Courtyard"
	
	var description: String {
		return self.rawValue
	}
}