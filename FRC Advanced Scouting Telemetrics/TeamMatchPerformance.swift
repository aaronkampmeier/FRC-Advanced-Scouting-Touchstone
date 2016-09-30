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
		let color = TeamDataManager.AllianceColor(rawValue: allianceColor!.intValue)!
		switch color {
		case .blue:
			return match?.blueFinalScore?.doubleValue ?? 0
		case .red:
			return match?.redFinalScore?.doubleValue ?? 0
		}
	}
	
	var winningMargin: Double {
		let selfFinalScore = finalScore
		let color = TeamDataManager.AllianceColor(rawValue: allianceColor!.intValue)!
		switch color {
		case .blue:
			return selfFinalScore - (match?.redFinalScore?.doubleValue ?? 0)
		case .red:
			return selfFinalScore - (match?.blueFinalScore?.doubleValue ?? 0)
		}
	}

	enum AutonomousVariable {
		case crossedDefense
		case moved
		case reachedDefense
		case returned
		case shot
		case autoSpy
		case autoSpyDidMakeShot
		case autoSpyDidShoot
		case autoSpyShotHighGoal
		
		func setValue(_ value: AutoValue, inCycle cycle: AutonomousCycle) {
			switch self {
			case .crossedDefense:
				cycle.crossedDefense = value as! Bool as NSNumber?
			case .moved:
				cycle.moved = value as! Bool as NSNumber?
			case .reachedDefense:
				cycle.reachedDefense = value as! Bool as NSNumber?
			case .returned:
				cycle.returned = value as! Bool as NSNumber?
			case .shot:
				cycle.shot = value as! Bool as NSNumber?
			case .autoSpy:
				cycle.matchPerformance?.autoSpy = value as! Bool as NSNumber?
			case .autoSpyDidMakeShot:
				cycle.matchPerformance?.autoSpyDidMakeShot = value as! Bool as NSNumber?
			case .autoSpyDidShoot:
				cycle.matchPerformance?.autoSpyDidShoot = value as! Bool as NSNumber?
			case .autoSpyShotHighGoal:
				cycle.matchPerformance?.autoSpyShotHighGoal = value as! Bool as NSNumber?
			}
		}
		
		func getValue(inCycle cycle: AutonomousCycle) -> AutoValue? {
			switch self {
			case .crossedDefense:
				return cycle.crossedDefense?.boolValue
			case .moved:
				return cycle.moved?.boolValue
			case .reachedDefense:
				return cycle.reachedDefense?.boolValue
			case .returned:
				return cycle.returned?.boolValue
			case .shot:
				return cycle.shot?.boolValue
			case .autoSpy:
				return cycle.matchPerformance?.autoSpy?.boolValue
			case .autoSpyDidShoot:
				return cycle.matchPerformance?.autoSpyDidShoot?.boolValue
			case .autoSpyDidMakeShot:
				return cycle.matchPerformance?.autoSpyDidMakeShot?.boolValue
			case .autoSpyShotHighGoal:
				return cycle.matchPerformance?.autoSpyShotHighGoal?.boolValue
			}
		}
	}
	
	func setValue(_ value: Bool, forAutonomousVariable autoVar: AutonomousVariable) {
		
	}
}

protocol AutoValue {
	
}

extension Bool: AutoValue {
	
}
