//
//  AutonomousCycle+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 4/28/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension AutonomousCycle {

    @NSManaged var crossedDefense: NSNumber?
    @NSManaged var moved: NSNumber?
    @NSManaged var reachedDefense: NSNumber?
    @NSManaged var returned: NSNumber?
    @NSManaged var shot: NSNumber?
    @NSManaged var defenseReached: String?
    @NSManaged var matchPerformance: TeamMatchPerformance?

}
