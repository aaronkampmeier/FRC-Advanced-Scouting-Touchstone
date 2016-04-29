//
//  Team+CoreDataProperties.swift
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

extension Team {

    @NSManaged var climber: NSNumber?
    @NSManaged var driverExp: NSNumber?
    @NSManaged var driveTrain: String?
    @NSManaged var frontImage: NSData?
    @NSManaged var height: NSNumber?
    @NSManaged var highGoal: NSNumber?
    @NSManaged var lowGoal: NSNumber?
    @NSManaged var notes: String?
    @NSManaged var robotWeight: NSNumber?
    @NSManaged var sideImage: NSData?
    @NSManaged var teamNumber: String?
    @NSManaged var visionTrackingRating: NSNumber?
    @NSManaged var autonomousDefensesAbleToCross: NSArray?
    @NSManaged var autonomousDefensesAbleToShoot: NSArray?
    @NSManaged var defensesAbleToCross: NSArray?
    @NSManaged var draftBoard: DraftBoard?
    @NSManaged var regionalPerformances: NSSet?

}
