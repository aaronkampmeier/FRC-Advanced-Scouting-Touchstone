//
//  ScoutingModels.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/15/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

@objcMembers class GeneralRanker: Object {
    dynamic var key = "General Ranker" //Is a singleton
    
    dynamic let rankedTeams = List<ScoutedTeam>()
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class EventRanker: Object {
    dynamic var key = "" //One for each event. Follows "ranker_(event code)"
    
    dynamic let rankedTeams = List<ScoutedTeam>()
    
    ///Teams that have been picked; the ones that are no longer in pick list
    dynamic let pickedTeams = List<ScoutedTeam>()
    
    func isInPickList(team: Team) -> Bool {
        return !pickedTeams.contains(team.scouted)
    }
    
    ///Must be within write transaction
    func setIsInPickList(_ isIn: Bool, team: Team) {
        guard rankedTeams.contains(team.scouted) else {
            CLSNSLogv("Trying to set team in pick list that is not even part of the event", getVaList([]))
            return
        }
        
        if isIn {
            //Remove it from the picked teams
            if let index = pickedTeams.index(of: team.scouted) {
                pickedTeams.remove(at: index)
            } else {
                //Already not in
            }
        } else {
            //Add it to the picked teams
            guard !pickedTeams.contains(team.scouted) else {
                //Already in the pick list so return
                return
            }
            
            pickedTeams.append(team.scouted)
        }
    }
    
    override static func primaryKey() -> String {
        return "key"
    }
}

@objcMembers class ScoutedTeam: Object, HasGeneralEquivalent {
    
    typealias SelfObject = ScoutedTeam
    
    typealias GeneralType = Team
    
    var ranker: GeneralRanker? {
        get {
            let rankers = LinkingObjects(fromType: GeneralRanker.self, property: "rankedTeams")
            return rankers.first
        }
    }
    
    let eventRankers = LinkingObjects(fromType: EventRanker.self, property: "rankedTeams")
    
    ///Cross Year Values
    dynamic var key = ""
    dynamic var notes = ""
    dynamic var programmingLanguage: String?
    dynamic var computerVisionCapability: String?
    let robotHeight = RealmOptional<Double>()
    let robotWeight = RealmOptional<Double>()
    let robotLength = RealmOptional<Double>()
    let robotWidth = RealmOptional<Double>()
    dynamic var frontImage: Data?
    dynamic var strategy: String?
    dynamic var canBanana = false
    let driverXP = RealmOptional<Double>()
    dynamic var driveTrain: String?
    
    ///DO  NOT USE, Deprecated
    dynamic var isInPickList = true {
        didSet {
            assertionFailure()
        }
    }
    
    ///Game Based Values
    dynamic var scaleCapability: String?
    dynamic var switchCapability: String?
    dynamic var vaultCapability: String?
    dynamic var climbCapability: String?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    //To connect to the general team
    dynamic var cache: GeneralType?
    
    override static func ignoredProperties() -> [String] {
        return ["cache"]
    }
}

@objcMembers class ScoutedMatch: Object, HasGeneralEquivalent {
    dynamic var key = ""
    let blueScore = RealmOptional<Int>()
    let blueRP = RealmOptional<Int>()
    let redScore = RealmOptional<Int>()
    let redRP = RealmOptional<Int>()
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    typealias SelfObject = ScoutedMatch
    typealias GeneralType = Match
    dynamic var cache: Match?
    override static func ignoredProperties() -> [String] {
        return ["cache"]
    }
}

@objcMembers class ScoutedMatchPerformance: Object, HasGeneralEquivalent {
    dynamic var key = ""
    let timeMarkers = LinkingObjects(fromType: TimeMarker.self, property: "scoutedMatchPerformance")
    
    //--- Maybe try to remove
    dynamic var defaultScoutID: String = "default"
//    let scoutIDs = List<String>()
    //---
    
    dynamic var climbStatus: String? = nil
    dynamic var climbAssistStatus: String? = nil
    
    dynamic var didCrossAutoLine: Bool = false
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    typealias SelfObject = ScoutedMatchPerformance
    typealias GeneralType = TeamMatchPerformance
    dynamic var cache: TeamMatchPerformance?
    override static func ignoredProperties() -> [String] {
        return ["cache"]
    }
    
    var hasBeenScouted: Bool {
        get {
            let scoutIDs = (self.scoutIDs ?? [])
            if scoutIDs.count >= 1 {
                return true
            } else {
                return false
            }
        }
    }
    
    ///TODO: Seems to be random and not very helpful
    var preferredScoutID: String {
        get {
            if self.defaultScoutID != "default" {
                return self.defaultScoutID
            } else if timeMarkers.count > 0 {
                for marker in timeMarkers {
                    return marker.scoutID
                }
                return "default"
            } else {
                return "default"
            }
        }
    }
    
    var scoutIDs: [String]? {
        get {
            var ids = [String]()
            for marker in timeMarkers {
                if !ids.contains(marker.scoutID) {
                    ids.append(marker.scoutID)
                }
            }
            
            return ids
        }
    }
    
    func timeMarkers(forScoutID scoutID: String) -> [TimeMarker] {
        return timeMarkers.filter {$0.scoutID == scoutID}
    }
}
