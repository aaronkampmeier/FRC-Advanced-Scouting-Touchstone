//
//  TeamMatchPerformance+CoreDataProperties.swift
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

extension TeamMatchPerformance {

    @NSManaged var allianceColor: NSNumber?
    @NSManaged var allianceTeam: NSNumber?
    @NSManaged var regionalPerformance: NSManagedObject?
    @NSManaged var match: Match?
    @NSManaged var autonomousCycles: NSSet?
    @NSManaged var timeMarkers: NSOrderedSet?
    @NSManaged var defenseBlocks: Shot?
    @NSManaged var offenseShots: Shot?
    @NSManaged var defenseCrossTimes: NSSet?

}
