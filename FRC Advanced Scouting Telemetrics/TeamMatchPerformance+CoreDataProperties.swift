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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMatchPerformance> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var allianceColor: NSNumber?
    @NSManaged public var allianceTeam: NSNumber?
    @NSManaged public var key: String?
    @NSManaged public var match: Match?
    @NSManaged public var eventPerformances: TeamEventPerformance?

}
