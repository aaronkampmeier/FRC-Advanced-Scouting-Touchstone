//
//  Team+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension Team: HasLocalEquivalent {
    var localEntityName: String {
        get {
            return "LocalTeam"
        }
    }
    typealias SelfObject = Team
    typealias LocalType = LocalTeam
    
    static func specificFR() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "Team")
    }

    @NSManaged public var key: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var nickname: String?
    @NSManaged public var rookieYear: NSNumber?
    @NSManaged public var teamNumber: String?
    @NSManaged public var website: String?
    @NSManaged public var eventPerformances: NSSet?
    @NSManaged public var transientLocal: LocalTeam?

}

extension Team: HasStats {
    var stats: [StatName:()->StatValue?] {
        get {
            return [
                StatName.TeamNumber: {Int(self.teamNumber!)!},
                StatName.RookieYear: {self.rookieYear?.intValue},
                StatName.RobotHeight: {self.local.robotHeight?.doubleValue},
                StatName.RobotWeight: {self.local.robotWeight?.doubleValue}
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible {
        case TeamNumber = "Team Number"
        case RookieYear = "Rookie Year"
        case RobotHeight = "Robot Height"
        case RobotWeight = "Robot Weight"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
}

// MARK: Generated accessors for eventPerformances
extension Team {

    @objc(addEventPerformancesObject:)
    @NSManaged public func addToEventPerformances(_ value: TeamEventPerformance)

    @objc(removeEventPerformancesObject:)
    @NSManaged public func removeFromEventPerformances(_ value: TeamEventPerformance)

    @objc(addEventPerformances:)
    @NSManaged public func addToEventPerformances(_ values: NSSet)

    @objc(removeEventPerformances:)
    @NSManaged public func removeFromEventPerformances(_ values: NSSet)

}
