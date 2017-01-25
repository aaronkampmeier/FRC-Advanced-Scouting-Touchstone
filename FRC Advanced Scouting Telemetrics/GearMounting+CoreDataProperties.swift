//
//  GearMounting+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/24/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension GearMounting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GearMounting> {
        return NSFetchRequest<GearMounting>(entityName: "GearMounting");
    }

    @NSManaged public var pegNumber: NSNumber?
    @NSManaged public var time: NSNumber?
    @NSManaged public var isAutonomous: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
