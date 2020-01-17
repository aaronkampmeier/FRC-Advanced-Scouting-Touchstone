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

class FASTInterestToken {
    private(set) var isValid: Bool
    private var cancelHandler: () -> Void
    
    init(withCancelHandler cancelHandler: @escaping () -> Void) {
        isValid = true
        self.cancelHandler = cancelHandler
    }
    
    internal func cancel() {
        if isValid {
            cancelHandler()
            invalidate()
        }
    }
    
    fileprivate func invalidate() {
        isValid = false
    }
}

/// For loading async OPRs, ranks, team statuses, match scores, and eventually insights
class FASTAsyncManager {

    private static let backgroundQueueID = "TBAUpdatingThread"
    private let operationQueue: OperationQueue
    private let backgroundQueue: DispatchQueue
    private let propertyAccessorQueue: DispatchQueue
    private var networkUpdater: FASTCancellable?
    
    /// Tracks all eventKeys that have timed updaters
    private var timedEventUpdaters: [String:[FASTBackgroundTimer]] {
        get {
            var value: [String:[FASTBackgroundTimer]]!
            
            propertyAccessorQueue.sync {
                value = self.unsafeTimedUpdaters
            }
            
            return value
        }
        
        set {
            propertyAccessorQueue.async(flags: .barrier) {[weak self] in
                self?.unsafeTimedUpdaters = newValue
            }
        }
    }
    /// Dictionary of all the eventKeys that have active delta syncs
    private var deltaSyncUpdaters: [String: [Cancellable?]]  {
        get {
            var value: [String:[Cancellable?]]!
            
            propertyAccessorQueue.sync {
                value = self.unsafeDeltaSyncUpdaters
            }
            
            return value
        }
        
        set {
            propertyAccessorQueue.async(flags: .barrier) {[weak self] in
                self?.unsafeDeltaSyncUpdaters = newValue
            }
        }
    }
    /// Tracks the number of interests in an eventKey. Once one hits zero, the event key's updaters and deltaSyncs are removed
    private var eventInterestsCount: [String:Int] {
        get {
            var value: [String:Int]!
            
            propertyAccessorQueue.sync {
                value = self.unsafeEventInterestsCount
            }
            
            return value
        }
        
        set {
            propertyAccessorQueue.async(flags: .barrier) {[weak self] in
                self?.unsafeEventInterestsCount = newValue
            }
        }
    }
    
    /// The competition model for each event key
    private(set) var eventModelStates: [String:FASTCompetitionModelState]  {
        get {
            var value: [String:FASTCompetitionModelState]!
            
            let workItem = DispatchWorkItem(qos: .userInteractive) {
                value = self.unsafeEventModelStates
            }
            propertyAccessorQueue.sync(execute: workItem)
            
            return value
        }
        
        set {
            propertyAccessorQueue.async(flags: .barrier) {[weak self] in
                self?.unsafeEventModelStates = newValue
            }
        }
    }
    
    // Must include these to make the other types thread safe: https://www.raywenderlich.com/5370-grand-central-dispatch-tutorial-for-swift-4-part-1-2
    private var unsafeTimedUpdaters = [String:[FASTBackgroundTimer]]()
    private var unsafeDeltaSyncUpdaters = [String:[Cancellable?]]()
    private var unsafeEventInterestsCount = [String:Int]()
    private var unsafeEventModelStates = [String:FASTCompetitionModelState]()
    
    
    private var addEventSubscription: AWSAppSyncSubscriptionWatcher<OnAddTrackedEventSubscription>?
    private var removeEventSubscription: AWSAppSyncSubscriptionWatcher<OnRemoveTrackedEventSubscription>?

    init() {
        //Create background thread for updating
        backgroundQueue = DispatchQueue(label: "com.kampmeier.FAST.AsyncManagerDispatchQueue", qos: .utility)
        
        operationQueue = OperationQueue()
        operationQueue.name = "com.kampmeier.FAST.AsyncManagerOpQueue"
        operationQueue.qualityOfService = .utility
        operationQueue.underlyingQueue = backgroundQueue
        
        propertyAccessorQueue = DispatchQueue(label: "com.kampmeier.FAST.AsyncManagerPropertyAccessorOpQueue", qos: .userInitiated)
        
        if #available(iOS 12.0, *) {
            networkUpdater = FASTNetworkManager.main.register {[weak self] (isConnected) in
                if isConnected {
                    CLSNSLogv("Resuming async updaters", getVaList([]))
                    self?.timedEventUpdaters.forEach {$0.value.forEach {$0.resume()}}
                } else {
                    CLSNSLogv("Pausing async updaters", getVaList([]))
                    self?.timedEventUpdaters.forEach {$0.value.forEach {$0.suspend()}}
                }
            }
        } else {
            // Fallback on earlier versions
            networkUpdater = nil
        }
        

        NotificationCenter.default.addObserver(forName: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: nil, queue: operationQueue) {[weak self] (notification) in
            self?.setUp(forScoutingTeam: Globals.dataManager.enrolledScoutingTeamID)
        }
        
    }
	
	deinit {
		networkUpdater?.cancel()
		addEventSubscription?.cancel()
		removeEventSubscription?.cancel()
	}
    
    internal func registerInterest(inEvent eventKey: String) -> FASTInterestToken {
        CLSNSLogv("Registering interest in \(eventKey)", getVaList([]))
        eventInterestsCount[eventKey] = (eventInterestsCount[eventKey] ?? 0) + 1
        
        //Check if any new updaters need to be made
        if timedEventUpdaters[eventKey] == nil {
            setTimedUpdaters(forEventKey: eventKey)
        }
        if deltaSyncUpdaters[eventKey] == nil {
            setDeltaSyncUpdaters(forEventKey: eventKey)
        }
        
        return FASTInterestToken {[weak self] in
            self?.operationQueue.addOperation {
                self?.eventInterestsCount[eventKey] = (self?.eventInterestsCount[eventKey] ?? 0) - 1
                CLSNSLogv("Cancelling interest in \(eventKey), remaining interest: \(String(describing: self?.eventInterestsCount[eventKey]))", getVaList([]))
                
                // Check if any events need to be removed
                // If an eventKey gets to 0 interested parties, remove its updaters and clear it out
                let uninterestedEvents = self?.eventInterestsCount.filter {$0.value <= 0} ?? [:]
                // Set the new interests without these events
                self?.eventInterestsCount = self!.eventInterestsCount.filter {eventInterestCount in !uninterestedEvents.contains {$0.key == eventInterestCount.key}}
                // Remove the timed updaters and cancellables from this event
                for event in uninterestedEvents {
                    CLSNSLogv("Removing all interest from event \(eventKey)", getVaList([]))
                    self?.timedEventUpdaters[event.key] = nil
                    self?.deltaSyncUpdaters[event.key]?.forEach {$0?.cancel()}
                    self?.deltaSyncUpdaters[event.key] = nil
                }
            }
        }
    }
    
    private func setUp(forScoutingTeam scoutingTeam: String?) {
        // Clear out past things
        operationQueue.isSuspended = true
        operationQueue.cancelAllOperations()
        timedEventUpdaters.removeAll()
        eventInterestsCount.removeAll()
        deltaSyncUpdaters.forEach {$0.value.forEach {$0?.cancel()}}
        deltaSyncUpdaters.removeAll()
        addEventSubscription?.cancel()
        removeEventSubscription?.cancel()
        operationQueue.isSuspended = false
        
        // Set up the basic subscriptions on tracked events
        if let _ = scoutingTeam {
            resetSubscriptions()
        }
        
    }
    
    //MARK: - Watching Tracked Events
    private func resetSubscriptions() {
        if let scoutingTeamID = Globals.dataManager.enrolledScoutingTeamID {
            addEventSubscription?.cancel()
            removeEventSubscription?.cancel()
            //Set updaters to listen for new/deleted events
            do {
                #warning("Reinstate")
//                addEventSubscription = try Globals.appSyncClient?.subscribe(subscription: OnAddTrackedEventSubscription(scoutTeam: scoutingTeamID), resultHandler: {[weak self] (result, transaction, error) in
//                    if Globals.handleAppSyncErrors(forQuery: "AsyncLoader-OnAddTrackedEventSubscription", result: result, error: error) {
//                        if let newEvent = result?.data?.onAddTrackedEvent {
//                            do {
//                                try transaction?.update(query: ListTrackedEventsQuery(scoutTeam: scoutingTeamID), { (selectionSet) in
//                                    selectionSet.listTrackedEvents?.append(try ListTrackedEventsQuery.Data.ListTrackedEvent(newEvent))
//                                })
//                            } catch {
//                                CLSNSLogv("Error updating ListTrackedEvents cache \(error)", getVaList([]))
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        }
//                    } else {
//                        if let error = error as? AWSAppSyncSubscriptionError {
//                            if error.recoverySuggestion != nil {
//                                self?.resetSubscriptions()
//                            } else {
//                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5 * 60, execute: {[weak self] in
//                                    self?.resetSubscriptions()
//                                })
//                            }
//                        }
//                    }
//                })
//                
//                removeEventSubscription = try Globals.appSyncClient?.subscribe(subscription: OnRemoveTrackedEventSubscription(scoutTeam: scoutingTeamID), resultHandler: {[weak self] (result, transaction, error) in
//                    if Globals.handleAppSyncErrors(forQuery: "AsyncLoader-OnRemoveTrackedEventSubscription", result: result, error: error) {
//                        if let removedEvent = result?.data?.onRemoveTrackedEvent {
//                            do {
//                                try transaction?.update(query: ListTrackedEventsQuery(scoutTeam: scoutingTeamID), { (selectionSet) in
//                                    selectionSet.listTrackedEvents?.removeAll(where: {$0?.eventKey == removedEvent.eventKey})
//                                })
//                            } catch {
//                                CLSNSLogv("Error updating ListTrackedEvents cache \(error)", getVaList([]))
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        }
//                    } else {
//                        if let error = error as? AWSAppSyncSubscriptionError {
//                            if error.recoverySuggestion != nil {
//                                self?.resetSubscriptions()
//                            } else {
//                                if #available(iOS 12.0, *) {
//                                    FASTNetworkManager.main.registerUpdateOnReconnect {
//                                        self?.resetSubscriptions()
//                                    }
//                                } else {
//                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5 * 50, execute: {
//                                        self?.resetSubscriptions()
//                                    })
//                                }
//                            }
//                        }
//                    }
//                })
            } catch {
                CLSNSLogv("Error setting subscriptions on the Async Loading Manager", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
        }
	}

    //MARK: - Setting Timed Updaters
    private func setTimedUpdaters(forEventKey eventKey: String) {
        operationQueue.addOperation {
            CLSNSLogv("Setting timed updaters for \(eventKey)", getVaList([]))
            
            
            self.eventModelStates[eventKey] = FASTCompetitionModelState.Loading
            let competitionModelTimer = FASTBackgroundTimer(withInterval: 60 * 60 * 24 * 2) {[weak self] in
                Globals.appSyncClient?.fetch(query: GetCompetitionModelQuery(year: eventKey.trimmingCharacters(in: CharacterSet.letters)), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "GetCompetitionModel", result: result, error: error) {
                        if let resultData = result?.data?.getCompetitionModel?.data(using: .utf8) {
                            self?.eventModelStates[eventKey] = FASTCompetitionModelState.load(withJson: resultData)
                        } else {
                            self?.eventModelStates[eventKey] = .Error(NSError(domain: "FASTErrorConvertingCompetitionModelToData", code: 1, userInfo: nil))
                        }
                    } else {
                        //TODO: Retry the query a bit later if the failure was due to no interent connection
                        self?.eventModelStates[eventKey] = .Error(error ?? NSError(domain: "FASTUnknownError", code: 2, userInfo: nil))
                    }
                })
            }
            competitionModelTimer.resume()
            
            let oprTimer = FASTBackgroundTimer(withInterval: 60 * 8) {[weak self] in
                //Reload OPR
                Globals.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of oprs for event \(eventKey) completed", getVaList([]))
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListEventOPRs", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_oprs", attributes: ["successful":successful.description])
                })
            }
            oprTimer.resume()
            
            let matchTimer = FASTBackgroundTimer(withInterval: 60 * 3) { [weak self] in
                Globals.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of matches for event \(eventKey) completed", getVaList([]))
                    
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListMatches", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_matches", attributes: ["successful":successful.description])
                })
            }

            matchTimer.resume()
            
            let statusTimer = FASTBackgroundTimer(withInterval: 60 * 4) { [weak self] in
                
                Globals.appSyncClient?.fetch(query: ListTeamEventStatusesQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: self!.backgroundQueue, resultHandler: { (result, error) in
                    CLSNSLogv("Background reload of team statuses for event \(eventKey) completed", getVaList([]))
                    
                    let successful = Globals.handleAppSyncErrors(forQuery: "AsyncManager-ListTeamEventStatuses", result: result, error: error)
                    Globals.recordAnalyticsEvent(eventType: "async_loaded_event_statuses", attributes: ["successful":successful.description])
                })
            }

            statusTimer.resume()
            
            
            self.timedEventUpdaters[eventKey] = [oprTimer, matchTimer, statusTimer, competitionModelTimer]
            
            Globals.recordAnalyticsEvent(eventType: "set_timed_updaters")
        }
    }
    
    private func setDeltaSyncUpdaters(forEventKey eventKey: String) {
        if let scoutTeamID = Globals.dataManager.enrolledScoutingTeamID {
            operationQueue.addOperation {
                CLSNSLogv("Setting delta sync updaters for \(eventKey)", getVaList([]))
                
                //Start the scout sessions delta sync
                #warning("Reinstate this line once subscriptions are fixed")
//                Globals.dataManager.registerCaching(ofEventKey: eventKey)
                let config = SyncConfiguration(baseRefreshIntervalInSeconds: 6 * 60 * 60)
                let perfTrace = Performance.startTrace(name: "ScoutSessions Delta Sync Base Query")
//                perfTrace?.start()
                
                #warning("Reinstate the delta sync when the AWS AppSync team fixes their thing")
                let scoutSessionsSync: Cancellable? = nil
//                let scoutSessionsSync = Globals.appSyncClient?.sync(baseQuery: ListAllScoutSessionsQuery(scoutTeam: scoutTeamID, eventKey: eventKey), baseQueryResultHandler: { (result, error) in
//                    if Globals.handleAppSyncErrors(forQuery: "ListAllScoutSessions-Base", result: result, error: error) {
//                        let numOfSessions = result?.data?.listAllScoutSessions?.count ?? 0
//                        perfTrace?.setValue(Int64(numOfSessions), forMetric: "sessions_returned")
//                        CLSNSLogv("Ran ListAllScoutSessions Base Query with source: \(String(describing: result?.source)) with \(numOfSessions) sessions", getVaList([]))
//
//                        //Set the in memory cache of scout sessions
//                        Globals.dataManager.setCachedScoutSessions(scoutSessions: result?.data?.listAllScoutSessions?.map({$0?.fragments.scoutSession}), toEventKey: eventKey)
//                    }
//                    perfTrace?.stop()
//                    Globals.dataManager.endCaching(ofEventKey: eventKey)
//                }, subscription: OnCreateScoutSessionSubscription(scoutTeam: scoutTeamID, eventKey: eventKey), subscriptionResultHandler: { (result, transaction, error) in
//                    CLSNSLogv("Scout Sessions Subscription Fired", getVaList([]))
//                    if Globals.handleAppSyncErrors(forQuery: "OnCreateScoutSessionSubscription-DeltaSync", result: result, error: error) {
//                        //Add the new scout session to the cache
//                        if let newSession = result?.data?.onCreateScoutSession {
//                            do {
//                                let perfTrace = Performance.startTrace(name: "Scout Session Subscription Cache Update")
//                                try transaction?.update(query: ListAllScoutSessionsQuery(scoutTeam: scoutTeamID, eventKey: eventKey), { (selectionSet) in
//                                    if !(selectionSet.listAllScoutSessions?.contains(where: {$0?.key == newSession.key}) ?? false) {
//                                        do {
//                                            selectionSet.listAllScoutSessions?.append(try ListAllScoutSessionsQuery.Data.ListAllScoutSession(newSession))
//                                        } catch {
//                                            CLSNSLogv("Error appending scout session to the cache: \(newSession) \(error)", getVaList([]))
//                                        }
//                                    }
//                                    perfTrace?.stop()
//                                })
//
//                                //Update the in memory cache
//                                if !(Globals.dataManager.cachedScoutSessions[eventKey]??.contains(where: {$0?.key == newSession.key}) ?? false) {
//                                    Globals.dataManager.cachedScoutSessions[eventKey]??.append(newSession.fragments.scoutSession)
//                                }
//                            } catch {
//                                CLSNSLogv("Error updating the scout session cache: \(error)", getVaList([]))
//                                Crashlytics.sharedInstance().recordError(error)
//                            }
//                        }
//                    }
//                }, deltaQuery: ListScoutSessionsDeltaQuery(scoutTeam: scoutTeamID, eventKey: eventKey, lastSync: 0), deltaQueryResultHandler: { (result, transaction, error) in
//                    if Globals.handleAppSyncErrors(forQuery: "ListScoutSessionsDelta", result: result, error: error) {
//                        let numOfUpdates = result?.data?.listScoutSessionsDelta?.count ?? 0
//                        CLSNSLogv("Got delta update of scout sessions with \(numOfUpdates) updates", getVaList([]))
//                        //Add the new scout session to the cache
//                        do {
//                            let perfTrace = Performance.startTrace(name: "Scout Sessions Delta Cache Update")
//                            perfTrace?.setValue(Int64(numOfUpdates), forMetric: "sessions_returned")
//                            try transaction?.update(query: ListAllScoutSessionsQuery(scoutTeam: scoutTeamID, eventKey: eventKey), { (selectionSet) in
//                                for session in result?.data?.listScoutSessionsDelta ?? [] {
//                                    if let newSession = session {
//                                        if !(selectionSet.listAllScoutSessions?.contains(where: {$0?.key == newSession.key}) ?? false) {
//                                            selectionSet.listAllScoutSessions?.append(try ListAllScoutSessionsQuery.Data.ListAllScoutSession(newSession))
//                                        }
//
//                                        //Update the in memory cache
//                                        if !(Globals.dataManager.cachedScoutSessions[eventKey]??.contains(where: {$0?.key == newSession.key}) ?? false) {
//                                            Globals.dataManager.cachedScoutSessions[eventKey]??.append(newSession.fragments.scoutSession)
//                                        }
//                                    }
//                                }
//                                perfTrace?.stop()
//                            })
//                        } catch {
//                            CLSNSLogv("Error updating the scout session cache: \(error)", getVaList([]))
//                            Crashlytics.sharedInstance().recordError(error)
//                        }
//
//                        Globals.recordAnalyticsEvent(eventType: "scoutsessions_delta_update", metrics: ["update_count":Double(numOfUpdates)])
//                    }
//                }, callbackQueue: self.backgroundQueue, syncConfiguration: config)
//
                
                let updateScoutedTeamSubscriber: Cancellable?
                do {
                    #warning("")
                    updateScoutedTeamSubscriber = nil
//                    updateScoutedTeamSubscriber = try Globals.appSyncClient?.subscribe(subscription: OnUpdateScoutedTeamsSubscription(scoutTeam: scoutTeamID, eventKey: eventKey), queue: self.backgroundQueue, resultHandler: {[weak self] (result, transaction, error) in
//                        if Globals.handleAppSyncErrors(forQuery: "OnUpdateScoutedTeamGeneral", result: result, error: error) {
//                            ((try? transaction?.update(query: ListScoutedTeamsQuery(scoutTeam: scoutTeamID, eventKey: eventKey), { (selectionSet) in
//                                if let index = selectionSet.listScoutedTeams?.firstIndex(where: {$0?.teamKey == result?.data?.onUpdateScoutedTeam?.teamKey}) {
//                                    selectionSet.listScoutedTeams?.remove(at: index)
//                                }
//                                if let newTeam = result?.data?.onUpdateScoutedTeam {
//                                    selectionSet.listScoutedTeams?.append(try! ListScoutedTeamsQuery.Data.ListScoutedTeam(newTeam))
//                                }
//                            })) as ()??)
//
//                            //TODO: Update the scouted team image cache
//                        } else {
//                            if let error = error as? AWSAppSyncSubscriptionError {
//                                if error.recoverySuggestion != nil {
//                                    self?.resetSubscriptions()
//                                }
//                            }
//                        }
//                    })
                } catch {
                    CLSNSLogv("Error starting the scouted team subscriber", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    updateScoutedTeamSubscriber = nil
                }
                
                self.deltaSyncUpdaters[eventKey] = [scoutSessionsSync, updateScoutedTeamSubscriber]
                
                Globals.recordAnalyticsEvent(eventType: "set_delta_sync_updaters")
            }
        }
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
    
    /// Executes the timer's eventHandler and continues the regularly scheduled timer
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
        
        eventHandler?()
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
