//
//  Globals.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 7/26/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSAppSync
import Crashlytics
import Firebase

//MARK: - Globals
internal struct Globals {
    static unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let isSpectatorModeKey = "FAST-IsInSpectatorMode"
    static var isInSpectatorMode: Bool {
        return UserDefaults.standard.value(forKey: isSpectatorModeKey) as? Bool ?? false
    }
    
    static var dataManager: AWSDataManager!
    static var appSyncClient: AWSAppSyncClient?
    
    //User Activity Types
    struct UserActivity {
        static let eventSelection = "com.kampmeier.eventSelection"
        static let viewTeamDetail = "com.kampmeier.viewTeamDetail"
    }
    
    /// Handles AppSync errors inline by logging and recording them
    /// - Returns: A bool signifiying if the query was successful or not
    /// - Parameters:
    ///   - queryIdentifier: A unique string identifying all queries made by this operation
    ///   - result: Pass in the result object
    ///   - error: Pass in the error object
    static func handleAppSyncErrors<T>(forQuery queryIdentifier: String, result: GraphQLResult<T>?, error: Error?, shouldDisplayErrors: Bool = true) -> Bool {
        var wereErrors = false
        
        //TODO: Put following errors into this array and display
        var errorMessages = [String]()
        
        if let error = error {
            if let error = error as? AWSAppSyncClientError {
                
                let handleNsError = {(nserr: NSError) in
                    if nserr.code == -999 {
                        //The error is that the operation was cancelled, do not treat as error
                        CLSNSLogv("Operation \(queryIdentifier) cancelled", getVaList([]))
                    } else if nserr.code == -1005 {
                        //The network connection was lost
                        errorMessages.append("Operation \(queryIdentifier) terminated because the network connection was lost")
                    } else if nserr.code == -1009 {
                        //Internet connection is offline
                        CLSNSLogv("Operation \(queryIdentifier) failed because the network connection is offline", getVaList([]))
                    } else if nserr.code == -1001 {
                        //Timed out
                        errorMessages.append("Operation \(queryIdentifier) failed because the request timed out")
                    } else if nserr.code == 53 {
                        CLSNSLogv("Operation \(queryIdentifier) canceled by the software", getVaList([]))
                    } else if nserr.code == -1003 {
                        
                        if #available(iOS 12.0, *) {
                            errorMessages.append("Operation \(queryIdentifier) failed beccause a server with specified hostname could not be found. Is online: \(FASTNetworkManager.main.isOnline())")
                            if FASTNetworkManager.main.isOnline() {
                                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["is-online":"true"])
                            }
                        } else {
                            // Fallback on earlier versions
                            errorMessages.append("Operation \(queryIdentifier) failed beccause a server with specified hostname could not be found.")
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    } else {
                        errorMessages.append("Error: \(error)")
                        Crashlytics.sharedInstance().recordError(nserr)
                    }
                }
                
                switch error {
                case .requestFailed(_,_, let err):
                    if let nserr = err as NSError? {
                        handleNsError(nserr)
                    } else {
                        errorMessages.append("Request Failed: \(error)")
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .authenticationError(let error):
                    let nserr = error as NSError
                    handleNsError(nserr)
                case .noData(_):
                    errorMessages.append("No Data: \(error)")
                    Crashlytics.sharedInstance().recordError(error)
                case .parseError(_,_, let err):
                    if let err = err {
                        errorMessages.append("Parse Error: \(err)")
                        Crashlytics.sharedInstance().recordError(err)
                    } else {
                        errorMessages.append("Parse Error: \(error)")
                        Crashlytics.sharedInstance().recordError(error)
                    }
                }
                
            } else if let error = error as? AWSAppSyncSubscriptionError {
                if error.recoverySuggestion != nil {
                    //There is a recovery suggestion, don't treat as error
                } else {
                    if error.errorDescription?.contains("-1001") ?? false || error.errorDescription?.contains("-1009") ?? false {
                        //Internet is offline, no error
                    } else {
                        CLSNSLogv("Error subscribing to \(queryIdentifier): \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    }
                }
            } else {
                errorMessages.append("Error: \(error)")
                Crashlytics.sharedInstance().recordError(error)
            }
            
            wereErrors = true
        }
        if let errors = result?.errors {
            errorMessages.append("GraphQL Errors performing \(queryIdentifier): \(errors)")
            for error in errors {
                Crashlytics.sharedInstance().recordError(error)
            }
            wereErrors = true
        }
        
        //Display potential errors if the request came from the server
        if errorMessages.count > 0 {
            CLSNSLogv("Error performing \(queryIdentifier): \(errorMessages)", getVaList([]))
            
            
            if result?.source == GraphQLResult<T>.Source.server && shouldDisplayErrors {
                //Display the errors
                let alert = UIAlertController(title: "Error Performing \(queryIdentifier)", message: "\(errorMessages)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
            }
        }
        
        if result?.source == GraphQLResult<T>.Source.server {
            Globals.recordAnalyticsEvent(eventType: "app_sync_request", attributes: ["successful":(!wereErrors).description, "request":queryIdentifier])
        }
        
        return !wereErrors
    }
    
    static func recordAnalyticsEvent(eventType: String, attributes: [String:String] = [:], metrics: [String: Double] = [:]) {
        //Now for Firebase Analytics
        Analytics.logEvent(eventType, parameters: (attributes as [String:Any]).merging((metrics as [String:Any]), uniquingKeysWith: {val1,val2 in attributes[val1 as! String] as Any}))
    }
}


class FASTAppSyncClient {
    internal let appSyncClient: AWSAppSyncClient
    
    internal init(appSyncClient: AWSAppSyncClient) {
        self.appSyncClient = appSyncClient
    }
    
    
    internal func fetch<Query>(query: Query, readableId: String, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: ((GraphQLResult<Query.Data>?, Error?) -> Void)? = nil) -> Cancellable where Query : GraphQLQuery {
        return appSyncClient.fetch(query: query, cachePolicy: cachePolicy, queue: queue) {[weak self] (result, error) in
            //Handle the AppSync response and then call the result handler
//            self?.handleAppSyncErrors(forQuery: readableId, result: result, error: error)
            resultHandler?(result,error)
        }
    }
    
    /// Handles AppSync errors inline by logging and recording them
    /// - Returns: A bool signifiying if the query was successful or not
    /// - Parameters:
    ///   - queryIdentifier: A unique string identifying all queries made by this operation
    ///   - result: Pass in the result object
    ///   - error: Pass in the error object
//    @discardableResult private func handleAppSyncErrors<T>(forQuery queryIdentifier: String, result: GraphQLResult<T>?, error: Error?) -> Bool {
//
//    }
}
