//
//  TBAAsyncManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/12/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

///For loading async OPRs, ranks, team statuses, match scores, and eventually insights

///
class TBAEventUpdatingData {
    
    
    init() {
        
    }
}

///Sole job is to reload data from cloud not retrieve
class TBAUpdatingDataReloader {
    
    let cloudConnection = CloudData()
    
    ///Only accessible on the TBA background thread
    private var backgroundGeneralRealm: Realm!
    private var backgroundSyncedRealm: Realm!
    
    static let backgroundQueueID = "TBAUpdatingThread"
    private var backgroundQueue: DispatchQueue
    
    private var oprTimedUpdaters = [Event:FASTBackgroundTimer]()
    private var matchTimedUpdaters = [Event:FASTBackgroundTimer]()
    
    init(withSyncedRealmConfig syncedRealmConfig: Realm.Configuration, andGeneralRealmConfig generalRealmConfig: Realm.Configuration) {
        //Create background thread for updating
        backgroundQueue = DispatchQueue(label: TBAUpdatingDataReloader.backgroundQueueID)
        backgroundQueue.sync {
            do {
                self.backgroundGeneralRealm = try Realm(configuration: generalRealmConfig)
                self.backgroundSyncedRealm = try Realm(configuration: syncedRealmConfig)
            } catch {
                CLSNSLogv("Unable to open realms on tba background thread with error: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                
                //TODO: Should stop reloading at this moment, maybe call suspend() ?
                
            }
        }
    }
    
    func setOPRUpdater(forEvent event: Event) {
        
    }
    
    func reloadOPRs(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (_ wasUpdated: Bool) -> Void) {
        cloudConnection.oprs(withEventKey: eventKey) {frcOPRs, error in
            if let oprs = frcOPRs {
                self.backgroundQueue.sync {
                    self.backgroundGeneralRealm.refresh()
                    self.backgroundSyncedRealm.refresh()
                    
                    let event = self.backgroundGeneralRealm.object(ofType: Event.self, forPrimaryKey: eventKey)!
                    let teams = event.teamEventPerformances.map({$0.team!})
                    
                    
                    //Go through all the teams in this event
                    for team in teams {
                        //Get the computed stats
                        if let computedStats = team.scouted.computedStats(forEvent: event) {
                            
                            computedStats.opr.value = oprs.oprs[team.key]
                            computedStats.dpr.value = oprs.dprs[team.key]
                            computedStats.ccwm.value = oprs.ccwms[team.key]
                            computedStats.areFromTBA = true
                        }
                    }
                    
                    Answers.logCustomEvent(withName: "Loaded OPRs from TBA", customAttributes: nil)
                }
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    ///Reloads match scores and times
    func reloadMatchInfo(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (_ wasUpdated: Bool) -> Void) {
        
    }
}

//From: https://medium.com/@danielgalasko/a-background-repeating-timer-in-swift-412cecfd2ef9
///A custom background timer that will start after 3 seconds and update with a custom number of seconds
class FASTBackgroundTimer {
    init(withInterval interval: Int, andEventHandler eventHandler: @escaping () -> Void) {
        self.interval = interval
        self.eventHandler = eventHandler
        
        self.timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + 3, repeating: .seconds(interval))
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
    }
    
    private let interval: Int
    
    private var timer: DispatchSourceTimer
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here
         https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
}
