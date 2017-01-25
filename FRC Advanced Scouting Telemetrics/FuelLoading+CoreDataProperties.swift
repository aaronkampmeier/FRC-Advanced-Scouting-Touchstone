//
//  FuelLoading+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension FuelLoading {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FuelLoading> {
        return NSFetchRequest<FuelLoading>(entityName: "FuelLoading");
    }

    @NSManaged public var associatedFuelIncrease: NSNumber?
    @NSManaged public var location: String?
    @NSManaged public var time: NSNumber?
    @NSManaged public var isAutonomous: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
