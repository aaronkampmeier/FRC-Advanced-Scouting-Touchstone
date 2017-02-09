//
//  TimeMarker+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


open class TimeMarker: NSManagedObject {

	var timeMarkerEventType: TimeMarkerEvent {
		return TimeMarkerEvent(rawValue: event!) ?? .Error
	}
}
