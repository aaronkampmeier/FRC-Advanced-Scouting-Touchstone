//
//  LocalTeam+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/4/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalTeam: HasUniversalEquivalent {

    typealias UniversalType = Team
    typealias SelfObject = LocalTeam
    var universalEntityName: String {
        get {
            return "Team"
        }
    }
    
    static func specificFR() -> NSFetchRequest<LocalTeam> {
        return NSFetchRequest<LocalTeam>(entityName: "LocalTeam")
    }
    
    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<LocalTeam>(entityName: "LocalTeam") as! NSFetchRequest<NSFetchRequestResult>;
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var canBanana: NSNumber?
    @NSManaged public var climberCapability: String?
    @NSManaged public var driverXP: NSNumber?
    @NSManaged public var frontImage: Data?
    @NSManaged public var gearsCapability: String?
    @NSManaged public var highGoalCapability: String?
    @NSManaged public var key: String?
    @NSManaged public var lowGoalCapability: String?
    @NSManaged public var notes: String?
    @NSManaged public var programmingLanguage: String?
    @NSManaged public var robotHeight: NSNumber?
    @NSManaged public var robotWeight: NSNumber?
    @NSManaged public var sideImage: Data?
    @NSManaged public var tankSize: NSNumber?
    @NSManaged public var visionTrackingCapability: String?
    @NSManaged public var autoPegs: [Int]?
    @NSManaged public var autoDoesLoadFuel: NSNumber?
    @NSManaged public var autoDoesShootPreloaded: NSNumber?
    @NSManaged public var autoDoesShootMoreFuel: NSNumber?
    @NSManaged public var localEvents: NSSet?
    @NSManaged public var ranker: LocalTeamRanking?
    @NSManaged public var transientUniversal: Team?

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
