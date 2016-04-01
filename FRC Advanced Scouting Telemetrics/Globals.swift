//
//  Globals.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

let skippedVersionKey = "skippedVersion"

let appManifestStringURL = "itms-services://?action=download-manifest&url=https://dl.dropboxusercontent.com/s/hdgc21cu3vzspcg/manifest.plist"

let latestVersionStringURL = "https://dl.dropboxusercontent.com/s/xvjxmo77plk3wxz/current.txt"

//Custom Operators
/**
An operator to easily decide which of two values to use in a merged object
*/
infix operator ~? {}

func ~? (left: Double, right: Double) -> Double {
	//Check is the numbers represent bools
	if (left == 0 || left == 1) && (right == 0 || right == 1) {
		if right == 1 || left == 1 {
			return 1
		} else {
			return 0
		}
	}
	
	if left == 0 {
		return right
	} else if right == 0 {
		return left
	} else {
		return (left + right) / 2 //Return the average if both have values
	}
}

func ~? (left: Int, right: Int) -> Int {
	return Int((Double(left) ~? Double(right)))
}

func ~? (left: NSNumber, right: NSNumber) -> NSNumber {
	return NSNumber(double: left.doubleValue ~? right.doubleValue)
}

func ~? (left: NSNumber?, right: NSNumber?) -> NSNumber? {
	let result = NSNumber(double: left?.doubleValue ?? 0 ~? right?.doubleValue ?? 0)
	if result != 0 {
		return result
	} else {
		return nil
	}
}

///Very unlogical, maybe don't use
func ~? (left: String?, right: String?) -> String? {
	if left == nil && right == nil {
		return nil
	} else if left == nil && right != nil {
		return right
	} else if right == nil && left != nil {
		return left
	} else if left?.characters.count > right?.characters.count {
		return left
	} else {
		return right
	}
}

func + (left: NSSet?, right: NSSet?) -> NSSet {
	return left?.setByAddingObjectsFromSet(right as? Set<NSObject> ?? Set()) ?? NSSet()
}

//func ==(left: Payload, right: Payload) -> Bool {
//	return left.equalToOther(right)
//}