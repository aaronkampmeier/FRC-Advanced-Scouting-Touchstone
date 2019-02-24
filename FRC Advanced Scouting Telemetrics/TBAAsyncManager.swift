//
//  TBAAsyncManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/12/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import AWSAppSync
import AWSMobileClient
import Crashlytics

///For loading async OPRs, ranks, team statuses, match scores, and eventually insights

///Sole job is to reload data from cloud not retrieve
class TBAUpdatingDataReloader {

    static let backgroundQueueID = "TBAUpdatingThread"
    private var backgroundQueue: DispatchQueue

    //Event Key is key
    private var oprTimedUpdaters = [String:FASTBackgroundTimer]()
    private var matchTimedUpdaters = [String:FASTBackgroundTimer]()
    private var statusTimedUpdaters = [String:FASTBackgroundTimer]()
    
    private var addEventSubscription: AWSAppSyncSubscriptionWatcher<OnAddTrackedEventSubscription>?
    private var removeEventSubscription: AWSAppSyncSubscriptionWatcher<OnRemoveTrackedEventSubscription>?
    var trackedEventWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    var trackedEvents = [ListTrackedEventsQuery.Data.ListTrackedEvent]()

    init() {
        //Create background thread for updating
        backgroundQueue = DispatchQueue(label: TBAUpdatingDataReloader.backgroundQueueID, qos: .utility)

        resetSubscriptions()
        
        trackedEventWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery-AsyncManager", result: result, error: error) {
                self?.trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
                self?.setGeneralUpdaters()
            } else {
                
            }
        })
    }
    
    func resetSubscriptions() {
        //Set updaters to listen for new/deleted events
        do {
            addEventSubscription = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnAddTrackedEventSubscription(userID: AWSMobileClient.sharedInstance().username!), resultHandler: {[weak self] (result, transaction, error) in
                if Globals.handleAppSyncErrors(forQuery: "AsyncLoader-OnAddTrackedEventSubscription", result: result, error: error) {
                    if let newEvent = result?.data?.onAddTrackedEvent {
                        do {
                            try transaction?.update(query: ListTrackedEventsQuery(), { (selectionSet) in
                                selectionSet.listTrackedEvents?.append(try ListTrackedEventsQuery.Data.ListTrackedEvent(newEvent))
                            })
                        } catch {
                            CLSNSLogv("Error updating ListTrackedEvents cache \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                } else {
                    if let _ = error as? AWSAppSyncSubscriptionError {
                        self?.resetSubscriptions()
                    }
                }
            })
            
            removeEventSubscription = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnRemoveTrackedEventSubscription(userID: AWSMobileClient.sharedInstance().username!), resultHandler: {[weak self] (result, transaction, error) in
                if Globals.handleAppSyncErrors(forQuery: "AsyncLoader-OnRemoveTrackedEventSubscription", result: result, error: error) {
                    if let removedEvent = result?.data?.onRemoveTrackedEvent {
                        do {
                            try transaction?.update(query: ListTrackedEventsQuery(), { (selectionSet) in
                                selectionSet.listTrackedEvents?.removeAll(where: {$0?.eventKey == removedEvent.eventKey})
                            })
                        } catch {
                            CLSNSLogv("Error updating ListTrackedEvents cache \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                } else {
                    if let _ = error as? AWSAppSyncSubscriptionError {
                        self?.resetSubscriptions()
                    }
                }
            })
        } catch {
            CLSNSLogv("Error setting subscriptions on the Async Loading Manager", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    deinit {
    }

    ///Sets basic, general updaters; will remove all existing ones on call
    func setGeneralUpdaters() {
        oprTimedUpdaters.removeAll()
        matchTimedUpdaters.removeAll()
        statusTimedUpdaters.removeAll()
        
        for trackedEvent in self.trackedEvents {
            self.setOPRUpdater(forEventKey: trackedEvent.eventKey)
            self.setMatchUpdater(forEventKey: trackedEvent.eventKey)
            self.setStatusesUpdater(forEvent: trackedEvent.eventKey)
        }
        
        Globals.recordAnalyticsEvent(eventType: "set_async_updaters")
    }

    func setOPRUpdater(forEventKey eventKey: String) {
        backgroundQueue.sync {
            let timer = FASTBackgroundTimer(withInterval: 60 * 8) {[weak self] in
                guard self != nil else {
                    return
                }
                //Reload OPR
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of oprs for event \(eventKey) completed with errors \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListEventOPRs", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_oprs", attributes: ["successful":successful.description])
                })
            }

            timer.resume()

            self.oprTimedUpdaters[eventKey] = timer
        }
    }

    func removeOPRUpdaters(forEventKey eventKey: String) {
        oprTimedUpdaters[eventKey] = nil
    }

    func setMatchUpdater(forEventKey eventKey: String) {
        backgroundQueue.sync {
            let timer = FASTBackgroundTimer(withInterval: 60 * 3) { [weak self] in
                guard self != nil else {
                    return
                }
                Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of matches for event \(eventKey) completed with errors \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
                    
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListMatches", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_matches", attributes: ["successful":successful.description])
                })
            }

            timer.resume()

            self.matchTimedUpdaters[eventKey] = timer
        }
    }

    func removeMatchUpdater(forEventKey eventKey: String) {
        matchTimedUpdaters[eventKey] = nil
    }

    func setStatusesUpdater(forEvent eventKey: String) {
        backgroundQueue.sync {
            let timer = FASTBackgroundTimer(withInterval: 60 * 4) { [weak self] in
                guard self != nil else {
                    return
                }
                
                Globals.appDelegate.appSyncClient?.fetch(query: ListTeamEventStatusesQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of team statuses for event \(eventKey) completed with errors \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
                    
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListTeamEventStatuses", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_event_statuses", attributes: ["successful":successful.description])
                })
            }

            timer.resume()

            self.statusTimedUpdaters[eventKey] = timer
        }
    }

    func removeStatusesUpdater(forEvent eventKey: String) {
        statusTimedUpdaters[eventKey] = nil
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
