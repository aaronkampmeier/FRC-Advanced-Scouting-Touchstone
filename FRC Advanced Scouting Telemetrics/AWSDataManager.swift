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
    //Tuple of event key and scout sessions
    var cachedScoutSessions: [String: [ScoutSession?]?] = [:]
    var currentlyCachingEvents = [String]()
    let utilityWorkQueue = DispatchQueue(label: "FASTDataManagerUtility", qos: .utility)
    let foregroundWorkQueue = DispatchQueue(label: "FASTDataManagerForeground", qos: .userInitiated)
    
    //Track signed in user information
    var userClaims: CognitoIDTokenClaims?
    var userSub: String? {
        return userClaims?.sub
    }
    struct CognitoIDTokenClaims: Decodable {
        let atHash: String
        let sub: String
        let emailVerified: Bool
        let aud: String
        let email: String
    }
    //Tracking current signed in scouting team
    private(set) var enrolledScoutingTeamID: GraphQLID?
    private(set) var scoutingTeamMembershipStatus: ScoutingTeamMembershipStatus = .Invalid
    
    init() {
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
    func changeUserState(to state: UserState) {
        CLSNSLogv("New User State: \(state)", getVaList([]))
        
        userClaims = nil
        
        switch state {
        case .signedOut:
            do {
                try Globals.appSyncClient?.clearCaches()
            } catch {
                CLSNSLogv("Error clearing app sync cache: \(error)", getVaList([]))
            }
            Globals.asyncLoadingManager = nil
            
            //Clear the Images cache
            TeamImageLoader.default.clearCache()
        case .signedIn:
//            Globals.asyncLoadingManager = FASTAsyncManager()
            
            //Get the new user attributes from their id token
            AWSMobileClient.default().getTokens { (tokens, error) in
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
    
    func signOut() {
        AWSMobileClient.default().signOut(options: SignOutOptions(signOutGlobally: false, invalidateTokens: true)) { (error) in
            if let error = error {
                CLSNSLogv("Error signing out: \(error)", getVaList([]))
            }
        }
    }
    
    //TODO: Add the fast async manager to reset in here
    /// Sets up resources for working in the new scouting team
    /// - Parameter newScoutingTeam: The new scouting team
    func switchCurrentScoutingTeam(to newScoutingTeam: ScoutingTeam) {
        enrolledScoutingTeamID = newScoutingTeam.teamId
        if newScoutingTeam.teamLead == AWSMobileClient.default().username ?? "" {
            self.scoutingTeamMembershipStatus = .Lead
        } else {
            self.scoutingTeamMembershipStatus = .Member
        }
        
        //Send out a notification about the update
        NotificationCenter.default.post(name: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: self, userInfo: ["scoutingTeam":newScoutingTeam.teamId])
    }
    
    func switchCurrentScoutingTeam(to newScoutingTeam: ScoutingTeamWithMembers) {
        do {
            let scoutingTeam = try ScoutingTeam(newScoutingTeam)
            switchCurrentScoutingTeam(to: scoutingTeam)
        } catch {
            CLSNSLogv("Error converting scoutingTeamWithMembers to scouting team", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    enum ScoutingTeamMembershipStatus {
        case Lead
        case Member
        case Invalid
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
        Globals.appSyncClient?.fetch(query: ListAllScoutSessionsQuery(scoutTeam: enrolledScoutingTeamID ?? "", eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.global(qos: .utility), resultHandler: {[weak self] (result, error) in
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
