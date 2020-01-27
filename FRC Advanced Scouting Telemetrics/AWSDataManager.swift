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
import Firebase

extension Notification.Name {
    static let FASTAWSDataManagerCurrentScoutingTeamChanged = Notification.Name(rawValue: "AWSDataManagerCurrentScoutingTeamChanged")
}

class AWSDataManager {
    internal let asyncLoadingManager: FASTAsyncManager = FASTAsyncManager()
    private let operationQueue = OperationQueue()
    
    /// Tuple of event key and scout sessions
    private let cachedScoutSessionsAccessQueue = DispatchQueue(label: "com.kampmeier.FAST.DataManagerCachedScoutSessionsAccess", qos: .userInitiated)
//    private let cachedScoutSessionsDictSeamphore = DispatchSemaphore(value: 1)
    private var cachedScoutSessions: [String: [ScoutSession?]?] = [:]
    
    private let scoutSessionCachingGroupsDictSemaphore = DispatchSemaphore(value: 1)
    /// Dispatch groups for each event key that controls access to the cachedScoutSessions available in cachedScoutSessions dictionary, one all operations for the cachedScoutSessions group are done, then it's good to access the cachedScoutSessions
    private var scoutSessionCachingGroups = [String:DispatchGroup]()
    
//    /// A semaphore that controls access to the scoutSessionCachingSemaphore dictionary
//    private let scoutSessionCachingSemaphoreDictSemaphore = DispatchSemaphore(value: 1)
//    /// Holds a count for each event of the number of scout session caching operations going on
//    private var scoutSessionCachingCount: [String:Int] = [:]
    
//    private let scoutSessionQueue = DispatchQueue(label: "com.kampmeier.FAST.DataManagerScoutSessions", qos: .utility)
    private let utilityWorkQueue = DispatchQueue(label: "com.kampmeier.FAST.DataManagerUtility", qos: .utility)
    private let foregroundWorkQueue = DispatchQueue(label: "com.kampmeier.FAST.DataManager.ForegroundWork", qos: .userInitiated)
    
    // Track signed in user information
    internal var userClaims: CognitoIDTokenClaims?
    internal var userSub: String? {
        return userClaims?.sub
    }
    internal struct CognitoIDTokenClaims: Decodable {
        let atHash: String
        let sub: String
        let emailVerified: Bool?
        let aud: String
        let email: String?
        let name: String?
        
        let identities: [CognitoIDTokenClaimsIndentity]?
        
        var primaryIdentity: CognitoIDTokenClaimsIndentity? {
            get {
                if let primary = identities?.first(where: {$0.isPrimary ?? false}) {
                    return primary
                } else {
                    return identities?.first
                }
            }
        }
    }
    internal struct CognitoIDTokenClaimsIndentity: Decodable {
        let userId: String?
        let providerName: String?
        let providerType: String?
        private let primary: String?
        internal var isPrimary: Bool? {
            if let primary = primary {
                return primary == "true"
            } else {
                return false
            }
        }
        let issuer: String?
        private let dateCreated: String?
        internal var dateCreatedDate: Date? {
            if let dateCreated = dateCreated, let time = Double(dateCreated) {
                return Date(timeIntervalSince1970: time)
            } else {
                return nil
            }
        }
    }
    
    //Tracking current signed in scouting team
    private let scoutingTeamCacheKey = "FASTCurrentlyScoutingTeamIDKey"
    private(set) var enrolledScoutingTeamID: GraphQLID?
    
    init() {
        operationQueue.name = "AWSDataManagerScoutingTeamChanges"
        operationQueue.isSuspended = true
        
        // AWS App Sync Config
        _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("FASTAppSyncDatabase")
        do {
            let serviceConfig = try AWSAppSyncServiceConfig()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: serviceConfig, userPoolsAuthProvider: FASTCognitoUserPoolsAuthProvider(), connectionStateChangeHandler: FASTAppSyncStateChangeHandler())
            Globals.appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            Globals.appSyncClient?.apolloClient?.cacheKeyForObject = {
                switch $0["__typename"] as! String {
                case "EventRanking":
                    return "ranking_\($0["eventKey"]!)"
                case "ScoutedTeam":
                    return "scouted_\($0["eventKey"]!)_\($0["teamKey"]!)"
                case "TeamEventOPR":
                    return "opr_\($0["eventKey"]!)_\($0["teamKey"]!)"
                case "TeamEventStatus":
                    return "status_\($0["eventKey"]!)_\($0["teamKey"]!)"
                case "ScoutingTeam":
                    return "scoutingTeam_\($0["teamID"]!)"
                case "ScoutingTeamWithMembers":
                    return "scoutingTeamMembers_\($0["teamID"]!)"
                case "ScoutTeamInvitation":
                    return "scoutTeamInvitation_\($0["inviteID"]!)"
                default:
                    return $0["key"]
                }
            }
        } catch {
            CLSNSLogv("Error starting AppSync: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
            assertionFailure()
        }
        
        Globals.appSyncClient?.offlineMutationDelegate = FASTOfflineMutationDelegate()
        
        AWSMobileClient.default().addUserStateListener(self) { (state, attributes) in
            self.changeUserState(to: state)
        }
        changeUserState(to: AWSMobileClient.default().currentUserState)
        
    }
    
    
    /// Handles switching over app resources to use a new user
    /// - Parameter state: The new user state
    private func changeUserState(to state: UserState) {
        CLSNSLogv("New User State: \(state)", getVaList([]))
        
        userClaims = nil
        
        switch state {
        case .signedOut:
            //Clear the caches
            do {
                try Globals.appSyncClient?.clearCaches()
            } catch {
                CLSNSLogv("Error clearing app sync cache: \(error)", getVaList([]))
            }
            TeamImageLoader.default.clearCache()
            
            //Dump the scouting team
            switchCurrentScoutingTeam(to: nil)
        case .signedIn:
            //Get the new user attributes from their id token
            AWSMobileClient.default().getTokens { (tokens, error) in
                self.utilityWorkQueue.async {
                    if let error = error {
                        CLSNSLogv("Error getting AWS Auth tokens: \(error)", getVaList([]))
                    }
                    
                    if let idToken = tokens?.idToken?.tokenString {
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .secondsSince1970
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            let tokenSplit = idToken.split(separator: ".")
                            let claimsPayload = tokenSplit[1]
                            
                            //The following code was 100% copied from the AWSMobileClientExtensions code that does the same thing but doesn't put it into a Struct
                            let paddedLength = claimsPayload.count + (4 - (claimsPayload.count % 4)) % 4
                            //JWT is not padded with =, pad it if necessary
                            let updatedClaims = claimsPayload.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
                            let claimsData = Data.init(base64Encoded: updatedClaims, options: .ignoreUnknownCharacters)!
                            self.userClaims = try decoder.decode(CognitoIDTokenClaims.self, from: claimsData)
                        } catch {
                            CLSNSLogv("Error decoding the id token: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                }
            }
            
            
            if let scoutingTeamId = UserDefaults.standard.value(forKey: scoutingTeamCacheKey) as? String {
                switchCurrentScoutingTeam(to: scoutingTeamId)
            }
            break
        case .signedOutUserPoolsTokenInvalid:
            fallthrough
        case .signedOutFederatedTokensInvalid:
            Globals.dataManager.signOut()
            break
        case .guest:
            break
        case .unknown:
            break
        }
        
        //Update analytics identifiers
        Analytics.setUserID(AWSMobileClient.default().username)
        Crashlytics.sharedInstance().setUserIdentifier(AWSMobileClient.default().username)
        //            Analytics.setUserProperty(AWSMobileClient.default().username, forName: "teamNumber")
    }
    
    internal func signOut() {
        AWSMobileClient.default().signOut(options: SignOutOptions(signOutGlobally: false, invalidateTokens: true)) { (error) in
            if let error = error {
                CLSNSLogv("Error signing out: \(error)", getVaList([]))
            }
        }
    }
    
    /// Switches the data manager over to the new scouting team and sends out a notification of type .FASTAWSDataManagerCurrentScoutingTeamChanged that the scouting team has changed.
    /// - Parameter newScoutingTeamId: The new scouting team id
    internal func switchCurrentScoutingTeam(to newScoutingTeamId: String?) {
        operationQueue.addOperation {
            //Check that the user is authorized on this team
            if let teamId = newScoutingTeamId {
                Globals.appSyncClient?.fetch(query: ListEnrolledScoutingTeamsQuery(), cachePolicy: .fetchIgnoringCacheData, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "ListEnrolledScoutingTeams-DataManagerCheckEnrollment", result: result, error: error) {
                        let enrolledScoutingTeams = result?.data?.listEnrolledScoutingTeams
                        if !(enrolledScoutingTeams?.contains(where: {$0?.teamId == teamId}) ?? true) {
                            //Switch to no scouting team
                            self.switchCurrentScoutingTeam(to: nil)
                        }
                    }
                })
            }
            
            UserDefaults.standard.set(newScoutingTeamId, forKey: self.scoutingTeamCacheKey)
            self.enrolledScoutingTeamID = newScoutingTeamId
            
            self.cachedScoutSessionsAccessQueue.async(qos: .userInitiated, flags: .barrier) {
                self.cachedScoutSessions.removeAll()
            }
            self.scoutSessionCachingGroupsDictSemaphore.wait()
            self.scoutSessionCachingGroups.removeAll()
            self.scoutSessionCachingGroupsDictSemaphore.signal()
            do {
                try Globals.appSyncClient?.clearCaches()
            } catch {
                CLSNSLogv("Error clearing the AppSync cache on change of scouting team: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
            
            //Send out a notification about the update
            NotificationCenter.default.post(name: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: self, userInfo: ["scoutingTeam":newScoutingTeamId as Any])
        }
    }
    /// Sets up resources for working in the new scouting team
    /// - Parameter newScoutingTeam: The new scouting team
    internal func switchCurrentScoutingTeam(to newScoutingTeam: ScoutingTeam) {
        self.switchCurrentScoutingTeam(to: newScoutingTeam.teamId)
    }
    
    internal func switchCurrentScoutingTeam(to newScoutingTeam: ScoutingTeamWithMembers) {
        self.switchCurrentScoutingTeam(to: newScoutingTeam.teamId)
    }
    /// ONLY CALL FROM APPDELEGATE (when the app starts). If the scouting team switching was available during init of this class, then some dependencies might not be ready, so wait until this class is actually initialized and then begin the switching of socuting teams. This function is called from the AppDelegate.
    internal func beginScoutingTeamSwitching() {
        operationQueue.isSuspended = false
    }
    
    
    //MARK: - Managing Scout Sessions
    internal func registerCaching(ofEventKey eventKey: String) {
//        scoutSessionCachingSemaphoreDictSemaphore.wait()
//        scoutSessionCachingCount[eventKey] = scoutSessionCachingCount[eventKey] ?? 0 + 1
//        scoutSessionCachingSemaphoreDictSemaphore.signal()
        
        //Set a semaphore to zero for this event key
        scoutSessionCachingGroupsDictSemaphore.wait()
        let group = scoutSessionCachingGroups[eventKey] ?? DispatchGroup()
        group.enter()
        scoutSessionCachingGroups[eventKey] = group
        scoutSessionCachingGroupsDictSemaphore.signal()
    }
    
    internal func endCaching(ofEventKey eventKey: String) {
//        scoutSessionCachingSemaphoreDictSemaphore.wait()
//        let newCount = scoutSessionCachingCount[eventKey] ?? 0 - 1
//        scoutSessionCachingCount[eventKey] = newCount
//        scoutSessionCachingSemaphoreDictSemaphore.signal()
        
        //Leave the group
        scoutSessionCachingGroupsDictSemaphore.wait()
        scoutSessionCachingGroups[eventKey]?.leave()
        scoutSessionCachingGroupsDictSemaphore.signal()
    }
    
    internal func setCachedScoutSessions(scoutSessions: [ScoutSession?]?, toEventKey eventKey: String) {
//        cachedScoutSessionsDictSeamphore.wait()
        cachedScoutSessionsAccessQueue.sync(flags: .barrier) {
            self.cachedScoutSessions[eventKey] = scoutSessions
        }
//        cachedScoutSessionsDictSeamphore.signal()
    }
    
    internal func retrieveScoutSessions(forEventKey eventKey: String, teamKey: String, andMatchKey matchKey: String? = nil, withCallback callbackHandler: @escaping (([ScoutSession?]?) -> Void)) {
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
            
            //Wait for all caching events to finish
            let cachingGroup: DispatchGroup?
            self.scoutSessionCachingGroupsDictSemaphore.wait()
            cachingGroup = self.scoutSessionCachingGroups[eventKey]
            self.scoutSessionCachingGroupsDictSemaphore.signal()
            cachingGroup?.wait()
            
            // Fetching hundreds of records from the SQLite cache everytime this function is called is inefficient, so we'll store all of the scout sessions in memory for multiple calls
            let scoutSessions = self.cachedScoutSessionsAccessQueue.sync {() -> [ScoutSession?]? in
                return self.cachedScoutSessions[eventKey] ?? nil
            }
            if let scoutSessions = scoutSessions {
                // There are values cached, use them
                filterAndReturn(scoutSessions)
            } else {
                // Cache scout sessions
                self.cacheScoutSessions(withEventKey: eventKey)
                self.retrieveScoutSessions(forEventKey: eventKey, teamKey: teamKey, withCallback: callbackHandler)
//                filterAndReturn(nil)
            }
        }
    }
    
//    private var scoutSessionWatcher: GraphQLQueryWatcher<ListAllScoutSessionsQuery>?
    private func cacheScoutSessions(withEventKey eventKey: String) {
        CLSNSLogv("Caching scout sessions manually for event: \(eventKey)", getVaList([]))
        registerCaching(ofEventKey: eventKey)
        let group = DispatchGroup()
        var hasLeft = false
        group.enter()
        Globals.appSyncClient?.fetch(query: ListAllScoutSessionsQuery(scoutTeam: enrolledScoutingTeamID ?? "", eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.global(qos: .utility), resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListAllScoutSessions-UpdateInMemoryCache", result: result, error: error) {
                self?.setCachedScoutSessions(scoutSessions: result?.data?.listAllScoutSessions?.map({$0?.fragments.scoutSession}), toEventKey: eventKey)
            }

            if !hasLeft {
                hasLeft = true
                self?.endCaching(ofEventKey: eventKey)
                group.leave()
            }
        })
        group.wait()
    }
}

