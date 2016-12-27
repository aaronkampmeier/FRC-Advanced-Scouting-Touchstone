//
//  TimeMarker+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension TimeMarker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeMarker> {
        return NSFetchRequest<TimeMarker>(entityName: "TimeMarker");
    }

    @NSManaged public var event: NSNumber?
    @NSManaged public var time: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
