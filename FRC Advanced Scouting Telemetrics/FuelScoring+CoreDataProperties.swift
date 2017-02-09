//
//  FuelScoring+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension FuelScoring {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<FuelScoring>(entityName: "FuelScoring") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var accuracy: NSNumber?
    @NSManaged public var amountShot: NSNumber?
    @NSManaged public var goal: String?
    @NSManaged public var time: NSNumber?
    @NSManaged public var xLocation: NSNumber?
    @NSManaged public var yLocation: NSNumber?
    @NSManaged public var isAutonomous: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
