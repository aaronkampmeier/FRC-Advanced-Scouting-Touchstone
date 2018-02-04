//
//  Team+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Team: Object, HasScoutedEquivalent {
    dynamic var key = ""
    dynamic var location: String?
    dynamic var name = ""
    dynamic var nickname = ""
    dynamic var rookieYear = 0
    dynamic var teamNumber = 0
    dynamic var website: String?
    
    let eventPerformances = LinkingObjects(fromType: TeamEventPerformance.self, property: "team")
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    typealias SelfObject = Team
    typealias LocalType = ScoutedTeam
    @objc dynamic var cache: ScoutedTeam?
    override static func ignoredProperties() -> [String] {
        return ["cache"]
    }
}

extension Team: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.LocalRank: {
                    let teamRanking = RealmController.realmController.teamRanking()
                    if let index = teamRanking.index(of: self) {
                        return StatValue.Integer(index + 1)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TeamNumber: {
                    return StatValue.Integer(self.teamNumber)
                },
                StatName.RookieYear: {
                    return StatValue.Integer(self.rookieYear)
                },
                StatName.RobotHeight: {
                    if let doubleValue = self.scouted.robotHeight.value {
                        return StatValue.Double(doubleValue)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.RobotWeight: {
                    if let doubleVal = self.scouted.robotWeight.value {
                        return StatValue.Double(doubleVal)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.DriveTrain: {
                    StatValue.initWithOptional(value: self.scouted.driveTrain)
                },
                StatName.GamePlayStrategy: {
                    StatValue.initWithOptional(value: self.scouted.strategy)
                },
                StatName.DriverXP: {
                    StatValue.initWithOptional(value: self.scouted.driverXP.value)
                },
                StatName.ProgrammingLanguage: {
                    StatValue.initWithOptional(value: self.scouted.programmingLanguage)
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case LocalRank = "Local Rank"
        case TeamNumber = "Team Number"
        case RookieYear = "Rookie Year"
        case RobotHeight = "Robot Height"
        case RobotWeight = "Robot Weight"
        case DriveTrain = "Drive Train"
        case ClimberCapability = "Climber Capability"
        case GamePlayStrategy = "Game Play Strategy"
        
        case DriverXP = "Driver XP"
        case VisionTrackingCapability = "Computer Vision Capability"
        case ProgrammingLanguage = "Programming Language"
        
        //Game Specific
        
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.LocalRank, .TeamNumber, .RookieYear, .RobotHeight, .RobotWeight, .GamePlayStrategy, .DriveTrain, .ClimberCapability]
        
        static let teamDetailValues: [StatName] = [.RobotHeight, .RobotWeight, .DriverXP, .GamePlayStrategy, .DriveTrain,  .VisionTrackingCapability, .ProgrammingLanguage, .ClimberCapability]
    }
}

