//
//  LocalEvent+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalEvent: HasUniversalEquivalent {
    typealias UniversalType = Event
    typealias SelfObject = LocalEvent
    
    static func specificFR() -> NSFetchRequest<LocalEvent> {
        return NSFetchRequest<LocalEvent>(entityName: "LocalEvent")
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalEvent> {
        return NSFetchRequest<LocalEvent>(entityName: "LocalEvent");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "LocalEvent")
    }

    @NSManaged public var key: String?
    @NSManaged public var rankedTeams: NSOrderedSet?

}

// MARK: Generated accessors for rankedTeams
extension LocalEvent {

    @objc(addRankedTeamsObject:)
    @NSManaged public func addToRankedTeams(_ value: LocalTeam)

    @objc(removeRankedTeamsObject:)
    @NSManaged public func removeFromRankedTeams(_ value: LocalTeam)

    @objc(addRankedTeams:)
    @NSManaged public func addToRankedTeams(_ values: NSSet)

    @objc(removeRankedTeams:)
    @NSManaged public func removeFromRankedTeams(_ values: NSSet)

}
