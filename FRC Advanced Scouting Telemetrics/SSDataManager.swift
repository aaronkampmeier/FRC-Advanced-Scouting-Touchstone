//
//  SSDataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/21/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
import Crashlytics
import UIKit

///A data manager that tracks a team participating in a match. It is a singleton so when the stands scouting vc first initializes it, it saves itself and all the other stands scouting vcs use the same object.
class SSDataManager {
    let managedContext = DataManager.managedContext
    let scoutID: String
    
    let scoutedTeam: Team
    let scoutedMatch: Match
    let scoutedMatchPerformance: TeamMatchPerformance
    let stopwatch: Stopwatch //A place for the stands scouting view controller to put the stopwatch so that other vcs can access it while it is running
    
    var startingPosition: StartingPosition!
    var isAutonomous: Bool = true {
        didSet {
            if !isAutonomous {
                saveTimeMarker(event: .EndedAutonomous, atTime: stopwatch.elapsedTime)
            }
        }
    }
    
    var preloadedFuel: Double = 0.0
    var preloadedGear = false
    
    fileprivate weak static var mostRecentSSDataManager: SSDataManager?
    class func currentSSDataManager() -> SSDataManager? {
        return mostRecentSSDataManager
    }
    
    init(teamBeingScouted: Team, matchBeingScouted: Match, stopwatch: Stopwatch) {
        try? managedContext.save()
        managedContext.rollback()
        
        self.scoutID = UUID().uuidString
        
        self.stopwatch = stopwatch
        
        scoutedTeam = teamBeingScouted
        scoutedMatch = matchBeingScouted
        
        //Get the match performance that we are scouting
        var teamMatchPerformance: TeamMatchPerformance?
        for matchPerformance in scoutedMatch.teamPerformances?.allObjects as! [TeamMatchPerformance] {
            if matchPerformance.eventPerformance!.team == scoutedTeam {
                teamMatchPerformance = matchPerformance
            }
        }
        
        if let matchPerformance = teamMatchPerformance {
            scoutedMatchPerformance = matchPerformance
        } else {
            Crashlytics.sharedInstance().recordCustomExceptionName("Stands Scouting Team Match Performance Does Not Exist", reason: nil, frameArray: [])
            assertionFailure()
            exit(EXIT_FAILURE)
        }
        
        scoutedMatchPerformance.local.defaultScoutID = scoutID
        
        SSDataManager.mostRecentSSDataManager = self
    }
    
    func save() -> Bool {
        do {
            try managedContext.save()
            return true
        } catch {
            CLSNSLogv("Unable to save Stands Scouting data", getVaList([]))
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: nil)
            return false
        }
    }
    
    func rollback() {
        managedContext.rollback()
    }
    
    func saveTimeMarker(event: TimeMarkerEvent, atTime time: TimeInterval) {
        let timeMarker = TimeMarker(entity: NSEntityDescription.entity(forEntityName: "TimeMarker", in: managedContext)!, insertInto: managedContext)
        
        timeMarker.localMatchPerformance = scoutedMatchPerformance.local
        
        timeMarker.event = event.rawValue
        timeMarker.time = time as NSNumber?
        
        timeMarker.scoutID = scoutID
    }
    
    //MARK: - Fuel
    //For recording that the team loaded fuel from somewhere
    var lastFuelLoading: FuelLoading?
    func recordFuelLoading(_ location: SSOffenseFuelViewController.FuelLoadingLocations.RawValue, atTime time: TimeInterval) {
        
        let fuelLoading = FuelLoading(entity: NSEntityDescription.entity(forEntityName: "FuelLoading", in: managedContext)!, insertInto: managedContext)
        
        let localPerformance = scoutedMatchPerformance.local
        fuelLoading.localMatchPerformance = localPerformance
        
        fuelLoading.location = location
        fuelLoading.time = time as NSNumber
        
        fuelLoading.isAutonomous = isAutonomous as NSNumber
        
        fuelLoading.scoutID = scoutID
        
        if let increase = fuelIncreaseToBeSet {
            fuelLoading.associatedFuelIncrease = increase as NSNumber
            fuelIncreaseToBeSet = nil
        }
        
        lastFuelLoading = fuelLoading
        
        saveTimeMarker(event: .LoadedFuel, atTime: time)
    }
    
    var fuelIncreaseToBeSet: Double?
    func setAssociatedFuelIncrease(withFuelIncrease fuelIncrease: Double, afterTime time: TimeInterval) {
        if (lastFuelLoading?.time?.doubleValue ?? 0) > time {
            //Fuel loading object has already been made and now just needs its amount set
            lastFuelLoading?.associatedFuelIncrease = fuelIncrease as NSNumber
            fuelIncreaseToBeSet = nil
        } else {
            //Object has not been made yet, set the amount to be set
            fuelIncreaseToBeSet = fuelIncrease
        }
    }
    
    func recordFuelScoring(inGoal goal: BoilerGoal.RawValue, atTime time: TimeInterval, scoredFrom location: CGPoint, withAmountShot amountShot: Double, withAccuracy accuracy: Double) {
        let fuelScoring = FuelScoring(entity: NSEntityDescription.entity(forEntityName: "FuelScoring", in: managedContext)!, insertInto: managedContext)
        
        fuelScoring.localMatchPerformance = scoutedMatchPerformance.local
        
        fuelScoring.goal = goal
        fuelScoring.time = time as NSNumber
        fuelScoring.accuracy = accuracy as NSNumber
        fuelScoring.amountShot = amountShot as NSNumber
        fuelScoring.xLocation = location.x as NSNumber
        fuelScoring.yLocation = location.y as NSNumber
        
        fuelScoring.isAutonomous = NSNumber(value: isAutonomous)
        
        fuelScoring.scoutID = scoutID
        
        saveTimeMarker(event: .ScoredFuel, atTime: time)
    }
    
    //MARK: Gears
    func recordGearLoading(fromLocation location: GearLoadingLocation.RawValue, atTime time: TimeInterval) {
        
        let gearLoading = GearLoading(entity: NSEntityDescription.entity(forEntityName: "GearLoading", in: managedContext)!, insertInto: managedContext)
        
        gearLoading.localMatchPerformance = scoutedMatchPerformance.local
        
        gearLoading.location = location
        gearLoading.time = time as NSNumber
        
        gearLoading.isAutonomous = isAutonomous as NSNumber
        
        gearLoading.scoutID = scoutID
        
        saveTimeMarker(event: .LoadedGear, atTime: time)
    }
    
    func recordGearMounting(onPeg peg: Int, atTime time: TimeInterval) {
        let gearMounting = GearMounting(entity: NSEntityDescription.entity(forEntityName: "GearMounting", in: managedContext)!, insertInto: managedContext)
        
        gearMounting.localMatchPerformance = scoutedMatchPerformance.local
        
        gearMounting.time = time as NSNumber
        gearMounting.pegNumber = peg as NSNumber
        
        gearMounting.isAutonomous = isAutonomous as NSNumber
        
        gearMounting.scoutID = scoutID
        
        saveTimeMarker(event: .ScoredGear, atTime: time)
    }
    
    //MARK: - Defendings
    func recordDefending(didDefendOffensiveTeam offendingTeam: TeamMatchPerformance, withType type: String, atTime time: TimeInterval, forDuration duration: TimeInterval, successfully successful: String) {
        let defendingObject = Defending(entity: NSEntityDescription.entity(forEntityName: "Defending", in: managedContext)!, insertInto: managedContext)
        
        defendingObject.defendingTeam = scoutedMatchPerformance.local
        defendingObject.offendingTeam = offendingTeam.local
        
        defendingObject.type = type
        defendingObject.time = time as NSNumber
        defendingObject.duration = duration as NSNumber
        defendingObject.successful = successful
        
        defendingObject.scoutID = scoutID
        
        saveTimeMarker(event: .Defended, atTime: time)
        
        /*-- For now not going to do this because we can't ensure that the other match performance is being scouted/ that it has a scout id. Also this sort of creates a loop in the data model so ae will only pay attention to the defendings property in a match performance*/
        //Now also save a time marker on the offending team (the team that was blocked)
//        let wasBlockedTimeMarker = TimeMarker(entity: NSEntityDescription.entity(forEntityName: "TimeMarker", in: managedContext)!, insertInto: managedContext)
//        
//        wasBlockedTimeMarker.localMatchPerformance = offendingTeam.local
//        
//        wasBlockedTimeMarker.event = TimeMarkerEvent.WasBlocked.rawValue
//        wasBlockedTimeMarker.time = time as NSNumber?
//        wasBlockedTimeMarker.scoutID =
    }
    
    //MARK: - Rope
    func recordRopeClimb(_ successful: LocalMatchPerformance.RopeClimbSuccess.RawValue) {
        scoutedMatchPerformance.local.ropeClimbStatus = successful
    }
}
