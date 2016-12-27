//
//  LocalTeam+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalTeam: HasUniversalEquivalent {
    static let genericName = "Team"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalTeam> {
        return NSFetchRequest<LocalTeam>(entityName: "LocalTeam");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var frontImage: NSData?
    @NSManaged public var key: String?
    @NSManaged public var notes: String?
    @NSManaged public var robotHeight: NSNumber?
    @NSManaged public var robotWeight: NSNumber?
    @NSManaged public var sideImage: NSData?
    @NSManaged public var localEvents: NSSet?
    @NSManaged public var ranker: LocalTeamRanking?

}

// MARK: Generated accessors for localEvents
extension LocalTeam {

    @objc(addLocalEventsObject:)
    @NSManaged public func addToLocalEvents(_ value: LocalEvent)

    @objc(removeLocalEventsObject:)
    @NSManaged public func removeFromLocalEvents(_ value: LocalEvent)

    @objc(addLocalEvents:)
    @NSManaged public func addToLocalEvents(_ values: NSSet)

    @objc(removeLocalEvents:)
    @NSManaged public func removeFromLocalEvents(_ values: NSSet)

}
