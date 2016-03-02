//
//  Team+CoreDataProperties.swift
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

extension Team {

    @NSManaged var driverExp: NSNumber?
    @NSManaged var frontImage: NSData?
    @NSManaged var robotWeight: NSNumber?
    @NSManaged var sideImage: NSData?
    @NSManaged var teamNumber: String?
	@NSManaged var defensesAbleToCross: NSSet?
    @NSManaged var draftBoard: DraftBoard?
    @NSManaged var stats: NSSet?
    @NSManaged var regionalPerformances: NSSet?

}
