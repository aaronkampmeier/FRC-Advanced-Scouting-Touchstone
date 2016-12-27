//
//  LocalMatch+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension LocalMatch: HasUniversalEquivalent {
    static let genericName = "Match"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalMatch> {
        return NSFetchRequest<LocalMatch>(entityName: "LocalMatch");
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "LocalMatch")
    }

    @NSManaged public var blueFinalScore: NSNumber?
    @NSManaged public var blueRankingPoints: NSNumber?
    @NSManaged public var key: String?
    @NSManaged public var redFinalScore: NSNumber?
    @NSManaged public var redRankingPoints: NSNumber?

}
