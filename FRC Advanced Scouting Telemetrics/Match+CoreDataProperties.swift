//
//  Match+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/9/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Match {

    @NSManaged var matchNumber: NSNumber?
    @NSManaged var b1: Team?
    @NSManaged var b2: Team?
    @NSManaged var b3: Team?
    @NSManaged var r1: Team?
    @NSManaged var r2: Team?
    @NSManaged var r3: Team?
    @NSManaged var participatingTeams: NSSet?
    @NSManaged var matchBoard: NSManagedObject?
    @NSManaged var time: NSDate?

}
