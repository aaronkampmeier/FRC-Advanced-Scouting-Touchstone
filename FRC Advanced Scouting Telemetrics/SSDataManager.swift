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
    
    let scoutedTeam: Team
    let scoutedMatch: Match
    let scoutedMatchPerformance: TeamMatchPerformance
    let stopwatch: Stopwatch //A place for the stands scouting view controller to put the stopwatch so that other vcs can access it while it is running
    
    var startingPosition: StartingPosition!
    var isAutonomous: Bool = true
    
    var preloadedFuel: Double = 0.0
    var preloadedGear = false
    
    private weak static var mostRecentSSDataManager: SSDataManager?
    class func currentSSDataManager() -> SSDataManager? {
        return mostRecentSSDataManager
    }
    
    init(teamBeingScouted: Team, matchBeingScouted: Match, stopwatch: Stopwatch) {
        try! managedContext.save()
        
        self.stopwatch = stopwatch
        
        scoutedTeam = teamBeingScouted
        scoutedMatch = matchBeingScouted
        
        var teamMatchPerformance: TeamMatchPerformance?
        for matchPerformance in scoutedMatch.teamPerformances?.allObjects as! [TeamMatchPerformance] {
            if matchPerformance.eventPerformance!.team == scoutedTeam {
                teamMatchPerformance = matchPerformance
            }
        }
        
        if let matchPerformance = teamMatchPerformance {
            scoutedMatchPerformance = matchPerformance
        } else {
            assertionFailure()
            exit(EXIT_FAILURE)
        }
        
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
    
    //MARK: - Fuel
    //For recording that the team loaded fuel from somewhere
    var lastFuelLoading: FuelLoading?
    func recordFuelLoading(location: SSOffenseFuelViewController.FuelLoadingLocations.RawValue, atTime time: TimeInterval) {
        
        let fuelLoading = FuelLoading(entity: NSEntityDescription.entity(forEntityName: "FuelLoading", in: managedContext)!, insertInto: managedContext)
        
        let localPerformance = scoutedMatchPerformance.local
        fuelLoading.localMatchPerformance = localPerformance
        
        fuelLoading.location = location
        fuelLoading.time = time as NSNumber
        
        lastFuelLoading = fuelLoading
        
        fuelLoading.isAutonomous = isAutonomous as NSNumber
    }
    
    func setAssociatedFuelIncrease(withFuelIncrease fuelIncrease: Double) {
        lastFuelLoading?.associatedFuelIncrease = fuelIncrease as NSNumber
    }
    
    func recordFuelScoring(inGoal goal: SSOffenseFuelViewController.FuelScoringLocations.RawValue, atTime time: TimeInterval, scoredFrom location: CGPoint) {
        let fuelScoring = FuelScoring(entity: NSEntityDescription.entity(forEntityName: "FuelScoring", in: managedContext)!, insertInto: managedContext)
        
        fuelScoring.localMatchPerformance = scoutedMatchPerformance.local
        
        fuelScoring.goal = goal
        fuelScoring.time = time as NSNumber
        fuelScoring.xLocation = location.x as NSNumber
        fuelScoring.yLocation = location.y as NSNumber
        
        fuelScoring.isAutonomous = NSNumber(value: isAutonomous)
    }
    
    //MARK: Gears
    func recordGearLoading(fromLocation location: SSOffenseGearViewController.GearLoadingLocations.RawValue, atTime time: TimeInterval) {
        
        let gearLoading = GearLoading(entity: NSEntityDescription.entity(forEntityName: "GearLoading", in: managedContext)!, insertInto: managedContext)
        
        gearLoading.localMatchPerformance = scoutedMatchPerformance.local
        
        gearLoading.location = location
        gearLoading.time = time as NSNumber
        
        gearLoading.isAutonomous = isAutonomous as NSNumber
    }
    
    func recordGearMounting(onPeg peg: Int, atTime time: TimeInterval) {
        let gearMounting = GearMounting(entity: NSEntityDescription.entity(forEntityName: "GearMounting", in: managedContext)!, insertInto: managedContext)
        
        gearMounting.localMatchPerformance = scoutedMatchPerformance.local
        
        gearMounting.time = time as NSNumber
        gearMounting.pegNumber = peg as NSNumber
        
        gearMounting.isAutonomous = isAutonomous as NSNumber
    }
    
    //MARK: - Defendings
    func recordDefending(defendingTeam: TeamMatchPerformance, didDefendOffensiveTeam offendingTeam: TeamMatchPerformance, atTime time: TimeInterval, forDuration duration: TimeInterval, successfully successful: Bool) {
        let defendingObject = Defending(entity: NSEntityDescription.entity(forEntityName: "Defending", in: managedContext)!, insertInto: managedContext)
        
        defendingObject.defendingTeam = defendingTeam.local
        defendingObject.offendingTeam = offendingTeam.local
        
        defendingObject.time = time as NSNumber
        defendingObject.duration = duration as NSNumber
        defendingObject.successful = successful as NSNumber
    }
}
