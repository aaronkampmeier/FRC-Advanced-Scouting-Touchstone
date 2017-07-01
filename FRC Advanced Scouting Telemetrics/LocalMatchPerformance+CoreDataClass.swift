//
//  LocalMatchPerformance+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


open class LocalMatchPerformance: NSManagedObject {
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
    
    var hasBeenScouted: Bool {
        get {
            let scoutIDs = (self.scoutIDs ?? [])
            if scoutIDs.count >= 1 {
                return true
            } else {
                return false
            }
        }
    }
    
    var preferredScoutID: String {
        get {
            let timeMarkers = self.timeMarkers?.array as! [TimeMarker]
            if self.defaultScoutID != nil && self.defaultScoutID != "default" {
                return self.defaultScoutID!
            } else if timeMarkers.count > 0 {
                for marker in timeMarkers {
                    if let id = marker.scoutID {
                        return id
                    }
                }
                return "default"
            } else {
                return "default"
            }
        }
    }
    
    var scoutIDs: [String]? {
        get {
            let timeMarkers = self.timeMarkers?.array as! [TimeMarker]
            
            var ids = [String]()
            for marker in timeMarkers {
                if !ids.contains(marker.scoutID!) {
                    ids.append(marker.scoutID!)
                }
            }
            
            return ids
        }
    }
    
    func timeMarkers(forScoutID scoutID: String) -> [TimeMarker] {
        let timeMarkers = self.timeMarkers?.array as! [TimeMarker]
        return timeMarkers.filter {$0.scoutID == scoutID}
    }
    
    func defendings(forScoutID scoutID: String) -> [Defending] {
        let defendings = self.defendings?.allObjects as! [Defending]
        return defendings.filter {$0.scoutID == scoutID}
    }
    
    func fuelLoadings(forScoutID scoutID: String) -> [FuelLoading] {
        let fuelLoadings = self.fuelLoadings?.allObjects as! [FuelLoading]
        return fuelLoadings.filter {$0.scoutID == scoutID}
    }
    
    func fuelScorings(forScoutID scoutID: String) -> [FuelScoring] {
        let fuelScorings = self.fuelScorings?.allObjects as! [FuelScoring]
        return fuelScorings.filter {$0.scoutID == scoutID}
    }
    
    func gearLoadings(forScoutID scoutID: String) -> [GearLoading] {
        let gearLoadings = self.gearLoadings?.allObjects as! [GearLoading]
        return gearLoadings.filter {$0.scoutID == scoutID}
    }
    
    func gearMountings(forScoutID scoutID: String) -> [GearMounting] {
        let gearMountings = self.gearMountings?.allObjects as! [GearMounting]
        return gearMountings.filter {$0.scoutID == scoutID}
    }
}
