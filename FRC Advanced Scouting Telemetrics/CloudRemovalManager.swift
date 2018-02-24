//
//  CloudRemovalManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/29/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
import Crashlytics

class CloudEventRemovalManager {
    fileprivate let eventToRemove: Event
    let realmController = RealmController.realmController
    
    let completionHandler: (Bool) -> Void
    
    init(eventToRemove event: Event, completionHandler: @escaping (Bool) -> Void) {
        self.eventToRemove = event
        self.completionHandler = completionHandler
    }
    
    func remove() {
        CLSNSLogv("Beginning removal of event: %@", getVaList([eventToRemove.key]))
        
        //Start by going through the teams and finding the ones that will need to be removed. A team will be removed if the event being removed is the only event it is a part of.
        let eventTeams = (eventToRemove.teamEventPerformances).map(){$0.team}
        var teamsToRemove = [Team]()
        for team in eventTeams {
            if (team!.eventPerformances.count) == 1 {
                teamsToRemove.append(team!)
            }
        }
        let scoutedTeamsToRemove = teamsToRemove.map {$0.scouted}
        realmController.delete(objects: teamsToRemove)
        
        //Won't actually remove the local team. It will stay in the database in case the user adds it back and wants to access their old data. The local team is simply removed from the local team ranking so it doesn't show up in the team list.
        realmController.genericWrite(onRealm: .Synced) {
            for scoutedTeam in scoutedTeamsToRemove {
                scoutedTeam.ranker?.rankedTeams.remove(at: (scoutedTeam.ranker?.rankedTeams.index(of: scoutedTeam))!)
            }
        }
        
        let matchesToDelete = Array(eventToRemove.matches)
        let teamMatchPerformances = Array(eventToRemove.matches.reduce([TeamMatchPerformance]()) {partialArray, match in
            return partialArray + match.teamPerformances})
        let teamEventPerformances = Array(eventToRemove.teamEventPerformances)
        
        //Now delete the event and along with it the matches, the event performances, and the match performances. Again the local versions will stay.
        realmController.delete(objects: matchesToDelete)
        realmController.delete(objects: teamMatchPerformances)
        realmController.delete(objects: teamEventPerformances)
        
        realmController.delete(object: eventToRemove)
        CLSNSLogv("Finished removal of event", getVaList([]))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdatedTeams")))
        
        completionHandler(true)
    }
}
