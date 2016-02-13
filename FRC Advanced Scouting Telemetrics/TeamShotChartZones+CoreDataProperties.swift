//
//  TeamShotChartZones+CoreDataProperties.swift
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

extension TeamShotChartZones {

    @NSManaged var succesfulShots: NSNumber?
    @NSManaged var missedShots: NSNumber?
    @NSManaged var zoneNumber: NSNumber?
    @NSManaged var shotChart: TeamShotChart?

}
