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

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<Defending>(entityName: "Defending") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var scoutID: String?
    @NSManaged public var duration: NSNumber?
    @NSManaged public var successful: String?
    @NSManaged public var time: NSNumber?
    @NSManaged public var type: String?
    @NSManaged public var defendingTeam: LocalMatchPerformance?
    @NSManaged public var offendingTeam: LocalMatchPerformance?

}
