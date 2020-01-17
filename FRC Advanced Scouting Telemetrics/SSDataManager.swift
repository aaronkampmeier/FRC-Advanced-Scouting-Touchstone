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
    private let teamKey: String
    private let match: Match
    
    //TODO: Move this to private(set) and handle managing the stopwatch from the data manager
    internal var stopwatch: Stopwatch
    
    private(set) var modelState: FASTCompetitionModelState
    internal var model: FASTCompetitionModel? {
        switch modelState {
        case .Loaded(let model):
            return model
        default:
            return nil
        }
    }
    
    private var timeMarkers: [TimeMarkerInput] = []
    private(set) var hasPassedAutonomous: Bool = false
    private var startState: [String:Any] = [:]
    private var endState: [String:Any] = [:]
    
    init(match: Match, teamKey: String) {
        self.match = match
        self.teamKey = teamKey
        
        self.stopwatch = Stopwatch()
        
        self.modelState = Globals.dataManager.asyncLoadingManager.eventModelStates[match.eventKey] ?? .Loading
        
        CLSNSLogv("Began Stands Scouting for key: \(teamKey) in \(match.key)", getVaList([]))
    }
    
    internal func start() {
        
    }
    
    internal func recordScoutSession() {
        //Create the start state and end state json strings
        var startStateString: String = "{}"
        var endStateString: String = "{}"
        do {
            let startStateData = try JSONSerialization.data(withJSONObject: startState, options: [])
            startStateString = String(data: startStateData, encoding: .utf8) ?? "{}"
            
            let endStateData = try JSONSerialization.data(withJSONObject: endState, options: [])
            endStateString = String(data: endStateData, encoding: .utf8) ?? "{}"
        } catch {
            CLSNSLogv("Error serializing start (\(startState)) and end state (\(endState)) data: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
        
        let mutation = CreateScoutSessionMutation(scoutTeam: Globals.dataManager.enrolledScoutingTeamID ?? "", eventKey: match.eventKey, teamKey: teamKey, matchKey: match.key, recordedDate: Int(Date().timeIntervalSince1970), startState: startStateString, endState: endStateString, timeMarkers: timeMarkers)
        Globals.appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
            //TODO: - Add optimistic update
        }, conflictResolutionBlock: { (snapshot, taskCompletionSource, onCompletion) in
            
        }, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "CreateScoutSession", result: result, error: error) {
                //TODO: - Handle this
                CLSNSLogv("Successfully saved new scout session", getVaList([]))
            } else {
                //Show an alert that it failed to save
                let alert = UIAlertController(title: "Stands Scouting Failed", message: "There was an error saving the stands scouting data. This error has been recorded. \(error?.localizedDescription ?? result?.errors?.map({$0.errorDescription}).description ?? "Unkown Error")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
            }
        })
    }
    
    ///Stores a time marker that marks the end of the Autonomous/Sandstorm(2019) period
    internal func endAutonomousPeriod() {
        if hasPassedAutonomous {
            return
        } else {
            hasPassedAutonomous = true
            addTimeMarker(event: "end_autonomous_period", subOption: nil)
        }
    }
    
    internal func setState(value: Any, forKey key: String, inSection gameSection: SSStateGameSection) {
        switch gameSection {
        case .Start:
            startState[key] = value
        case .End:
            endState[key] = value
        }
    }
    
    internal func addTimeMarker(event: String, subOption: String?) {
        var option: String?
        if subOption == "" {
            option = nil
        } else {
            option = subOption
        }
        
        let newTM = TimeMarkerInput(event: event, time: stopwatch.elapsedTime, subOption: option)
        
        timeMarkers.append(newTM)
    }
}
