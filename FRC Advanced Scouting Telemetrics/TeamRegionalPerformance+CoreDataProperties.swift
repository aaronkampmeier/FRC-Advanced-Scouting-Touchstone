//
//  TeamRegionalPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TeamRegionalPerformance {

    @NSManaged var team: Team?
    @NSManaged var matchPerformances: NSSet?
    @NSManaged var regional: Regional?

}
