//
//  Defense.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class Defense: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var defenseCategory: TeamDataManager.DefenseCategory {
		return TeamDataManager.DefenseCategory(category: category!.characters.first!)
	}
	
	var defenseType: TeamDataManager.DefenseType {
		return TeamDataManager.DefenseType(rawValue: defenseName!)!
	}
}
