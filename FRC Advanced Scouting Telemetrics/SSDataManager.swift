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
    let scoutID: String
    
    let scoutedTeam: Team
    let scoutedMatch: Match
    let scoutedMatchPerformance: TeamMatchPerformance
    let stopwatch: Stopwatch //A place for the stands scouting view controller to put the stopwatch so that other vcs can access it while it is running
    
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
        
        self.scoutID = UUID().uuidString
        
        self.stopwatch = stopwatch
        
        scoutedTeam = teamBeingScouted
        scoutedMatch = matchBeingScouted
        
        //Get the match performance that we are scouting
        var teamMatchPerformance: TeamMatchPerformance?
        for matchPerformance in scoutedMatch.teamPerformances {
            if matchPerformance.teamEventPerformance!.team == scoutedTeam {
                teamMatchPerformance = matchPerformance
            }
        }
        
        if let matchPerformance = teamMatchPerformance {
            scoutedMatchPerformance = matchPerformance
        } else {
            Crashlytics.sharedInstance().recordCustomExceptionName("Stands Scouting Team Match Performance Does Not Exist", reason: nil, frameArray: [])
            
            //TODO: Handle this error better
            assertionFailure()
            exit(EXIT_FAILURE)
        }
        
        //TODO: Don't believe this lines up with good use of scout IDs
        scoutedMatchPerformance.scouted.defaultScoutID = scoutID
        
        SSDataManager.mostRecentSSDataManager = self
    }
    
    func rollback() {
        //TODO: Implement a way to erase scouted data from a session
    }
    
    func saveTimeMarker(event: TimeMarkerEvent, atTime time: TimeInterval) {
        let timeMarker = RealmController.realmController.syncedRealm.create(TimeMarker.self)
        
        do {
            try RealmController.realmController.syncedRealm.write {
                timeMarker.scoutedMatchPerformance = scoutedMatchPerformance.scouted
                
                timeMarker.event = event.rawValue
                timeMarker.time = time
                
                timeMarker.scoutID = scoutID
            }
        } catch {
            CLSNSLogv("Error writing a new time marker", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    //MARK: - Climg
    func recordClimb(_ successful: ScoutedMatchPerformance.ClimbSuccess.RawValue) {
        scoutedMatchPerformance.scouted.climbStatus = successful
    }
}
