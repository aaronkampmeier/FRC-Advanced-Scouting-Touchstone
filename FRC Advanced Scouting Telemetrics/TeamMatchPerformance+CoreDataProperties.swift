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
    static let genericName = "MatchPerformance"
    typealias SelfObject = TeamMatchPerformance
    
    static func specificFR() -> NSFetchRequest<TeamMatchPerformance> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance")
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMatchPerformance> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var allianceColor: String
    @NSManaged public var allianceTeam: NSNumber?
    @NSManaged public var key: String?
    @NSManaged public var match: Match?
    @NSManaged public var eventPerformance: TeamEventPerformance?

}

extension TeamMatchPerformance: HasStats {
    var stats: [StatName:()->StatValue?] {
        get {
            return [
                StatName.TotalPoints:{self.finalScore},
                StatName.TotalRankingPoints:{self.rankingPoints}
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible {
        case TotalPoints = "Total Points"
        case TotalRankingPoints = "Total Ranking Points"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
}
