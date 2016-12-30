//
//  LocalMatchPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalMatchPerformance: HasUniversalEquivalent {
    typealias UniversalType = TeamMatchPerformance
    typealias SelfObject = LocalMatchPerformance
    
    static func specificFR() -> NSFetchRequest<LocalMatchPerformance> {
        return NSFetchRequest<LocalMatchPerformance>(entityName: "LocalMatchPerformance")
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalMatchPerformance> {
        return NSFetchRequest<LocalMatchPerformance>(entityName: "LocalMatchPerformance");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "LocalMatchPerformance")
    }

    @NSManaged public var key: String?
    @NSManaged public var autonomousCycles: NSOrderedSet?
    @NSManaged public var timeMarkers: NSOrderedSet?

}

// MARK: Generated accessors for autonomousCycles
extension LocalMatchPerformance {

    @objc(insertObject:inAutonomousCyclesAtIndex:)
    @NSManaged public func insertIntoAutonomousCycles(_ value: AutonomousCycle, at idx: Int)

    @objc(removeObjectFromAutonomousCyclesAtIndex:)
    @NSManaged public func removeFromAutonomousCycles(at idx: Int)

    @objc(insertAutonomousCycles:atIndexes:)
    @NSManaged public func insertIntoAutonomousCycles(_ values: [AutonomousCycle], at indexes: NSIndexSet)

    @objc(removeAutonomousCyclesAtIndexes:)
    @NSManaged public func removeFromAutonomousCycles(at indexes: NSIndexSet)

    @objc(replaceObjectInAutonomousCyclesAtIndex:withObject:)
    @NSManaged public func replaceAutonomousCycles(at idx: Int, with value: AutonomousCycle)

    @objc(replaceAutonomousCyclesAtIndexes:withAutonomousCycles:)
    @NSManaged public func replaceAutonomousCycles(at indexes: NSIndexSet, with values: [AutonomousCycle])

    @objc(addAutonomousCyclesObject:)
    @NSManaged public func addToAutonomousCycles(_ value: AutonomousCycle)

    @objc(removeAutonomousCyclesObject:)
    @NSManaged public func removeFromAutonomousCycles(_ value: AutonomousCycle)

    @objc(addAutonomousCycles:)
    @NSManaged public func addToAutonomousCycles(_ values: NSOrderedSet)

    @objc(removeAutonomousCycles:)
    @NSManaged public func removeFromAutonomousCycles(_ values: NSOrderedSet)

}

// MARK: Generated accessors for timeMarkers
extension LocalMatchPerformance {

    @objc(insertObject:inTimeMarkersAtIndex:)
    @NSManaged public func insertIntoTimeMarkers(_ value: TimeMarker, at idx: Int)

    @objc(removeObjectFromTimeMarkersAtIndex:)
    @NSManaged public func removeFromTimeMarkers(at idx: Int)

    @objc(insertTimeMarkers:atIndexes:)
    @NSManaged public func insertIntoTimeMarkers(_ values: [TimeMarker], at indexes: NSIndexSet)

    @objc(removeTimeMarkersAtIndexes:)
    @NSManaged public func removeFromTimeMarkers(at indexes: NSIndexSet)

    @objc(replaceObjectInTimeMarkersAtIndex:withObject:)
    @NSManaged public func replaceTimeMarkers(at idx: Int, with value: TimeMarker)

    @objc(replaceTimeMarkersAtIndexes:withTimeMarkers:)
    @NSManaged public func replaceTimeMarkers(at indexes: NSIndexSet, with values: [TimeMarker])

    @objc(addTimeMarkersObject:)
    @NSManaged public func addToTimeMarkers(_ value: TimeMarker)

    @objc(removeTimeMarkersObject:)
    @NSManaged public func removeFromTimeMarkers(_ value: TimeMarker)

    @objc(addTimeMarkers:)
    @NSManaged public func addToTimeMarkers(_ values: NSOrderedSet)

    @objc(removeTimeMarkers:)
    @NSManaged public func removeFromTimeMarkers(_ values: NSOrderedSet)

}
