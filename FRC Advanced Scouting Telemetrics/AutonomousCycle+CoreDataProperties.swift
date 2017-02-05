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

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<AutonomousCycle>(entityName: "AutonomousCycle") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var moved: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
