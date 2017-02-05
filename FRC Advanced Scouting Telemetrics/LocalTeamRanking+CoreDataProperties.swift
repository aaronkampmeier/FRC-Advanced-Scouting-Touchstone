//
//  LocalTeamRanking+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalTeamRanking {

    @nonobjc open class func fetchRequest() -> NSFetchRequest<LocalTeamRanking> {
        return NSFetchRequest<LocalTeamRanking>(entityName: "LocalTeamRanking")
    }

    @NSManaged public var localTeams: NSOrderedSet?

}

// MARK: Generated accessors for localTeams
extension LocalTeamRanking {

    @objc(insertObject:inLocalTeamsAtIndex:)
    @NSManaged public func insertIntoLocalTeams(_ value: LocalTeam, at idx: Int)

    @objc(removeObjectFromLocalTeamsAtIndex:)
    @NSManaged public func removeFromLocalTeams(at idx: Int)

    @objc(insertLocalTeams:atIndexes:)
    @NSManaged public func insertIntoLocalTeams(_ values: [LocalTeam], at indexes: IndexSet)

    @objc(removeLocalTeamsAtIndexes:)
    @NSManaged public func removeFromLocalTeams(at indexes: IndexSet)

    @objc(replaceObjectInLocalTeamsAtIndex:withObject:)
    @NSManaged public func replaceLocalTeams(at idx: Int, with value: LocalTeam)

    @objc(replaceLocalTeamsAtIndexes:withLocalTeams:)
    @NSManaged public func replaceLocalTeams(at indexes: IndexSet, with values: [LocalTeam])

    @objc(addLocalTeamsObject:)
    @NSManaged public func addToLocalTeams(_ value: LocalTeam)

    @objc(removeLocalTeamsObject:)
    @NSManaged public func removeFromLocalTeams(_ value: LocalTeam)

    @objc(addLocalTeams:)
    @NSManaged public func addToLocalTeams(_ values: NSOrderedSet)

    @objc(removeLocalTeams:)
    @NSManaged public func removeFromLocalTeams(_ values: NSOrderedSet)

}
