//
//  SSDataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/21/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import AWSMobileClient
import AWSAppSync

///A data manager that tracks a team participating in a match. It is a singleton so when the stands scouting vc first initializes it, it saves itself and all the other stands scouting vcs use the same object.
class SSDataManager {
    let teamKey: String
    let match: Match
    
    let stopwatch: Stopwatch
    
    static var currentSSDataManager: SSDataManager?
    
    var timeMarkers: [TimeMarkerInput] = []
    
    private(set) var hasPassedAutonomous: Bool = false
    
    init(match: Match, teamKey: String) {
        self.match = match
        self.teamKey = teamKey
        
        self.stopwatch = Stopwatch()
        
        SSDataManager.currentSSDataManager = self
        
        CLSNSLogv("Began Stands Scouting for key: \(teamKey) in \(match.key)", getVaList([]))
    }
    
    func recordScoutSession() {
        Globals.appDelegate.appSyncClient?.perform(mutation: CreateScoutSessionMutation(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: match.eventKey, teamKey: teamKey, matchKey: match.key, timeMarkers: timeMarkers), optimisticUpdate: { (transaction) in
            //TODO: - Add optimistic update
        }, conflictResolutionBlock: { (snapshot, taskCompletionSource, onCompletion) in
            
        }, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "CreateScoutSession", result: result, error: error) {
                //TODO: - Handle this
                CLSNSLogv("Successfully saved new scout session", getVaList([]))
            } else {
                //Show an alert that it failed to save
                //TODO: - Handle this
            }
        })
    }
    
    ///Stores a time marker that marks the end of the Autonomous/Sandstorm(2019) period
    func endAutonomousPeriod() {
        if hasPassedAutonomous {
            return
        } else {
            hasPassedAutonomous = true
            addTimeMarker(event: "endAutonomousPeriod", location: nil)
        }
    }
    
    func didCrossAutoLine() {
        addTimeMarker(event: "didCrossAutoLine", location: nil)
    }
    
    func addTimeMarker(event: String, location: String?) {
        let newTM = TimeMarkerInput(event: event, time: stopwatch.elapsedTime, associatedLocation: location)
        
        timeMarkers.append(newTM)
    }
}
