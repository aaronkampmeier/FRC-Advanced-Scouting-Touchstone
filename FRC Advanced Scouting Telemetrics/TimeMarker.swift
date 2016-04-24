//
//  TimeMarker.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


class TimeMarker: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

	var timeMarkerEventType: TeamDataManager.TimeMarkerEventType {
		return TeamDataManager.TimeMarkerEventType(rawValue: event!.integerValue)!
	}
}
