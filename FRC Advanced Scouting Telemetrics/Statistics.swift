//
//  Statistics.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

struct StatContext {
	let statCalculations: [StatCalculation]
	
	init(context: [TeamMatchPerformance]) {
		statCalculations = [.TotalPoints(context), .TotalShots(context), .TotalMadeShots(context), .ShotAccuracy(context), .TotalScales(context), .RankingPoints(context), .DefensesCrossed(context), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Portcullis), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.ChevalDeFrise), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Moat), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Ramparts), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.Drawbridge), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.SallyPort), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.RockWall), .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.RoughTerrain),  .AverageDefenseCrossTime(context, TeamDataManager.DefenseType.LowBar), .AverageTimeInZone(context, .DefenseCourtyard), .AverageTimeInZone(context, .OffenseCourtyard), .AverageTimeInZone(context, .Neutral)]
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
	
	//New ones
	case VisionTracking([Team])
	case Height([Team])
	case TotalAutonomousDefenses([Team])
	case TotalHighGoals([TeamMatchPerformance])
	case TotalLowGoals([TeamMatchPerformance])
	case TotalMadeHighGoals([TeamMatchPerformance])
	case TotalMadeLowGoals([TeamMatchPerformance])
	case TeamNumber(Team)
	case TotalDefensesCrossed([TeamMatchPerformance], TeamDataManager.DefenseType)
	
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
//				var matchPerformanceTotal = 0
				let allianceColor = TeamDataManager.AllianceColor(rawValue: matchPerformance.allianceColor!.integerValue)!
				
//				let redFinalScore = matchPerformance.match?.redFinalScore?.integerValue
//				let blueFinalScore = matchPerformance.match?.blueFinalScore?.integerValue
				
				switch allianceColor {
				case .Red:
					return cumulative + (matchPerformance.match?.redRankingPoints?.integerValue ?? 0)
//					//First add points for a capture
//					if (matchPerformance.match?.redCapturedTower?.boolValue) ?? false {
//						matchPerformanceTotal += 1
//					}
//					
//					//Next get points for a breach
//					if matchPerformance.match?.redDefensesBreached?.count >= 4 {
//						matchPerformanceTotal += 1
//					}
//					
//					//Fnally, check who won
//					if redFinalScore > blueFinalScore {
//						matchPerformanceTotal += 2
//					} else if redFinalScore == blueFinalScore {
//						matchPerformanceTotal += 1
//					}
				case .Blue:
					return cumulative + (matchPerformance.match?.blueRankingPoints?.integerValue ?? 0)
//					if (matchPerformance.match?.blueCapturedTower?.boolValue) ?? false {
//						matchPerformanceTotal += 1
//					}
//					if matchPerformance.match?.blueDefensesBreached?.count >= 4 {
//						matchPerformanceTotal += 1
//					}
//					//Fnally, check who won
//					if redFinalScore < blueFinalScore {
//						matchPerformanceTotal += 2
//					} else if redFinalScore == blueFinalScore {
//						matchPerformanceTotal += 1
//					}
				}
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
		case .AverageDefenseCrossTime(_, let defenseType):
			return "Average \(defenseType.string) Cross Time"
		case .AverageTimeInZone(_, let zone):
			return "Average Time in \(zone.rawValue)"
		case .TotalPoints(_):
			return "Total Points"
		default:
			return ""
		}
	}
}

enum GameFieldZone: String {
	case OffenseCourtyard = "Offense Courtyard"
	case Neutral = "Neutral Zone"
	case DefenseCourtyard = "Defense Courtyard"
}