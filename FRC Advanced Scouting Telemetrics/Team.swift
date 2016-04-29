//
//  Team.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class Team: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	var autonomousDefensesAbleToCrossArray: [Defense] {
		get {
			if let defenses = autonomousDefensesAbleToCross {
				
				return (defenses as AnyObject as! [String]).map() {string in
					return Defense(rawValue: string)!
				}
			} else {
				return []
			}
		}
		
		set {
			let rawArray = newValue.map() {defense in
				return defense.rawValue
			}
			autonomousDefensesAbleToCross = rawArray as NSArray
		}
	}
	
	var autonomousDefensesAbleToShootArray: [Defense] {
		get {
			if let defenses = autonomousDefensesAbleToShoot {
				return (defenses as AnyObject as! [String]).map() {string in
					return Defense(rawValue: string)!
				}
			} else {
				return []
			}
		}
		
		set {
			let rawArray = newValue.map() {defense in
				return defense.rawValue
			}
			autonomousDefensesAbleToShoot = rawArray as NSArray
		}
	}
	
	var defensesAbleToCrossArray: [Defense] {
		get {
			if let defenses = defensesAbleToCross {
				return (defenses as AnyObject as! [String]).map() {string in
					return Defense(rawValue: string)!
				}
			} else {
				return []
			}
		}
		
		set {
			let rawArray = newValue.map() {defense in
				return defense.rawValue
			}
			defensesAbleToCross = rawArray as NSArray
		}
	}
}
