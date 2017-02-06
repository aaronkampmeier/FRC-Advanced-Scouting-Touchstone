//
//  TeamMatchPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension TeamMatchPerformance: HasLocalEquivalent {
    var localEntityName: String {
        get {
            return "LocalMatchPerformance"
        }
    }
    typealias SelfObject = TeamMatchPerformance
    typealias LocalType = LocalMatchPerformance
    
    static func specificFR() -> NSFetchRequest<TeamMatchPerformance> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance")
    }

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance") as! NSFetchRequest<NSFetchRequestResult>;
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var allianceColor: String
    @NSManaged public var allianceTeam: NSNumber?
    @NSManaged public var key: String?
    @NSManaged public var match: Match?
    @NSManaged public var eventPerformance: TeamEventPerformance?
    @NSManaged public var transientLocal: LocalMatchPerformance?

}

extension TeamMatchPerformance: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.TotalPoints:{
                    if let val = self.finalScore {
                        return StatValue.Double(val)
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
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case TotalPoints = "Total Points"
        case TotalRankingPoints = "Total Ranking Points"
        
        case TotalPointsFromFuel = "Total Fuel Points"
        case TotalGearsScored = "Total Gears Scored"
        case AverageCycleTime = "Average Cycle Time"
        case OverallAccuracy = "Overall Accuracy"
        case ClimbingStatus = "Climbing Status"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.TotalPoints, .TotalRankingPoints]
    }
}
