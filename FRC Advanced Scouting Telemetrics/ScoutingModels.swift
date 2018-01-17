//
//  ScoutingModels.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/15/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class ScoutedTeam: Object {
    ///Cross Year Values
    dynamic var key = ""
    dynamic var notes = ""
    dynamic var programmingLanguage: String?
    let robotHeight = RealmOptional<Double>()
    let robotWeight = RealmOptional<Double>()
    let robotLength = RealmOptional<Double>()
    let robotWidth = RealmOptional<Double>()
    dynamic var frontImage: Data?
    dynamic var strategy: String?
    dynamic var canBanana = false
    let driverXP = RealmOptional<Int>()
    dynamic var driveTrain: String?
    dynamic var isInPickList = true
    
    ///Game Based Values
    
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    //To connect to the general team
    @objc private dynamic var universalCache: Team?
    @objc dynamic var universalTeam: Team {
        get {
            if let team = universalCache {
                return team
            } else {
                //Retrieve it and put it in the conveinence variable
                
            }
        }
    }
    override static func ignoredProperties() -> [String] {
        return ["universalCache"]
    }
}

@objcMembers class ScoutedMatch: Object {
    dynamic var key = ""
    dynamic var blueScore = 0
    dynamic var blueRP = 0
    dynamic var redScore = 0
    dynamic var redRP = 0
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class ScoutedMatchPerformance: Object {
    dynamic var key = ""
    dynamic var hasBeenScouted = false
    let timeMarkers = List<TimeMarker>()
    
    //--- Maybe try to remove
    dynamic var defaultScoutID = ""
    let scoutIDs = List<String>()
    //---
    
    dynamic var climbStatus = ""
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class TimeMarker: Object {
    dynamic var event = ""
    dynamic var scoutID = ""
    dynamic var time = Date()
    
    let scoutedMatchPerformance = LinkingObjects(fromType: ScoutedMatchPerformance.self, property: "timeMarkers")
    
    var timeMarkerEventType: TimeMarkerEvent {
        return TimeMarkerEvent(rawValue: event) ?? .Error
    }
}
