//
//  Match.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class Match: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	var blueDefensesArray: [Defense] {
		get {
			if let defenses = blueDefenses {
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
			blueDefenses = rawArray as NSArray
		}
	}
	
	var blueBreachedDefensesArray: [Defense] {
		get {
			if let defenses = blueDefensesBreached {
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
			blueDefensesBreached = rawArray as NSArray
		}
	}
	
	var redDefensesArray: [Defense] {
		get {
			if let defenses = redDefenses {
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
			redDefenses = rawArray as NSArray
		}
	}
	
	var redBreachedDefensesArray: [Defense] {
		get {
			if let defenses = redDefensesBreached {
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
			redDefensesBreached = rawArray as NSArray
		}
	}
}
