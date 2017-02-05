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

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<TimeMarker>(entityName: "TimeMarker") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var event: String?
    @NSManaged public var time: NSNumber?
    @NSManaged public var localMatchPerformance: LocalMatchPerformance?

}
