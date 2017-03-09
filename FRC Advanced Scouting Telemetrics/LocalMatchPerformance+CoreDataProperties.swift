//
//  LocalMatchPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalMatchPerformance: HasUniversalEquivalent {

    var universalEntityName: String {
        get {
            return "TeamMatchPerformance"
        }
    }
    typealias UniversalType = TeamMatchPerformance
    typealias SelfObject = LocalMatchPerformance
    
    static func specificFR() -> NSFetchRequest<LocalMatchPerformance> {
        return NSFetchRequest<LocalMatchPerformance>(entityName: "LocalMatchPerformance")
    }
    
    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<LocalMatchPerformance>(entityName: "LocalMatchPerformance") as! NSFetchRequest<NSFetchRequestResult>;
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "LocalMatchPerformance")
    }

    @NSManaged public var defaultScoutID: String?
    @NSManaged public var key: String?
    @NSManaged public var ropeClimbStatus: String?
    @NSManaged public var defendings: NSSet?
    @NSManaged public var fuelLoadings: NSSet?
    @NSManaged public var fuelScorings: NSSet?
    @NSManaged public var gearLoadings: NSSet?
    @NSManaged public var gearMountings: NSSet?
    @NSManaged public var offendings: NSSet?
    @NSManaged public var timeMarkers: NSOrderedSet?
    @NSManaged public var transientUniversal: TeamMatchPerformance?

}

// MARK: Generated accessors for defendings
extension LocalMatchPerformance {

    @objc(addDefendingsObject:)
    @NSManaged public func addToDefendings(_ value: Defending)

    @objc(removeDefendingsObject:)
    @NSManaged public func removeFromDefendings(_ value: Defending)

    @objc(addDefendings:)
    @NSManaged public func addToDefendings(_ values: NSSet)

    @objc(removeDefendings:)
    @NSManaged public func removeFromDefendings(_ values: NSSet)

}

// MARK: Generated accessors for fuelLoadings
extension LocalMatchPerformance {

    @objc(addFuelLoadingsObject:)
    @NSManaged public func addToFuelLoadings(_ value: FuelLoading)

    @objc(removeFuelLoadingsObject:)
    @NSManaged public func removeFromFuelLoadings(_ value: FuelLoading)

    @objc(addFuelLoadings:)
    @NSManaged public func addToFuelLoadings(_ values: NSSet)

    @objc(removeFuelLoadings:)
    @NSManaged public func removeFromFuelLoadings(_ values: NSSet)

}

// MARK: Generated accessors for fuelScorings
extension LocalMatchPerformance {

    @objc(addFuelScoringsObject:)
    @NSManaged public func addToFuelScorings(_ value: FuelScoring)

    @objc(removeFuelScoringsObject:)
    @NSManaged public func removeFromFuelScorings(_ value: FuelScoring)

    @objc(addFuelScorings:)
    @NSManaged public func addToFuelScorings(_ values: NSSet)

    @objc(removeFuelScorings:)
    @NSManaged public func removeFromFuelScorings(_ values: NSSet)

}

// MARK: Generated accessors for gearLoadings
extension LocalMatchPerformance {

    @objc(addGearLoadingsObject:)
    @NSManaged public func addToGearLoadings(_ value: GearLoading)

    @objc(removeGearLoadingsObject:)
    @NSManaged public func removeFromGearLoadings(_ value: GearLoading)

    @objc(addGearLoadings:)
    @NSManaged public func addToGearLoadings(_ values: NSSet)

    @objc(removeGearLoadings:)
    @NSManaged public func removeFromGearLoadings(_ values: NSSet)

}

// MARK: Generated accessors for gearMountings
extension LocalMatchPerformance {

    @objc(addGearMountingsObject:)
    @NSManaged public func addToGearMountings(_ value: GearMounting)

    @objc(removeGearMountingsObject:)
    @NSManaged public func removeFromGearMountings(_ value: GearMounting)

    @objc(addGearMountings:)
    @NSManaged public func addToGearMountings(_ values: NSSet)

    @objc(removeGearMountings:)
    @NSManaged public func removeFromGearMountings(_ values: NSSet)

}

// MARK: Generated accessors for offendings
extension LocalMatchPerformance {

    @objc(addOffendingsObject:)
    @NSManaged public func addToOffendings(_ value: Defending)

    @objc(removeOffendingsObject:)
    @NSManaged public func removeFromOffendings(_ value: Defending)

    @objc(addOffendings:)
    @NSManaged public func addToOffendings(_ values: NSSet)

    @objc(removeOffendings:)
    @NSManaged public func removeFromOffendings(_ values: NSSet)

}

// MARK: Generated accessors for timeMarkers
extension LocalMatchPerformance {

    @objc(insertObject:inTimeMarkersAtIndex:)
    @NSManaged public func insertIntoTimeMarkers(_ value: TimeMarker, at idx: Int)

    @objc(removeObjectFromTimeMarkersAtIndex:)
    @NSManaged public func removeFromTimeMarkers(at idx: Int)

    @objc(insertTimeMarkers:atIndexes:)
    @NSManaged public func insertIntoTimeMarkers(_ values: [TimeMarker], at indexes: IndexSet)

    @objc(removeTimeMarkersAtIndexes:)
    @NSManaged public func removeFromTimeMarkers(at indexes: IndexSet)

    @objc(replaceObjectInTimeMarkersAtIndex:withObject:)
    @NSManaged public func replaceTimeMarkers(at idx: Int, with value: TimeMarker)

    @objc(replaceTimeMarkersAtIndexes:withTimeMarkers:)
    @NSManaged public func replaceTimeMarkers(at indexes: IndexSet, with values: [TimeMarker])

    @objc(addTimeMarkersObject:)
    @NSManaged public func addToTimeMarkers(_ value: TimeMarker)

    @objc(removeTimeMarkersObject:)
    @NSManaged public func removeFromTimeMarkers(_ value: TimeMarker)

    @objc(addTimeMarkers:)
    @NSManaged public func addToTimeMarkers(_ values: NSOrderedSet)

    @objc(removeTimeMarkers:)
    @NSManaged public func removeFromTimeMarkers(_ values: NSOrderedSet)

}
