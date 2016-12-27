//
//  AutonomousCycle+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension AutonomousCycle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutonomousCycle> {
        return NSFetchRequest<AutonomousCycle>(entityName: "AutonomousCycle");
    }

    @NSManaged public var moved: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
