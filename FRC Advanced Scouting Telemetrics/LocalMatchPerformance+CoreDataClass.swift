//
//  LocalMatchPerformance+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


public class LocalMatchPerformance: NSManagedObject {
    enum RopeClimbSuccess: String, CustomStringConvertible {
        case Yes
        case Somewhat
        case No
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
}
