//
//  Shot.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class Shot: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var goal: TeamDataManager.ShotGoal {
		if let highGoal = highGoal?.boolValue {
			if highGoal {
				return TeamDataManager.ShotGoal.high
			} else {
				return TeamDataManager.ShotGoal.low
			}
		} else {
			return TeamDataManager.ShotGoal.both
		}
	}
}
