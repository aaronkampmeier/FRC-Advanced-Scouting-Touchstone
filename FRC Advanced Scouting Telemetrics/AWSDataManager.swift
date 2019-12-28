//
//  AWSDataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/19/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import AWSMobileClient
import AWSAppSync
import AWSS3

class AWSDataManager {
    static unowned let `default`: AWSDataManager = Globals.dataManager!
    
    //Tuple of event key and scout sessions
    var cachedScoutSessions: [String: [ScoutSession?]?] = [:]
    var currentlyCachingEvents = [String]()
    let utilityWorkQueue = DispatchQueue(label: "FASTDataManagerUtility", qos: .utility)
    let foregroundWorkQueue = DispatchQueue(label: "FASTDataManagerForeground", qos: .userInitiated)
    
    init() {
    }
    
    func signOut() {
        AWSMobileClient.default().signOut()
    }
    
    func retrieveScoutSessions(forEventKey eventKey: String, teamKey: String, andMatchKey matchKey: String? = nil, withCallback callbackHandler: @escaping (([ScoutSession?]?) -> Void)) {
        foregroundWorkQueue.async {
            let filterAndReturn = {(scoutSessions: [ScoutSession?]?) -> Void in
                var filtered: [ScoutSession?]?
                if let matchKey = matchKey {
                    filtered = scoutSessions?.filter({
                        $0?.teamKey == teamKey && $0?.matchKey == matchKey
                    })
                } else {
                    filtered = scoutSessions?.filter({
                        $0?.teamKey == teamKey
                    })
                }
                callbackHandler(filtered)
            }
            
            while self.currentlyCachingEvents.contains(eventKey) {
                
            }
            
            //Fetching hundreds of records from the SQLite cache everytime this function is called is inefficient, so we'll store all of the scout sessions in memory for multiple calls
            if let scoutSessions = self.cachedScoutSessions[eventKey] {
                //There are values cached, use them
                filterAndReturn(scoutSessions)
            } else {
                //Cache scout sessions
                self.cacheScoutSessions(withEventKey: eventKey)
                self.retrieveScoutSessions(forEventKey: eventKey, teamKey: teamKey, withCallback: callbackHandler)
//                filterAndReturn(nil)
            }
        }
    }
    
//    private var scoutSessionWatcher: GraphQLQueryWatcher<ListAllScoutSessionsQuery>?
    private func cacheScoutSessions(withEventKey eventKey: String) {
        CLSNSLogv("Caching scout sessions manually for event: \(eventKey)", getVaList([]))
        self.currentlyCachingEvents.append(eventKey)
        let group = DispatchGroup()
        var hasLeft = false
        group.enter()
        Globals.appDelegate.appSyncClient?.fetch(query: ListAllScoutSessionsQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.global(qos: .utility), resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListAllScoutSessions-UpdateInMemoryCache", result: result, error: error) {
                self?.cachedScoutSessions[eventKey] = result?.data?.listAllScoutSessions?.map({$0?.fragments.scoutSession})
            }

            if !hasLeft {
                hasLeft = true
                group.leave()
            }
            if let index = self?.currentlyCachingEvents.firstIndex(of: eventKey) {
                self?.currentlyCachingEvents.remove(at: index)
            }
        })
        group.wait()
    }
}
