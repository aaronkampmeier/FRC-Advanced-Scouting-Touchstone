//
//  TimeMarker.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/28/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class TimeMarker: Object {
    dynamic var event = ""
    dynamic var scoutID = ""
    dynamic var time: TimeInterval = 0
    dynamic var isAuto: Bool = false
    
    dynamic var associatedLocation: String? = nil
    
    dynamic var scoutedMatchPerformance: ScoutedMatchPerformance?
    
    var timeMarkerEventType: TimeMarkerEvent {
        return TimeMarkerEvent(rawValue: event) ?? .Error
    }
}

enum TimeMarkerEvent: String, CustomStringConvertible {
    //Year-by-year
    case GrabbedCube = "Grabbed Cube"
    case PlacedCube = "Placed Cube"
    
    //Cross-Year
    case EndedAutonomous = "Ended Autonomous"
    case Error
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}
