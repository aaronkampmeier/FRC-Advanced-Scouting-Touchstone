//
//  Match+CoreDataProperties.swift
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

extension Match {

    @NSManaged var matchNumber: NSNumber?
    @NSManaged var time: NSDate?
	@NSManaged var blueCapturedTower: NSNumber?
	@NSManaged var blueFinalScore: NSNumber?
	@NSManaged var redCapturedTower: NSNumber?
	@NSManaged var redFinalScore: NSNumber?
    @NSManaged var regional: Regional?
    @NSManaged var teamPerformances: NSSet?
    @NSManaged var redDefenses: NSSet?
	@NSManaged var blueDefenses: NSSet?
	@NSManaged var redDefensesBreached: NSSet?
	@NSManaged var blueDefensesBreached: NSSet?

}
