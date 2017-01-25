//
//  GearLoading+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension GearLoading {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GearLoading> {
        return NSFetchRequest<GearLoading>(entityName: "GearLoading");
    }

    @NSManaged public var location: String?
    @NSManaged public var time: NSNumber?
    @NSManaged public var isAutonomous: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
