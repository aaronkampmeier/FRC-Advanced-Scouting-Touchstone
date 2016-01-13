//
//  Team+CoreDataProperties.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Team {

    @NSManaged var teamNumber: String?
    @NSManaged var driverExp: Double
    @NSManaged var robotWeight: Double

}
