//
//  Statistics.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import Surge

///Would like to redo the entire statistics handling to be more simplistic as follows:
//One function that you pass an object and it returns stats on the object (i.e. func stats(object: NSManagedObject) -> ApplicableStats)
//Then another option to specify a stat that you would like calculated on an object (to be used for easy sorting without calculating all stats)
//Or instead just add the stats as properties into the NSManagedObject Subclasses to call them directly and have them manage their own caching

protocol StatValue: CustomStringConvertible {
    var numericValue: Double {get}
}

extension Int: StatValue {
    var numericValue: Double {
        get {
            return Double(self)
        }
    }
}

extension Double: StatValue {
    var numericValue: Double {
        get {
            return self
        }
    }
}

extension Bool: StatValue {
    var numericValue: Double {
        get {
            return Double(self.hashValue)
        }
    }
}

extension String: StatValue {
    var numericValue: Double {
        get {
            return 0
        }
    }
}

struct NoStatValue: StatValue, CustomStringConvertible {
    var description: String = "No Data"
    var numericValue: Double {
        get {
            return Double.nan
        }
    }
}
let StatNoData = NoStatValue()

//Grabbed off of http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift
//Provides a way to map the values in a dictionary with a single function
extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    ///Map through the values in a dictionary and return a dictionary with the same keys and new values
    func map<OutValue>( transform: (Value) throws -> OutValue) rethrows -> [Key: OutValue] {
        return Dictionary<Key, OutValue>(try map { (k, v) in (k, try transform(v)) })
    }
}

protocol HasStats {
    associatedtype StatName: StatNameable, Hashable
    var stats: [StatName:()->StatValue?] {get} //A list of all the stats a class has and a function to compute it
}

protocol StatNameable {
    associatedtype StatName: Hashable
    static var allValues: [StatName] {get}
}

//This provides the basic stat functions to all stat-able classes using their stats property
extension HasStats {
    func allStats() -> [StatName] {
        return Array(stats.keys)
    }
    
    func statsAndValues() -> [StatName : StatValue?] {
        return stats.map {$0()}
    }
    
    func statValue(forStat stat: StatName) -> StatValue {
        return stats[stat]?() ?? Double.nan
    }
}

//private let dataManager = TeamDataManager()
//private let matrixACache = NSCache<Event, StatCalculation.CachedMatrix>()
//private let arrayXCache = NSCache<NSString, StatCalculation.CachedMatrix>()

//struct StatContext {
//	var name: String?
//	var matchPerformances: [TeamMatchPerformance]?
//	var team: Team?
//	var eventPerformance: TeamEventPerformance?
//	
//	var matchPerformanceStatistics: [StatCalculation]
//	var eventPerformanceStatistics: [StatCalculation]
//	var teamStatistics: [StatCalculation]
//	
//	var possibleStats: [StatCalculation] {
//		return teamStatistics + eventPerformanceStatistics + matchPerformanceStatistics
//	}
//	
//	init() {
//		matchPerformanceStatistics = []
//		teamStatistics = []
//		eventPerformanceStatistics = []
//	}
//	
//	init(context: [TeamMatchPerformance]) {
//		matchPerformances = context
//		matchPerformanceStatistics = []
//		teamStatistics = []
//		eventPerformanceStatistics = []
//		setMatchPerformanceStatistics(context)
//	}
//	
//	init(context: Team) {
//		team = context
//		matchPerformanceStatistics = []
//		teamStatistics = []
//		eventPerformanceStatistics = []
//		setTeamStatistics(context)
//	}
//	
//	init(context: TeamEventPerformance) {
//		eventPerformance = context
//		matchPerformanceStatistics = []
//		teamStatistics = []
//		eventPerformanceStatistics = []
//		setEventPerformanceStatistics(context)
//	}
//	
//	mutating func setEventPerformanceStatistics(_ context: TeamEventPerformance?) {
//		if let context = context {
//			eventPerformanceStatistics = [.opr(context), .dpr(context), .ccwm(context)]
//		} else {
//			eventPerformanceStatistics = []
//		}
//	}
//	
//	mutating func setMatchPerformanceStatistics(_ context: [TeamMatchPerformance]?) {
//		if let context = context {
//			matchPerformanceStatistics = [.totalPoints(context), .totalShots(context), .totalMadeShots(context), .totalHighGoals(context), .totalMadeHighGoals(context), .totalLowGoals(context), .totalMadeLowGoals(context), .shotAccuracy(context, TeamDataManager.ShotGoal.both), .totalScales(context), .rankingPoints(context), .defensesCrossed(context), .averageTimeInZone(context, .DefenseCourtyard), .averageTimeInZone(context, .OffenseCourtyard), .averageTimeInZone(context, .Neutral), .cycleTime(context), .totalContacts(context), .totalContactsDisruptingShots(context), .totalGamesWithTimeInSection(context, .DefenseCourtyard, 30)]
//			for defenseType in Defense.allDefenses {
//				matchPerformanceStatistics.append(.totalCrossingsForDefense(context, defenseType))
//			}
//		} else {
//			matchPerformanceStatistics = []
//		}
//	}
//	
//	mutating func setTeamStatistics(_ context: Team?) {
//		if let context = context {
//			teamStatistics = [.teamNumber(context), .visionTracking([context]), .height([context]), .weight([context]), .totalAutonomousDefenses([context])]
//		} else {
//			teamStatistics = []
//		}
//	}
//}
//
//enum StatCalculation: CustomStringConvertible {
//	case totalShots([TeamMatchPerformance])
//	case totalMadeShots([TeamMatchPerformance])
//	case totalScales([TeamMatchPerformance])
//	case rankingPoints([TeamMatchPerformance])
//	case defensesCrossed([TeamMatchPerformance])
//	case shotAccuracy([TeamMatchPerformance], TeamDataManager.ShotGoal)
//	case averageTimeInZone([TeamMatchPerformance], GameFieldZone)
//	case totalPoints([TeamMatchPerformance])
//	case visionTracking([Team])
//	case height([Team])
//	case weight([Team])
//	case totalAutonomousDefenses([Team])
//	case totalHighGoals([TeamMatchPerformance])
//	case totalLowGoals([TeamMatchPerformance])
//	case totalMadeHighGoals([TeamMatchPerformance])
//	case totalMadeLowGoals([TeamMatchPerformance])
//	case teamNumber(Team)
//	case totalCrossingsForDefense([TeamMatchPerformance], Defense)
//	case cycleTime([TeamMatchPerformance])
//	case totalContacts([TeamMatchPerformance])
//	case totalContactsDisruptingShots([TeamMatchPerformance])
//	case totalGamesWithTimeInSection([TeamMatchPerformance], GameFieldZone, TimeInterval)
//	case opr(TeamEventPerformance)
//	case dpr(TeamEventPerformance)
//	case ccwm(TeamEventPerformance)
//	
//	//Newbs
//	case lowGoalAccuracy([TeamMatchPerformance])
//	case highGoalAccuracy([TeamMatchPerformance])
//	case autonomousPoints([TeamMatchPerformance])
//	
//	//Calculations for all the stat types
//	var value: Double {
//		switch self {
//		case .totalShots(let context):
//			return Double(context.reduce(0) {
//				$0 + $1.offenseShots!.count
//				})
//		case .totalMadeShots(let context):
//			let totalMadeShots = context.reduce(0) {currentCount,performance in
//				let madeShots = ((performance.offenseShots?.allObjects as! [Shot]).filter() {!($0.blocked?.boolValue)!}).count
//				return currentCount + madeShots
//			}
//			return Double(totalMadeShots)
//		case .totalScales(let context):
//			let total: Int = context.reduce(0) {
//				if ($1.didScaleTower?.boolValue) ?? false {
//					//They did scale the tower
//					return $0 + 1
//				} else {
//					return $0
//				}
//			}
//			return Double(total)
//		case .rankingPoints(let context):
//			let total: Int = context.reduce(0) {cumulative,matchPerformance in
//				let allianceColor = TeamDataManager.AllianceColor(rawValue: matchPerformance.allianceColor!.intValue)!
//				switch allianceColor {
//				case .red:
//					return cumulative + (matchPerformance.match?.redRankingPoints?.intValue ?? 0)
//				case .blue:
//					return cumulative + (matchPerformance.match?.blueRankingPoints?.intValue ?? 0)
//				}
//			}
//			
//			return Double(total)
//		case .defensesCrossed(let context):
//			let total = context.reduce(0) {
//				$0 + ($1.defenseCrossTimes?.count)!
//			}
//			return Double(total)
//		case .shotAccuracy(let context, let goal):
//			if goal == .both {
//				return StatCalculation.totalMadeShots(context).value / StatCalculation.totalShots(context).value
//			} else if goal == .high {
//				return StatCalculation.totalMadeHighGoals(context).value / StatCalculation.totalHighGoals(context).value
//			} else {
//				return StatCalculation.totalMadeLowGoals(context).value / StatCalculation.totalLowGoals(context).value
//			}
//		case .averageTimeInZone(let performances, let zone):
//			let times = timesInZone(performances, zone: zone)
//			let averageTime = times.reduce(0, {$0 + $1}) / Double(times.count)
//			return averageTime
//		case .totalPoints(let context):
//			let total: Double = context.reduce(0) {cumulative,matchPerformance in
//				var performanceTotal = 0.0
//				switch TeamDataManager.AllianceColor(rawValue: (matchPerformance.allianceColor?.intValue)!)! {
//				case .red:
//					performanceTotal += (matchPerformance.match?.redFinalScore?.doubleValue) ?? 0
//				case .blue:
//					performanceTotal += (matchPerformance.match?.blueFinalScore?.doubleValue) ?? 0
//				}
//				
//				return cumulative + performanceTotal
//			}
//			
//			return Double(total)
//		case .visionTracking(let teams):
//			let total = teams.reduce(0) {cumulative, team in
//				return team.visionTrackingRating?.intValue ?? 0 + cumulative
//			}
//			return Double(total)
//		case .height(let teams):
//			let total = teams.reduce(0) {cumulative, team in
//				return team.height?.intValue ?? 0 + cumulative
//			}
//			return Double(total)
//		case .weight(let teams):
//			let total = teams.reduce(0) {cumulative, team in
//				return team.robotWeight?.intValue ?? 0 + cumulative
//			}
//			return Double(total)
//		case .totalAutonomousDefenses(let teams):
//			let total = teams.reduce(0) {cumulative, team in
//				return team.autonomousDefensesAbleToCross?.count ?? 0 + cumulative
//			}
//			return Double(total)
//		case .totalHighGoals(let performances):
//			let total = performances.reduce(0) {cumulative, performance in
//				let shots = performance.offenseShots?.filter() {shot in
//					return (shot as! Shot).highGoal?.boolValue ?? false
//				}
//				return shots?.count ?? 0 + cumulative
//			}
//			return Double(total)
//		case .totalLowGoals(let performances):
//			let total = performances.reduce(0) {cumulative, performance in
//				let shots = performance.offenseShots?.filter() {shot in
//					let isHighGoalShot = (shot as! Shot).highGoal?.boolValue
//					if let isHighGoalShot = isHighGoalShot {
//						return !isHighGoalShot
//					} else {
//						return false
//					}
//				}
//				return shots?.count ?? 0 + cumulative
//			}
//			return Double(total)
//		case .totalMadeHighGoals(let performances):
//			let total = performances.reduce(0) {cumulative, performance in
//				let shots = performance.offenseShots?.filter() {shot in
//					return (shot as! Shot).highGoal?.boolValue ?? false
//				}
//				let madeShots = shots?.filter() {shot in
//					return !((shot as! Shot).blocked?.boolValue ?? true)
//				}
//				return madeShots?.count ?? 0 + cumulative
//			}
//			return Double(total)
//		case .totalMadeLowGoals(let performances):
//			let total = performances.reduce(0) {cumulative, performance in
//				let shots = performance.offenseShots?.filter() {shot in
//					let isHighGoalShot = (shot as! Shot).highGoal?.boolValue
//					if let isHighGoalShot = isHighGoalShot {
//						return !isHighGoalShot
//					} else {
//						return false
//					}
//				}
//				let madeShots = shots?.filter() {shot in
//					return !((shot as! Shot).blocked?.boolValue ?? true)
//				}
//				return madeShots?.count ?? 0 + cumulative
//			}
//			return Double(total)
//		case .teamNumber(let team):
//			return Double(team.teamNumber ?? "") ?? 0
//		case .totalCrossingsForDefense(let performances, let defense):
//			let total: Int = performances.reduce(0) {cumulative, performance in
//				let defenseCrossTimes = (performance.defenseCrossTimes?.allObjects as! [DefenseCrossTime]).filter() {defenseCrossTime in
//					return defenseCrossTime.getDefense() == defense
//				}
//				return defenseCrossTimes.count
//			}
//			return Double(total)
//		case .cycleTime(let performances):
//			var cycleTimes: [TimeInterval] = []
//			for performance in performances {
//				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
//				
//				var shotBeforeAt: TimeInterval?
//				var hasCrossedDefenseSinceLastTime = false
//				for event in timeOverview {
//					if event.type == .attemptedShot || event.type == .successfulHighShot || event.type == .successfulLowShot {
//						if let previousShotTime = shotBeforeAt {
//							if hasCrossedDefenseSinceLastTime {
//								cycleTimes.append(event.time - previousShotTime)
//								hasCrossedDefenseSinceLastTime = false
//							} else {
//								shotBeforeAt = event.time
//							}
//						} else {
//							shotBeforeAt = event.time
//						}
//					} else if event.type == .crossedDefense {
//						if shotBeforeAt != nil {
//							hasCrossedDefenseSinceLastTime = true
//						}
//					}
//				}
//			}
//			let averageCycleTime = cycleTimes.reduce(0, {$0 + $1}) / Double(cycleTimes.count)
//			return averageCycleTime
//		case .totalContacts(let performances):
//			let total: Int = performances.reduce(0) {cumulative, performance in
//				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
//				let contacts = timeOverview.filter() {marker in
//					return marker.type == .contact
//				}
//				return contacts.count + cumulative
//			}
//			return Double(total)
//		case .totalContactsDisruptingShots(let performances):
//			let total: Int = performances.reduce(0) {cumulative, performance in
//				let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
//				let contactsDisrupting = timeOverview.filter() {marker in
//					return marker.type == .contactDisruptingShot
//				}
//				return contactsDisrupting.count + cumulative
//			}
//			return Double(total)
//		case .totalGamesWithTimeInSection(let performances, let zone ,let lengthOfTime):
//			let filtered = performances.filter() {performance in
//				let times = timesInZone([performance], zone: zone)
//				for time in times {
//					if time >= lengthOfTime {return true}
//				}
//				return false
//			}
//			return Double(filtered.count)
//		case .opr(let eventPerformance):
//			//OPR stands for offensive power rating. The main idea: robot1+robot2+robot3 = redScore & robot4+robot5+robot6 = blueScore. It is calculated as follows. First, a N*N matrix (A), where N is the number of teams, is created. Each value in A is the number of matches that the two teams comprising the index play together. Then an array (B) is created where the number of elements is equal to the number of teams, N, and in the same order as A. Each element in B is the sum of all match scores for the team at that index. A third array (x) is also size N and each value in it represents the OPR for the team at that index. A * x = B. Given A and B, one can solve for x. (Alliance color doesn't really matter for this calculation)
//			
//			let event = eventPerformance.event!
//			let teamPerformances = event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
//			let numOfTeams = teamPerformances.count
//			
//			let matrixX: Matrix<Double>
//			//Cache the resulting array because it is an expensive calculation
//			if let cachedMatrix = arrayXCache.object(forKey: "OPR: \(event.eventNumber!.intValue)" as NSString) {
//				matrixX = cachedMatrix.matrix
//			} else {
//				//Check to make sure there are multiple teams to perform the calculation
//				if numOfTeams <= 1 {
//					return 0
//				}
//				
//				//Build matrix A
//				let matrixA = createMatrixA(withEvent: event)
//				
//				//Build matrix B
//				var arrayMatrixB = createArrayMatrix(height: numOfTeams, width: 1, initValue: 0.0)
//				for teamPerformance in teamPerformances {
//					let sumOfMatchScores: Double = teamPerformance.matchPerformances!.reduce(0) {cumulative, matchPerformance in
//						return (matchPerformance as! TeamMatchPerformance).finalScore + cumulative
//					}
//					let place = teamPerformances.index(of: teamPerformance)!
//					arrayMatrixB[place][0] = sumOfMatchScores
//				}
//				let matrixB = Matrix(arrayMatrixB)
//				
//				//Now solve for x
//				matrixX = inv(matrixA) * matrixB
//				arrayXCache.setObject(CachedMatrix(matrix: matrixX), forKey: "OPR: \(event.eventNumber!.intValue)" as NSString)
//			}
//			
//			let oprForTeam = matrixX[teamPerformances.index(of: eventPerformance)!,0]
//			return oprForTeam
//		case .ccwm(let eventPerformance):
//			//CCWM stands for Calculated Contribution to the Winning Margin. It is calculated the same as OPR except for the elements in array B are the sums of the winning margins for each match.
//			
//			let event = eventPerformance.event!
//			let teamPerformances = event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
//			let numOfTeams = teamPerformances.count
//			
//			let matrixX: Matrix<Double>
//			//Cache the resulting array because it is an expensive calculation
//			if let cachedMatrix = arrayXCache.object(forKey: "CCWM: \(event.eventNumber!.intValue)" as NSString) {
//				//If there is a cache of the matrix, then use that one instead
//				matrixX = cachedMatrix.matrix
//			} else {
//				//Check to make sure there are multiple teams to perform the calculation
//				if numOfTeams == 1 {
//					return 0
//				}
//				
//				//Create matrix A
//				let matrixA = createMatrixA(withEvent: event)
//				
//				//Create matrix B
//				var arrayMatrixB = createArrayMatrix(height: numOfTeams, width: 1, initValue: 0.0)
//				for teamPerformance in teamPerformances {
//					let sumOfMatchScores: Double = teamPerformance.matchPerformances!.reduce(0) {cumulative, matchPerformance in
//						return (matchPerformance as! TeamMatchPerformance).winningMargin + cumulative
//					}
//					let place = teamPerformances.index(of: teamPerformance)!
//					arrayMatrixB[place][0] = sumOfMatchScores
//				}
//				let matrixB = Matrix(arrayMatrixB)
//				
//				//Now solve for x
//				matrixX = inv(matrixA) * matrixB
//				arrayXCache.setObject(CachedMatrix(matrix: matrixX), forKey: "CCWM: \(event.eventNumber!.intValue)" as NSString)
//			}
//			
//			let ccwmForTeam = matrixX[teamPerformances.index(of: eventPerformance)!,0]
//			return ccwmForTeam
//		case .dpr(let eventPerformance):
//			//DPR stands for Defensive Power Rating. It is OPR - CCWM.
//			return StatCalculation.opr(eventPerformance).value - StatCalculation.ccwm(eventPerformance).value
//		default:
//			return 0
//		}
//	}
//	
//	private func createArrayMatrix<T>(height: Int, width: Int, initValue: T) -> [[T]] {
//		return [[T]](repeating: [T](repeating: initValue, count: width), count: height)
//	}
//	
//	private func createMatrixA(withEvent event: Event) -> Matrix<Double> {
//		//Cache the matrix because it is expensive to create
//		if let cachedMatrix = matrixACache.object(forKey: event) {
//			return cachedMatrix.matrix
//		} else {
//			//Grab all the teams playing in the event
//			let teamEventPerformances = event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
//			let numOfTeams = teamEventPerformances.count
//			
//			//In order to make an array, first create an array of arrays representing each row in a matrix filled with zeroes
//			let arrayMatrix = createArrayMatrix(height: numOfTeams, width: numOfTeams, initValue: 0.0)
//			var matrixA = Matrix(arrayMatrix)
//			
//			//Trying a little different way
//			for firstTeamIndex in 0..<teamEventPerformances.count {
//				//First grab all the matches that the first team participated in
//				let firstTeamMatchPerformances = Array(teamEventPerformances[firstTeamIndex].matchPerformances!) as! [TeamMatchPerformance]
//				
//				for secondTeamIndex in 0..<teamEventPerformances.count {
//					//Then grab all the matches the second teams participated in
//					let secondTeamMatchPerformances = Array(teamEventPerformances[secondTeamIndex].matchPerformances!) as! [TeamMatchPerformance]
//					
//					//See which matches the teams have in common and are on the same alliance
//					var numOfCommonPlays = 0
//					for firstTeamPerformance in firstTeamMatchPerformances {
//						for secondTeamPerformance in secondTeamMatchPerformances {
//							if firstTeamPerformance.match == secondTeamPerformance.match && (firstTeamPerformance.allianceColor?.isEqual(to: secondTeamPerformance.allianceColor!))! {
//								numOfCommonPlays += 1
//							}
//						}
//					}
//					
//					//Set the number of common plays on an alliance in the matrix
//					matrixA[firstTeamIndex, secondTeamIndex] = Double(numOfCommonPlays)
//				}
//			}
//
//			/*
//			for firstTeamPerformance in teamEventPerformances {
//				let firstPlace = teamEventPerformances.index(of: firstTeamPerformance)!.hashValue
//				let firstMatches: Set<Match> = Set(firstTeamPerformance.matchPerformances!.map() {performance in
//					return (performance as! TeamMatchPerformance).match!
//					})
//				for secondTeamPerformance in teamEventPerformances {
//					let secondPlace = teamEventPerformances.index(of: secondTeamPerformance)!.hashValue
//					let secondMatches: Set<Match> = Set(secondTeamPerformance.matchPerformances!.map() {performance in
//						return (performance as! TeamMatchPerformance).match!
//						})
//					
//					//Find the matches they have in common
//					let sharedMatches = firstMatches.intersection(secondMatches)
//					
//					//Set the number of shared matches in the matrix
//					matrixA[firstPlace,secondPlace] = Double(sharedMatches.count)
//				}
//			}
//*/
//			
//			matrixACache.setObject(CachedMatrix(matrix: matrixA), forKey: event)
//			return matrixA
//		}
//	}
//	
//	class CachedMatrix {
//		let matrix: Matrix<Double>
//		
//		init(matrix: Matrix<Double>) {
//			self.matrix = matrix
//		}
//	}
//	
//	var description: String {
//		switch self {
//		case .totalShots(_):
//			return "Total Shots"
//		case .totalMadeShots(_):
//			return "Total Made Shots"
//		case .totalScales(_):
//			return "Total Scales"
//		case .rankingPoints(_):
//			return "Ranking Points"
//		case .defensesCrossed(_):
//			return "Defenses Crossed"
//		case .shotAccuracy(_):
//			return "Shot Accuracy"
//		case .averageTimeInZone(_, let zone):
//			return "Average Time in \(zone.rawValue)"
//		case .totalPoints(_):
//			return "Total Points"
//		case .visionTracking(_):
//			 return "Vision Tracking Rating"
//		case .height(_):
//			return "Height"
//		case .weight(_):
//			return "Weight"
//		case .totalAutonomousDefenses(_):
//			return "Total Autonomous Defenses"
//		case .totalHighGoals(_):
//			return "Total High Goals"
//		case .totalMadeHighGoals(_):
//			return "Total Made High Goals"
//		case .totalLowGoals(_):
//			return "Total Low Goals"
//		case .totalMadeLowGoals(_):
//			return "Total Made Low Goals"
//		case .teamNumber(_):
//			return "Team Number"
//		case .totalCrossingsForDefense(_, let defenseType):
//			return "Total \(defenseType) Crossings"
//		case .cycleTime(_):
//			return "Cycle Time"
//		case .totalContacts(_):
//			return "Total Contacts"
//		case .totalContactsDisruptingShots(_):
//			return "Total Contacts Disrupting Shots"
//		case .totalGamesWithTimeInSection(_, let zone, let time):
//			return "Games With More Than \(time)sec in \(zone)"
//		case .opr(_):
//			return "OPR"
//		case .dpr(_):
//			return "DPR"
//		case .ccwm(_):
//			return "CCWM"
//		default:
//			return ""
//		}
//	}
//}
//
//private func timesInZone(_ performances: [TeamMatchPerformance], zone: GameFieldZone) -> [TimeInterval] {
//	var timesInZone = [TimeInterval]()
//	for performance in performances {
//		let timeOverview = dataManager.timeOverview(forMatchPerformance: performance)
//		
//		var enteredTime: TimeInterval?
//		for marker in timeOverview {
//			if marker.type == .movedToOffenseCourtyard || marker.type == .movedToDefenseCourtyard || marker.type == .movedToNeutral {
//				if (marker.type == .movedToOffenseCourtyard && zone == .OffenseCourtyard) || (marker.type == .movedToDefenseCourtyard && zone == .DefenseCourtyard) || (marker.type == .movedToNeutral && zone == .Neutral) {
//					//The marker is for the zone we are measuring
//					enteredTime = marker.time
//				} else {
//					if let enteredTime = enteredTime {
//						timesInZone.append(marker.time - enteredTime)
//					}
//					
//					enteredTime = nil
//				}
//			}
//		}
//	}
//	return timesInZone
//}
