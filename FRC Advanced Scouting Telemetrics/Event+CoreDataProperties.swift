//
//  Event+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension Event: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.NumberOfTeams:{
                    if let val = self.teamEventPerformances?.count {
                        return StatValue.Integer(val)
                    } else {
                        return StatValue.NoValue
                    }
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case NumberOfTeams = "Number Of Teams"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.NumberOfTeams]
    }
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
    @NSManaged public func insertIntoTeamEventPerformances(_ values: [TeamEventPerformance], at indexes: IndexSet)

    @objc(removeTeamEventPerformancesAtIndexes:)
    @NSManaged public func removeFromTeamEventPerformances(at indexes: IndexSet)

    @objc(replaceObjectInTeamEventPerformancesAtIndex:withObject:)
    @NSManaged public func replaceTeamEventPerformances(at idx: Int, with value: TeamEventPerformance)

    @objc(replaceTeamEventPerformancesAtIndexes:withTeamEventPerformances:)
    @NSManaged public func replaceTeamEventPerformances(at indexes: IndexSet, with values: [TeamEventPerformance])

    @objc(addTeamEventPerformancesObject:)
    @NSManaged public func addToTeamEventPerformances(_ value: TeamEventPerformance)

    @objc(removeTeamEventPerformancesObject:)
    @NSManaged public func removeFromTeamEventPerformances(_ value: TeamEventPerformance)

    @objc(addTeamEventPerformances:)
    @NSManaged public func addToTeamEventPerformances(_ values: NSOrderedSet)

    @objc(removeTeamEventPerformances:)
    @NSManaged public func removeFromTeamEventPerformances(_ values: NSOrderedSet)

}
