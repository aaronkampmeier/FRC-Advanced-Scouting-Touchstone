//
//  TeamMatchPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class TeamMatchPerformance: Object, HasScoutedEquivalent {
    dynamic var allianceColor = ""
    dynamic var allianceTeam = 0
    dynamic var key = ""
    
    dynamic var match: Match?
    
    dynamic var teamEventPerformance: TeamEventPerformance?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    typealias SelfObject = TeamMatchPerformance
    typealias LocalType = ScoutedMatchPerformance
    dynamic var cache: ScoutedMatchPerformance?
    override static func ignoredProperties() -> [String] {
        return ["cache"]
    }
    
    enum Alliance: String {
        case Red = "Red"
        case Blue = "Blue"
    }
    
    enum Slot: Int {
        case One = 1
        case Two = 2
        case Three = 3
    }
    
    var alliance: Alliance {
        get {
            return Alliance(rawValue: self.allianceColor)!
        }
    }
    
    var slot: Slot {
        get {
            return Slot(rawValue: self.allianceTeam)!
        }
    }
    
    var rankingPoints: Int? {
        switch allianceColor {
        case "Blue":
            return match?.scouted.blueRP.value
        case "Red":
            return match?.scouted.redRP.value
        default:
            assertionFailure()
            return -1
        }
    }
    
    var finalScore: Int? {
        switch allianceColor {
        case "Blue":
            return match?.scouted.blueScore.value
        case "Red":
            return match?.scouted.redScore.value
        default:
            assertionFailure()
            return -1
        }
    }
    
    var winningMargin: Int {
        let selfFinalScore = finalScore ?? 0
        switch allianceColor {
        case "Blue":
            return selfFinalScore - (match?.scouted.redScore.value ?? 0)
        case "Red":
            return selfFinalScore - (match?.scouted.blueScore.value ?? 0)
        default:
            assertionFailure()
            return -1
        }
    }
}

extension TeamMatchPerformance: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.TotalPoints:{
                    if let val = self.finalScore {
                        return StatValue.Integer(val)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TotalRankingPoints:{
                    if let val = self.rankingPoints {
                        return StatValue.Integer(val)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.ClimbingStatus: {
                    if self.scouted.hasBeenScouted {
                        return StatValue.initWithOptional(value: self.scouted.climbStatus)
                    } else {
                        return StatValue.NoValue
                    }
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case TotalPoints = "Total Points"
        case TotalRankingPoints = "Total Ranking Points"
        case TotalPointsFromFuel = "Total Fuel Points"
        case TotalGearsScored = "Total Gears Scored"
        case AverageFuelCycleTime = "Average Fuel Cycle Time"
        case AverageGearCycleTime = "Average Gear Cycle Time"
        case AverageAccuracy = "Average High Goal Accuracy"
        case ClimbingStatus = "Climbing Status"
        case Peg1Percentage = "Peg 1 Percentage"
        case Peg2Percentage = "Peg 2 Percentage"
        case Peg3Percentage = "Peg 3 Percentage"
        case TotalFloorGears = "Total Floor Gears"
        case AutoFuelScored = "Auto Fuel Scored"
        case AutoGearsScored = "Auto Gears Scored"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.TotalPoints, .TotalRankingPoints, .TotalPointsFromFuel, .AutoFuelScored, .TotalGearsScored, .TotalFloorGears, .AverageAccuracy, .AverageFuelCycleTime, .AverageGearCycleTime, .AutoGearsScored, .Peg1Percentage, .Peg2Percentage, .Peg3Percentage, .ClimbingStatus]
    }
}
