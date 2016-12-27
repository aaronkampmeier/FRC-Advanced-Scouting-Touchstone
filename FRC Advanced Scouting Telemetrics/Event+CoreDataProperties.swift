//
//  Event+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension Event: HasLocalEquivalent {
    static let genericName = "Event"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "Event")
    }

    @NSManaged public var code: String?
    @NSManaged public var eventType: NSNumber?
    @NSManaged public var eventTypeString: String?
    @NSManaged public var key: String?
    @NSManaged public var name: String?
    @NSManaged public var year: NSNumber?
    @NSManaged public var matches: NSSet?
    @NSManaged public var teamEventPerformances: NSSet?
	

}

// MARK: Generated accessors for matches
extension Event {

    @objc(addMatchesObject:)
    @NSManaged public func addToMatches(_ value: Match)

    @objc(removeMatchesObject:)
    @NSManaged public func removeFromMatches(_ value: Match)

    @objc(addMatches:)
    @NSManaged public func addToMatches(_ values: NSSet)

    @objc(removeMatches:)
    @NSManaged public func removeFromMatches(_ values: NSSet)

}

// MARK: Generated accessors for teamEventPerformances
extension Event {

    @objc(insertObject:inTeamEventPerformancesAtIndex:)
    @NSManaged public func insertIntoTeamEventPerformances(_ value: TeamEventPerformance, at idx: Int)

    @objc(removeObjectFromTeamEventPerformancesAtIndex:)
    @NSManaged public func removeFromTeamEventPerformances(at idx: Int)

    @objc(insertTeamEventPerformances:atIndexes:)
    @NSManaged public func insertIntoTeamEventPerformances(_ values: [TeamEventPerformance], at indexes: NSIndexSet)

    @objc(removeTeamEventPerformancesAtIndexes:)
    @NSManaged public func removeFromTeamEventPerformances(at indexes: NSIndexSet)

    @objc(replaceObjectInTeamEventPerformancesAtIndex:withObject:)
    @NSManaged public func replaceTeamEventPerformances(at idx: Int, with value: TeamEventPerformance)

    @objc(replaceTeamEventPerformancesAtIndexes:withTeamEventPerformances:)
    @NSManaged public func replaceTeamEventPerformances(at indexes: NSIndexSet, with values: [TeamEventPerformance])

    @objc(addTeamEventPerformancesObject:)
    @NSManaged public func addToTeamEventPerformances(_ value: TeamEventPerformance)

    @objc(removeTeamEventPerformancesObject:)
    @NSManaged public func removeFromTeamEventPerformances(_ value: TeamEventPerformance)

    @objc(addTeamEventPerformances:)
    @NSManaged public func addToTeamEventPerformances(_ values: NSOrderedSet)

    @objc(removeTeamEventPerformances:)
    @NSManaged public func removeFromTeamEventPerformances(_ values: NSOrderedSet)

}
