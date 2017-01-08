//
//  LocalEvent+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalEvent {
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

    @objc(insertObject:inRankedTeamsAtIndex:)
    @NSManaged public func insertIntoRankedTeams(_ value: LocalTeam, at idx: Int)

    @objc(removeObjectFromRankedTeamsAtIndex:)
    @NSManaged public func removeFromRankedTeams(at idx: Int)

    @objc(insertRankedTeams:atIndexes:)
    @NSManaged public func insertIntoRankedTeams(_ values: [LocalTeam], at indexes: NSIndexSet)

    @objc(removeRankedTeamsAtIndexes:)
    @NSManaged public func removeFromRankedTeams(at indexes: NSIndexSet)

    @objc(replaceObjectInRankedTeamsAtIndex:withObject:)
    @NSManaged public func replaceRankedTeams(at idx: Int, with value: LocalTeam)

    @objc(replaceRankedTeamsAtIndexes:withRankedTeams:)
    @NSManaged public func replaceRankedTeams(at indexes: NSIndexSet, with values: [LocalTeam])

    @objc(addRankedTeamsObject:)
    @NSManaged public func addToRankedTeams(_ value: LocalTeam)

    @objc(removeRankedTeamsObject:)
    @NSManaged public func removeFromRankedTeams(_ value: LocalTeam)

    @objc(addRankedTeams:)
    @NSManaged public func addToRankedTeams(_ values: NSOrderedSet)

    @objc(removeRankedTeams:)
    @NSManaged public func removeFromRankedTeams(_ values: NSOrderedSet)

}
