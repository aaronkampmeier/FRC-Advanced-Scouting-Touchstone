//
//  Stat+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stat {

    @NSManaged var value: NSNumber?
    @NSManaged var team: Team?
    @NSManaged var statsBoard: NSManagedObject?
    @NSManaged var statType: NSManagedObject?

}
