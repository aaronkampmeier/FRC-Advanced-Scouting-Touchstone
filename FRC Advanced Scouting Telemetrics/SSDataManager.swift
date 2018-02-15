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
    
    fileprivate weak static var mostRecentSSDataManager: SSDataManager?
    class func currentSSDataManager() -> SSDataManager? {
        return mostRecentSSDataManager
    }
    
    var preloadedCube: Bool?
    
    init(teamBeingScouted: Team, matchBeingScouted: Match, stopwatch: Stopwatch) {
        //Start the write session
        RealmController.realmController.syncedRealm.beginWrite()
        
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
    
    func save() {
        do {
            try RealmController.realmController.syncedRealm.commitWrite()
            CLSNSLogv("Saved Stands Scouting Data", getVaList([]))
        } catch {
            CLSNSLogv("Error commiting write of stands scouting data", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    func rollback() {
        //TODO: Implement a way to erase scouted data from a session
        RealmController.realmController.syncedRealm.cancelWrite()
        CLSNSLogv("Rolledback Stands Scouting Data", getVaList([]))
    }
    
    func setDidCrossAutoLine(didCross: Bool) {
        scoutedMatchPerformance.scouted.didCrossAutoLine = didCross
    }
    
    func saveTimeMarker(event: TimeMarkerEvent, atTime time: TimeInterval, withAssociatedLocation associatedLocation: String? = nil) {
        let timeMarker = RealmController.realmController.syncedRealm.create(TimeMarker.self)
        
        timeMarker.scoutedMatchPerformance = scoutedMatchPerformance.scouted
        
        timeMarker.event = event.rawValue
        timeMarker.time = time
        timeMarker.isAuto = self.isAutonomous
        
        timeMarker.associatedLocation = associatedLocation
        
        timeMarker.scoutID = scoutID
    }
    
    //MARK: - Climb
    func recordClimb(_ successful: ClimbStatus.RawValue) {
        scoutedMatchPerformance.scouted.climbStatus = successful
    }
    
    func recordAssist(_ assist: ClimbAssistStatus.RawValue) {
        scoutedMatchPerformance.scouted.climbAssistStatus = assist
    }
}
