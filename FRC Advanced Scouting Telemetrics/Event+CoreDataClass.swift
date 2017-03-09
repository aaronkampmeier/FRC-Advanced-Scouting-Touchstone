//
//  Event+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


open class Event: NSManagedObject {
    var allMatches: NSSet? {
        get {
            return self.matches
        }
        
        set {
            self.matches = newValue
        }
    }
}
