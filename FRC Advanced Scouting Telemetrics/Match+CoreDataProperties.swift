//
//  Match+CoreDataProperties.swift
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

extension Match {

    @NSManaged var blueCapturedTower: NSNumber?
    @NSManaged var blueFinalScore: NSNumber?
    @NSManaged var blueRankingPoints: NSNumber?
    @NSManaged var matchNumber: NSNumber?
    @NSManaged var redCapturedTower: NSNumber?
    @NSManaged var redFinalScore: NSNumber?
    @NSManaged var redRankingPoints: NSNumber?
    @NSManaged var time: NSDate?
    @NSManaged var blueDefenses: NSArray?
    @NSManaged var blueDefensesBreached: NSArray?
    @NSManaged var redDefenses: NSArray?
    @NSManaged var redDefensesBreached: NSArray?
    @NSManaged var regional: Regional?
    @NSManaged var teamPerformances: NSSet?

}
