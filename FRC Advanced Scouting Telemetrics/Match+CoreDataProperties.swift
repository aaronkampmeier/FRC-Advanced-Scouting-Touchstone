//
//  Match+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension Match: HasLocalEquivalent {
    var localEntityName: String {
        get {
            return "LocalMatch"
        }
    }
    typealias SelfObject = Match
    typealias LocalType = LocalMatch
    
    static func specificFR() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match")
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Match> {
        return NSFetchRequest<Match>(entityName: "Match");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "Match")
    }

    @NSManaged public var key: String?
    @NSManaged public var matchNumber: NSNumber?
    @NSManaged public var time: NSDate?
    @NSManaged public var event: Event?
    @NSManaged public var teamPerformances: NSSet?
    @NSManaged public var transientLocal: LocalMatch?

}

// MARK: Generated accessors for teamPerformances
extension Match {

    @objc(addTeamPerformancesObject:)
    @NSManaged public func addToTeamPerformances(_ value: TeamMatchPerformance)

    @objc(removeTeamPerformancesObject:)
    @NSManaged public func removeFromTeamPerformances(_ value: TeamMatchPerformance)

    @objc(addTeamPerformances:)
    @NSManaged public func addToTeamPerformances(_ values: NSSet)

    @objc(removeTeamPerformances:)
    @NSManaged public func removeFromTeamPerformances(_ values: NSSet)

}
