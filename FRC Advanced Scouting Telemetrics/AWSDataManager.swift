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
    var cachedScoutSessions: (eventKey: String, scoutSessions: [ScoutSession?]?) = (eventKey: "", scoutSessions: [ScoutSession?]())
    let utilityWorkQueue = DispatchQueue(label: "FASTDataManagerUtility", qos: .utility)
    let foregroundWorkQueue = DispatchQueue(label: "FASTDataManagerForeground", qos: .userInitiated)
    
    init() {
    }
    
    func signOut() {
        AWSMobileClient.sharedInstance().signOut()
        
        //Show the onboarding
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        Globals.appDelegate.window?.rootViewController = vc
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
            
            while self.cachedScoutSessions.eventKey == "" {
                
            }
            
            //Fetching hundreds of records from the SQLite cache everytime this function is called is inefficient, so we'll store all of the scout sessions in memory for multiple calls
            if self.cachedScoutSessions.eventKey == eventKey {
                //There are values cached, use them
                filterAndReturn(self.cachedScoutSessions.scoutSessions)
            } else {
//                self.beginScoutSessionCaching(withEventKey: eventKey)
                
                filterAndReturn([])
                
                //Has loaded everything now, try again
//                self.retrieveScoutSessions(forEventKey: eventKey, teamKey: teamKey, andMatchKey: matchKey, withCallback: callbackHandler)
            }
        }
    }
    
//    private var scoutSessionWatcher: GraphQLQueryWatcher<ListAllScoutSessionsQuery>?
//    private func beginScoutSessionCaching(withEventKey eventKey: String) {
//        scoutSessionWatcher?.cancel()
//        let group = DispatchGroup()
//        var hasLeft = false
//        group.enter()
//        scoutSessionWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListAllScoutSessionsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataDontFetch, queue: DispatchQueue.global(qos: .utility), resultHandler: {[weak self] (result, error) in
//            if Globals.handleAppSyncErrors(forQuery: "ListAllScoutSessions-UpdateInMemoryCache", result: result, error: error) {
//                self?.cachedScoutSessions = (eventKey, result?.data?.listAllScoutSessions?.map({$0?.fragments.scoutSession}))
//            }
//
//            if !hasLeft {
//                hasLeft = true
//                group.leave()
//            }
//        })
//        group.wait()
//    }
    
    func inMemoryCacheScoutSessions(scoutSessions: [ScoutSession?]?, forEventKey eventKey: String) {
        self.cachedScoutSessions = (eventKey, scoutSessions)
    }
}

class FASTAppSyncStateChangeHandler: ConnectionStateChangeHandler {
    func stateChanged(networkState: ClientNetworkAccessState) {
        CLSNSLogv("App Sync Connection State Changed: \(networkState)", getVaList([]))
    }
}
