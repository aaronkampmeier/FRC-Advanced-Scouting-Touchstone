//
//  Team.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/15/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Team: Object {
    dynamic var key = ""
    dynamic var location: String?
    dynamic var name = ""
    dynamic var nickname = ""
    let rookieYear = RealmOptional<Int>()
    dynamic var teamNumber = 0
    dynamic var website: String?
    
    let eventPerformances = List<TeamEventPerformance>()
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

@objcMembers class TeamEventPerformance: Object {
    let events = LinkingObjects(fromType: Event.self, property: "teamEventPerformances")
    let team = LinkingObjects(fromType: Team.self, property: "eventPerformances")
    let alliancePositions = LinkingObjects(fromType: AlliancePosition.self, property: "teamEventPerformance")
    
    dynamic var key = ""
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class Event: Object {
    dynamic var code = ""
    dynamic var eventType = 0
    dynamic var eventTypeString = ""
    dynamic var key = ""
    dynamic var location: String?
    dynamic var name = ""
    dynamic var year = 0
    
    let teamEventPerformances = List<TeamEventPerformance>()
    let matches = List<Match>()
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class Match: Object {
    dynamic var competitionLevel = ""
    dynamic var key = ""
    dynamic var matchNumber = 0
    let setNumber = RealmOptional<Int>()
    dynamic var time: Date?
    
    let alliancePositions = List<AlliancePosition>()
    let event = LinkingObjects(fromType: Event.self, property: "matches")
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class AlliancePosition: Object {
    dynamic var allianceColor = ""
    dynamic var allianceTeam = 0
    dynamic var key = ""
    
    let match = LinkingObjects(fromType: Match.self, property: "alliancePositions")
    
    dynamic var teamEventPerformance: TeamEventPerformance?
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class GeneralRanker: Object {
    dynamic var key = "General Ranker" //Is a singleton
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class EventRanker: Object {
    dynamic var key = "" //One for each event
    
    override static func primaryKey() -> String {
        return "key"
    }
}
