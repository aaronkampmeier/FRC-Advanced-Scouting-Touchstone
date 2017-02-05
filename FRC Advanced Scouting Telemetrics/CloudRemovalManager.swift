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
    let dataManager = DataManager()
    fileprivate let managedContext = DataManager.managedContext
    
    let completionHandler: (Bool) -> Void
    
    init(eventToRemove event: Event, completionHandler: @escaping (Bool) -> Void) {
        self.eventToRemove = event
        self.completionHandler = completionHandler
    }
    
    func remove() {
        CLSNSLogv("Beginning removal of event: %@", getVaList([eventToRemove.key!]))
        
        //Start by going through the teams and finding the ones that will need to be removed. A team will be removed if the event being removed is the only event it is a part of.
        let eventTeams = (eventToRemove.teamEventPerformances?.allObjects as! [TeamEventPerformance]).map(){$0.team}
        var teamsToRemove = [Team]()
        for team in eventTeams {
            if (team.eventPerformances?.count)! == 1 {
                teamsToRemove.append(team)
            }
        }
        let localTeamsToRemove = UniversalToLocalConversion<Team,LocalTeam>(universalObjects: teamsToRemove).convertToLocal()
        dataManager.delete(teamsToRemove)
        
        //Won't actually remove the local team. It will stay in the database in case the user adds it back and wants to access their old data. The local team is simply removed from the local team ranking so it doesn't show up in the team list.
        for localTeam in localTeamsToRemove {
            localTeam.ranker = nil
        }
        
        //Now delete the event and along with it the matches, the event performances, and the match performances. Again the local versions will stay.
        dataManager.delete(eventToRemove)
        
        CLSNSLogv("Finished removal of event", getVaList([]))
        dataManager.commitChanges()
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdatedTeams")))
        
        completionHandler(true)
    }
}
