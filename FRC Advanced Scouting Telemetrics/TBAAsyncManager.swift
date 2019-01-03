////
////  TBAAsyncManager.swift
////  FRC Advanced Scouting Touchstone
////
////  Created by Aaron Kampmeier on 3/12/18.
////  Copyright © 2018 Kampfire Technologies. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//import Crashlytics
//
/////For loading async OPRs, ranks, team statuses, match scores, and eventually insights
//
/////Sole job is to reload data from cloud not retrieve
//class TBAUpdatingDataReloader {
//
//    let cloudConnection = CloudData()
//
//    private var generalRealmConfig: Realm.Configuration
//    private var scoutedRealmConfig: Realm.Configuration
//
//    static let backgroundQueueID = "TBAUpdatingThread"
//    private var backgroundQueue: DispatchQueue
//
//    //Event Key is key
//    private var oprTimedUpdaters = [String:FASTBackgroundTimer]()
//    private var matchTimedUpdaters = [String:FASTBackgroundTimer]()
//    private var statusTimedUpdaters = [String:FASTBackgroundTimer]()
//
//    private var eventsNotificationToken: NotificationToken?
//
//    init(withScoutedRealmConfig scoutedRealmConfig: Realm.Configuration, andGeneralRealmConfig generalRealmConfig: Realm.Configuration) {
//        //Create background thread for updating
//        backgroundQueue = DispatchQueue(label: TBAUpdatingDataReloader.backgroundQueueID, qos: .background)
//
//        self.generalRealmConfig = generalRealmConfig
//        self.scoutedRealmConfig = scoutedRealmConfig
//
//        //Set updaters to listen for new/deleted events
//        eventsNotificationToken = getRealms()?.generalRealm.objects(Event.self).observe {[weak self]  collectionChange in
//            switch collectionChange {
//            case .update(_, let deletions, let insertions, _):
//                if deletions.count > 0 || insertions.count > 0 {
//                    //Reload all the updaters
//                    self?.setGeneralUpdaters()
//                }
//            default:
//                break
//            }
//        }
//    }
//
//    deinit {
//         eventsNotificationToken?.invalidate()
//    }
//
//    //Meant to be called on background threads to create the relams for that thread and return it
//    func getRealms() -> (generalRealm: Realm, scoutedRealm: Realm)? {
//        let generalRealm: Realm
//        let syncedRealm: Realm
//        do {
//            generalRealm = try Realm(configuration: generalRealmConfig)
//            syncedRealm = try Realm(configuration: scoutedRealmConfig)
//
//            return (generalRealm, syncedRealm)
//        } catch {
//            CLSNSLogv("Unable to open realms on tba background thread with error: \(error)", getVaList([]))
//            Crashlytics.sharedInstance().recordError(error)
//
//            //TODO: Should stop reloading at this moment, maybe call suspend() ?
//            return nil
//        }
//    }
//
//    ///Sets basic, general updaters; will remove all existing ones on call
//    func setGeneralUpdaters() {
//        oprTimedUpdaters.removeAll()
//        matchTimedUpdaters.removeAll()
//        statusTimedUpdaters.removeAll()
//
//        if let realms = self.getRealms() {
//            let events = realms.generalRealm.objects(Event.self)
//
//            for event in events {
//                self.setOPRUpdater(forEventKey: event.key)
//                self.setMatchUpdater(forEventKey: event.key)
//                self.setStatusesUpdater(forEvent: event.key)
//            }
//        }
//    }
//
//    func setOPRUpdater(forEventKey eventKey: String) {
//        backgroundQueue.sync {
//            let timer = FASTBackgroundTimer(withInterval: 60 * 8) {[weak self] in
//                //Reload OPR
//                self?.reloadOPRs(forEventKey: eventKey) {wasUpdated in
//                    CLSNSLogv("Background reload of OPR for event \(eventKey) completed with updates: \(wasUpdated)", getVaList([]))
//                }
//            }
//
//            timer.resume()
//
//            self.oprTimedUpdaters[eventKey] = timer
//        }
//    }
//
//    func removeOPRUpdaters(forEventKey eventKey: String) {
//        oprTimedUpdaters[eventKey] = nil
//    }
//
//    func setMatchUpdater(forEventKey eventKey: String) {
//        backgroundQueue.sync {
//            let timer = FASTBackgroundTimer(withInterval: 60 * 3) { [weak self] in
//                self?.reloadMatchInfo(forEventKey: eventKey) {didUpdate in
//                    CLSNSLogv("Background reload of matches for event \(eventKey) completed with updates: \(didUpdate)", getVaList([]))
//                }
//            }
//
//            timer.resume()
//
//            self.matchTimedUpdaters[eventKey] = timer
//        }
//    }
//
//    func removeMatchUpdater(forEventKey eventKey: String) {
//        matchTimedUpdaters[eventKey] = nil
//    }
//
//    func setStatusesUpdater(forEvent eventKey: String) {
//        backgroundQueue.sync {
//            let timer = FASTBackgroundTimer(withInterval: 60 * 4) { [weak self] in
//                self?.reloadTeamStatuses(forEventKey: eventKey) {didUpdate in
//                    CLSNSLogv("Background reload of statuses for event \(eventKey) completed with updates: \(didUpdate)", getVaList([]))
//                }
//            }
//
//            timer.resume()
//
//            self.statusTimedUpdaters[eventKey] = timer
//        }
//    }
//
//    func removeStatusesUpdater(forEvent eventKey: String) {
//        statusTimedUpdaters[eventKey] = nil
//    }
//
//    func reloadOPRs(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (_ wasUpdated: Bool) -> Void) {
//        cloudConnection.oprs(withEventKey: eventKey) {frcOPRs, error in
//            if let oprs = frcOPRs {
//                self.backgroundQueue.async {
//                    autoreleasepool {
//                        if let realms = self.getRealms() {
//                            realms.scoutedRealm.beginWrite()
//
//                            if let event = realms.generalRealm.object(ofType: Event.self, forPrimaryKey: eventKey) {
//                                let teams = event.teamEventPerformances.map({$0.team!})
//
//                                //Go through all the teams in this event
//                                for team in teams {
//                                    //Get the computed stats
//                                    if let computedStats = realms.scoutedRealm.object(ofType: ComputedStats.self, forPrimaryKey: "computedStats_\(event.key)_\(team.key)") {
//                                        computedStats.opr.value = oprs.oprs[team.key]
//                                        computedStats.dpr.value = oprs.dprs[team.key]
//                                        computedStats.ccwm.value = oprs.ccwms[team.key]
//                                    }
//                                }
//
//                                Answers.logCustomEvent(withName: "Background Loaded OPRs from TBA", customAttributes: nil)
//                            }
//
//                            do {
//                                try realms.scoutedRealm.commitWrite()
//                                completionHandler(true)
//                            } catch {
//                                CLSNSLogv("Error commiting write of background OPR loading: \(error)", getVaList([]))
//                                completionHandler(false)
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        } else {
//                            completionHandler(false)
//                        }
//                    }
//                }
//            } else {
//                completionHandler(false)
//            }
//        }
//    }
//
//    ///Reloads match scores and times
//    func reloadMatchInfo(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (_ wasUpdated: Bool) -> Void) {
//        cloudConnection.matches(forEventKey: eventKey, shouldUseModificationValues: true) {frcMatches, error in
//            if let frcMatches = frcMatches {
//                self.backgroundQueue.async {
//                    autoreleasepool {
//                        if let realms = self.getRealms() {
//                            realms.generalRealm.beginWrite()
//                            realms.scoutedRealm.beginWrite()
//
//                            if let event = realms.generalRealm.object(ofType: Event.self, forPrimaryKey: eventKey) {
//                                let matches = event.matches
//
//                                for match in matches {
//                                    if let scoutedMatch = realms.scoutedRealm.object(ofType: ScoutedMatch.self, forPrimaryKey: match.key) {
//                                        if let frcMatch = frcMatches.first(where: {$0.key == match.key}){
//                                            if let redScore = frcMatch.alliances?["red"]?.score {
//                                                if redScore != -1 {
//                                                    scoutedMatch.redScore.value = redScore
//                                                }
//                                            }
//
//                                            if let blueScore = frcMatch.alliances?["blue"]?.score {
//                                                if blueScore != -1 {
//                                                    scoutedMatch.blueScore.value = blueScore
//                                                }
//                                            }
//
//                                            if let actualTime = frcMatch.actualTime {
//                                                match.time = actualTime
//                                            } else if let predictedTime = frcMatch.predictedTime {
//                                                match.time = predictedTime
//                                            } else {
//                                                match.time = frcMatch.scheduledTime
//                                            }
//                                        }
//                                    }
//
//                                }
//                            }
//
//                            do {
//                                try realms.scoutedRealm.commitWrite()
//                                try realms.generalRealm.commitWrite()
//
//                                completionHandler(true)
//                            } catch {
//                                CLSNSLogv("Error commiting background write of match updates: \(error)", getVaList([]))
//                                completionHandler(false)
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        } else {
//                            completionHandler(false)
//                        }
//                    }
//                }
//            } else {
//                completionHandler(false)
//            }
//        }
//    }
//
//    ///Reloads team status string and rank (in Computed Stats)
//    func reloadTeamStatuses(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (_ wasUpdated: Bool) -> Void) {
//        cloudConnection.teamStatuses(forEvent: eventKey) {frcStatuses, error in
//            if let frcStatuses = frcStatuses {
//                self.backgroundQueue.async {
//                    autoreleasepool {
//                        if let realms = self.getRealms() {
//                            realms.scoutedRealm.beginWrite()
//
//                            if let eventRanker = realms.scoutedRealm.object(ofType: EventRanker.self, forPrimaryKey: eventKey) {
//                                for team in eventRanker.rankedTeams {
//                                    if let computedStats = realms.scoutedRealm.object(ofType: ComputedStats.self, forPrimaryKey: "computedStats_\(eventRanker.key)_\(team.key)") {
//                                        //Now get the frcStatus
//                                        if let frcStatus = frcStatuses[team.key] {
//                                            computedStats.rank.value = frcStatus?.qual?.ranking?.rank
//                                            computedStats.overallStatusString = frcStatus?.overallStatus
//                                        }
//                                    }
//                                }
//                            }
//
//                            do {
//                                try realms.scoutedRealm.commitWrite()
//                                completionHandler(true)
//                            } catch {
//                                CLSNSLogv("Error commiting background write of ststuses updates: \(error)", getVaList([]))
//                                completionHandler(false)
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        } else {
//                            completionHandler(false)
//                        }
//                    }
//                }
//            } else {
//                completionHandler(false)
//            }
//        }
//    }
//}
//
////From: https://medium.com/@danielgalasko/a-background-repeating-timer-in-swift-412cecfd2ef9
/////A custom background timer that will start after 3 seconds and update with a custom number of seconds
//class FASTBackgroundTimer {
//    init(withInterval interval: Int, andEventHandler eventHandler: @escaping () -> Void) {
//        self.interval = interval
//        self.eventHandler = eventHandler
//
//        self.timer = DispatchSource.makeTimerSource()
//        timer.schedule(deadline: .now() + 3, repeating: .seconds(interval))
//        timer.setEventHandler(handler: { [weak self] in
//            self?.eventHandler?()
//        })
//    }
//
//    private let interval: Int
//
//    private var timer: DispatchSourceTimer
//
//    var eventHandler: (() -> Void)?
//
//    private enum State {
//        case suspended
//        case resumed
//    }
//    private var state: State = .suspended
//    func resume() {
//        if state == .resumed {
//            return
//        }
//        state = .resumed
//        timer.resume()
//    }
//
//    func suspend() {
//        if state == .suspended {
//            return
//        }
//        state = .suspended
//        timer.suspend()
//    }
//
//    deinit {
//        timer.setEventHandler {}
//        timer.cancel()
//        /*
//         If the timer is suspended, calling cancel without resuming
//         triggers a crash. This is documented here
//         https://forums.developer.apple.com/thread/15902
//         */
//        resume()
//        eventHandler = nil
//    }
//}
