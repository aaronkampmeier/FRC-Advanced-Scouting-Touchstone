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
import Firebase
import FirebasePerformance

///For loading async OPRs, ranks, team statuses, match scores, and eventually insights

///Sole job is to reload data from cloud not retrieve
class FASTAsyncManager {

    static let backgroundQueueID = "TBAUpdatingThread"
    private var backgroundQueue: DispatchQueue

    //Event Key is key
    private var oprTimedUpdaters = [String:FASTBackgroundTimer]()
    private var matchTimedUpdaters = [String:FASTBackgroundTimer]()
    private var statusTimedUpdaters = [String:FASTBackgroundTimer]()
    private var scoutSessionDeltaSync: Cancellable?
    
    private var addEventSubscription: AWSAppSyncSubscriptionWatcher<OnAddTrackedEventSubscription>?
    private var removeEventSubscription: AWSAppSyncSubscriptionWatcher<OnRemoveTrackedEventSubscription>?
    var trackedEventWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    var trackedEvents = [ListTrackedEventsQuery.Data.ListTrackedEvent]()

    init() {
        //Create background thread for updating
        backgroundQueue = DispatchQueue.global(qos: .utility) //DispatchQueue(label: FASTAsyncManager.backgroundQueueID, qos: .utility)

        resetSubscriptions()
        
        getTrackedEvents()
    }
    
    func getTrackedEvents() {
        trackedEventWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery-AsyncManager", result: result, error: error) {
                self?.trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
//                self?.setGeneralUpdaters()
            } else {
                self?.getTrackedEvents()
            }
        })
    }
    
    func resetSubscriptions() {
        addEventSubscription?.cancel()
        removeEventSubscription?.cancel()
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
                    if let error = error as? AWSAppSyncSubscriptionError {
                        if error.recoverySuggestion != nil {
                            self?.resetSubscriptions()
                        }
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
                    if let error = error as? AWSAppSyncSubscriptionError {
                        if error.recoverySuggestion != nil {
                            self?.resetSubscriptions()
                        }
                    }
                }
            })
        } catch {
            CLSNSLogv("Error setting subscriptions on the Async Loading Manager", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    deinit {
        addEventSubscription?.cancel()
        removeEventSubscription?.cancel()
        scoutSessionDeltaSync?.cancel()
    }

	var selectedEventKey: String?
    ///Sets basic, general updaters; will remove all existing ones on call
    func setGeneralUpdaters(forEventKey eventKey: String?) {
		guard eventKey != selectedEventKey else {
			return
		}
		selectedEventKey = eventKey
		CLSNSLogv("Setting async updaters for \(eventKey ?? "?")", getVaList([]))
        oprTimedUpdaters.removeAll()
        matchTimedUpdaters.removeAll()
        statusTimedUpdaters.removeAll()
        scoutSessionDeltaSync?.cancel()
        
        if let eventKey = eventKey {
            self.setOPRUpdater(forEventKey: eventKey)
            self.setMatchUpdater(forEventKey: eventKey)
            self.setStatusesUpdater(forEvent: eventKey)
            
            //Start the scout sessions delta sync
			Globals.dataManager?.currentlyCachingEvents.append(eventKey)
            let config = SyncConfiguration(baseRefreshIntervalInSeconds: 6 * 60 * 60)
			let perfTrace = Performance.startTrace(name: "ScoutSessions Delta Sync Base Query")
//			perfTrace?.start()
            self.scoutSessionDeltaSync = Globals.appDelegate.appSyncClient?.sync(baseQuery: ListAllScoutSessionsQuery(eventKey: eventKey), baseQueryResultHandler: { (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListAllScoutSessions-Base", result: result, error: error) {
                    let numOfSessions = result?.data?.listAllScoutSessions?.count ?? 0
					perfTrace?.setValue(Int64(numOfSessions), forMetric: "sessions_returned")
                    CLSNSLogv("Ran ListAllScoutSessions Base Query with source: \(String(describing: result?.source)) with \(numOfSessions) sessions", getVaList([]))
                    
                    //Set the in memory cache of scout sessions
                    Globals.dataManager?.cachedScoutSessions[eventKey] = result?.data?.listAllScoutSessions?.map({$0?.fragments.scoutSession})
                }
				perfTrace?.stop()
				if let index = Globals.dataManager?.currentlyCachingEvents.firstIndex(of: eventKey) {
					Globals.dataManager?.currentlyCachingEvents.remove(at: index)
				}
            }, subscription: OnCreateScoutSessionSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey), subscriptionResultHandler: { (result, transaction, error) in
                CLSNSLogv("Scout Sessions Subscription Fired", getVaList([]))
                if Globals.handleAppSyncErrors(forQuery: "OnCreateScoutSessionSubscription-DeltaSync", result: result, error: error) {
                    //Add the new scout session to the cache
                    if let newSession = result?.data?.onCreateScoutSession {
                        do {
							let perfTrace = Performance.startTrace(name: "Scout Session Subscription Cache Update")
                            try transaction?.update(query: ListAllScoutSessionsQuery(eventKey: eventKey), { (selectionSet) in
                                if !(selectionSet.listAllScoutSessions?.contains(where: {$0?.key == newSession.key}) ?? false) {
                                    selectionSet.listAllScoutSessions?.append(try ListAllScoutSessionsQuery.Data.ListAllScoutSession(newSession))
                                }
								perfTrace?.stop()
                            })
                            
                            //Update the in memory cache
                            if !(Globals.dataManager?.cachedScoutSessions[eventKey]??.contains(where: {$0?.key == newSession.key}) ?? false) {
                                Globals.dataManager?.cachedScoutSessions[eventKey]??.append(newSession.fragments.scoutSession)
                            }
                        } catch {
                            CLSNSLogv("Error updating the scout session cache: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                }
            }, deltaQuery: ListScoutSessionsDeltaQuery(eventKey: eventKey, lastSync: 0), deltaQueryResultHandler: { (result, transaction, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutSessionsDelta", result: result, error: error) {
                    let numOfUpdates = result?.data?.listScoutSessionsDelta?.count ?? 0
                    CLSNSLogv("Got delta update of scout sessions with \(numOfUpdates) updates", getVaList([]))
                    //Add the new scout session to the cache
                    do {
						let perfTrace = Performance.startTrace(name: "Scout Sessions Delta Cache Update")
						perfTrace?.setValue(Int64(numOfUpdates), forMetric: "sessions_returned")
                        try transaction?.update(query: ListAllScoutSessionsQuery(eventKey: eventKey), { (selectionSet) in
                            for session in result?.data?.listScoutSessionsDelta ?? [] {
                                if let newSession = session {
                                    if !(selectionSet.listAllScoutSessions?.contains(where: {$0?.key == newSession.key}) ?? false) {
                                        selectionSet.listAllScoutSessions?.append(try ListAllScoutSessionsQuery.Data.ListAllScoutSession(newSession))
                                    }
                                    
                                    //Update the in memory cache
                                    if !(Globals.dataManager?.cachedScoutSessions[eventKey]??.contains(where: {$0?.key == newSession.key}) ?? false) {
                                        Globals.dataManager?.cachedScoutSessions[eventKey]??.append(newSession.fragments.scoutSession)
                                    }
                                }
                            }
							perfTrace?.stop()
                        })
                    } catch {
                        CLSNSLogv("Error updating the scout session cache: \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    }
                    
                    Globals.recordAnalyticsEvent(eventType: "scoutsessions_delta_update", metrics: ["update_count":Double(numOfUpdates)])
                }
            }, callbackQueue: backgroundQueue, syncConfiguration: config)
            
            Globals.recordAnalyticsEvent(eventType: "set_event_async_updaters")
        }
    }

    func setOPRUpdater(forEventKey eventKey: String) {
        backgroundQueue.sync {
            let timer = FASTBackgroundTimer(withInterval: 60 * 8) {[weak self] in
                guard self != nil else {
                    return
                }
                //Reload OPR
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of oprs for event \(eventKey) completed \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
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
                    CLSNSLogv("Background reload of matches for event \(eventKey) completed \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
                    
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
                    CLSNSLogv("Background reload of team statuses for event \(eventKey) completed \(Globals.descriptions(ofError: error, andResult: result))", getVaList([]))
                    
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
