//
//  Event+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

//@objcMembers class Event: Object {
//    dynamic var code = ""
//    dynamic var eventType = 0
//    dynamic var eventTypeString = ""
//    dynamic var key = ""
//    dynamic var location: String?
//    dynamic var name = ""
//    dynamic var year = 0
//
//    dynamic var lastReloaded: Date?
//
//    let teamEventPerformances = LinkingObjects(fromType: TeamEventPerformance.self, property: "event")
//    let matches = LinkingObjects(fromType: Match.self, property: "event")
//
//    override static func primaryKey() -> String {
//        return "key"
//    }
//}

extension Event: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.NumberOfTeams:{
                    return StatValue.Integer(self.teamEventPerformances.count)
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case NumberOfTeams = "Number Of Teams"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.NumberOfTeams]
    }
}
