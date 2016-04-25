//
//  TeamMatchPerformance.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class TeamMatchPerformance: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	
	var finalScore: Double {
		let color = TeamDataManager.AllianceColor(rawValue: allianceColor!.integerValue)!
		switch color {
		case .Blue:
			return match?.blueFinalScore?.doubleValue ?? 0
		case .Red:
			return match?.redFinalScore?.doubleValue ?? 0
		}
	}
	
	var winningMargin: Double {
		let selfFinalScore = finalScore
		let color = TeamDataManager.AllianceColor(rawValue: allianceColor!.integerValue)!
		switch color {
		case .Blue:
			return selfFinalScore - (match?.redFinalScore?.doubleValue ?? 0)
		case .Red:
			return selfFinalScore - (match?.blueFinalScore?.doubleValue ?? 0)
		}
	}

	enum AutonomousVariable {
		case CrossedDefense
		case Moved
		case ReachedDefense
		case Returned
		case Shot
		case AutoSpy
		case AutoSpyDidMakeShot
		case AutoSpyDidShoot
		case AutoSpyShotHighGoal
		
		func setValue(value: AutoValue, inCycle cycle: AutonomousCycle) {
			switch self {
			case .CrossedDefense:
				cycle.crossedDefense = value as! Bool
			case .Moved:
				cycle.moved = value as! Bool
			case .ReachedDefense:
				cycle.reachedDefense = value as! Bool
			case .Returned:
				cycle.returned = value as! Bool
			case .Shot:
				cycle.shot = value as! Bool
			case .AutoSpy:
				cycle.matchPerformance?.autoSpy = value as! Bool
			case .AutoSpyDidMakeShot:
				cycle.matchPerformance?.autoSpyDidMakeShot = value as! Bool
			case .AutoSpyDidShoot:
				cycle.matchPerformance?.autoSpyDidShoot = value as! Bool
			case .AutoSpyShotHighGoal:
				cycle.matchPerformance?.autoSpyShotHighGoal = value as! Bool
			}
		}
		
		func getValue(inCycle cycle: AutonomousCycle) -> AutoValue? {
			switch self {
			case .CrossedDefense:
				return cycle.crossedDefense?.boolValue
			case .Moved:
				return cycle.moved?.boolValue
			case .ReachedDefense:
				return cycle.reachedDefense?.boolValue
			case .Returned:
				return cycle.returned?.boolValue
			case .Shot:
				return cycle.shot?.boolValue
			case .AutoSpy:
				return cycle.matchPerformance?.autoSpy?.boolValue
			case .AutoSpyDidShoot:
				return cycle.matchPerformance?.autoSpyDidShoot?.boolValue
			case .AutoSpyDidMakeShot:
				return cycle.matchPerformance?.autoSpyDidMakeShot?.boolValue
			case .AutoSpyShotHighGoal:
				return cycle.matchPerformance?.autoSpyShotHighGoal?.boolValue
			}
		}
	}
	
	func setValue(value: Bool, forAutonomousVariable autoVar: AutonomousVariable) {
		
	}
}

protocol AutoValue {
	
}

extension Bool: AutoValue {
	
}

extension Defense: AutoValue {
	
}
