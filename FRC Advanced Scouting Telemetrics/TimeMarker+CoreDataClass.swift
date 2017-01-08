//
//  TimeMarker+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


public class TimeMarker: NSManagedObject {

	var timeMarkerEventType: TeamDataManager.TimeMarkerEventType {
		return TeamDataManager.TimeMarkerEventType(rawValue: event!.intValue) ?? .error
	}
}