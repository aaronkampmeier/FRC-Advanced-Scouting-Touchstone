//
//  Defending+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/22/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension Defending {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Defending> {
        return NSFetchRequest<Defending>(entityName: "Defending");
    }

    @NSManaged public var duration: NSNumber?
    @NSManaged public var successful: NSNumber?
    @NSManaged public var time: NSNumber?
    @NSManaged public var defendingTeam: LocalMatchPerformance?
    @NSManaged public var offendingTeam: LocalMatchPerformance?

}
