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
    static var asyncLoadingManager: FASTAsyncManager?
    static var dataManager: AWSDataManager?
    
    //User Activity Types
    struct UserActivity {
        static let eventSelection = "com.kampmeier.eventSelection"
        static let viewTeamDetail = "com.kampmeier.viewTeamDetail"
    }
    
    ///Handles AppSync errors inline by logging and recording them
    ///- Returns: A bool signifiying if the query was successful or not
    static func handleAppSyncErrors<T>(forQuery queryIdentifier: String, result: GraphQLResult<T>?, error: Error?) -> Bool {
        var wereErrors = false
        if let error = error {
            if let error = error as? AWSAppSyncClientError {
                let handleNsError = {(nserr: NSError) in
                    if nserr.code == -999 {
                        //The error is that the operation was cancelled, do not treat as error
                        CLSNSLogv("Operation \(queryIdentifier) cancelled", getVaList([]))
                    } else if nserr.code == -1005 {
                        //The network connection was lost
                        CLSNSLogv("Operation \(queryIdentifier) terminated because the network connection was lost", getVaList([]))
                    } else if nserr.code == -1009 {
                        //Internet connection is offline
                        CLSNSLogv("Operation \(queryIdentifier) failed because the network connection is offline", getVaList([]))
                    } else if nserr.code == -1001 {
                        //Timed out
                        CLSNSLogv("Operation \(queryIdentifier) failed because the request timed out", getVaList([]))
                    } else if nserr.code == 53 {
                        CLSNSLogv("Operation \(queryIdentifier) canceled by the software", getVaList([]))
                    } else if nserr.code == -1003 {
                        
                        if #available(iOS 12.0, *) {
                            CLSNSLogv("Operation \(queryIdentifier) failed beccause a server with specified hostname could not be found. Is online: \(FASTNetworkManager.main.isOnline())", getVaList([]))
                            if FASTNetworkManager.main.isOnline() {
                                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["is-online":"true"])
                            }
                        } else {
                            // Fallback on earlier versions
                            CLSNSLogv("Operation \(queryIdentifier) failed beccause a server with specified hostname could not be found.", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["is-online":"true"])
                        }
                    } else {
                        CLSNSLogv("Error performing \(queryIdentifier): \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(nserr)
                    }
                }
                switch error {
                case .requestFailed( _,  _, let err):
                    if let nserr = err as NSError? {
                        handleNsError(nserr)
                    } else {
                        CLSNSLogv("Error performing \(queryIdentifier): \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .authenticationError(let error):
                    let nserr = error as NSError
                    handleNsError(nserr)
                default:
                    CLSNSLogv("Error performing \(queryIdentifier): \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    break
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
                CLSNSLogv("Error performing \(queryIdentifier): \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
            
            wereErrors = true
        }
        if let errors = result?.errors {
            CLSNSLogv("GraphQL Errors performing \(queryIdentifier): \(errors)", getVaList([]))
            for error in errors {
                Crashlytics.sharedInstance().recordError(error)
            }
            wereErrors = true
        }
        
        if result?.source == GraphQLResult<T>.Source.server {
            Globals.recordAnalyticsEvent(eventType: "app_sync_request", attributes: ["successful":(!wereErrors).description, "request":queryIdentifier])
        }
        
        return !wereErrors
    }
    
    static func presentError<T>(error: Error?, andResult result: GraphQLResult<T>?, withTitle title: String, hideIfIsOffline: Bool = true) {
        var shouldDisplay = true
        if let error = error as? AWSAppSyncClientError {
            let handleNsError = {(nserr: NSError) in
                if nserr.code == -1009 || nserr.code == -1001 {
                    //Is offline, request timed out
                    shouldDisplay = false && hideIfIsOffline
                }
            }
            switch error {
            case .requestFailed(_, _, let err):
                if let nserr = err as NSError? {
                    handleNsError(nserr)
                }
            case .authenticationError(let error):
                handleNsError(error as NSError)
            default:
                break
            }
        }
        
        if shouldDisplay {
            let alert = UIAlertController(title: "Unable to Load Teams", message: "There was an error loading the teams for this event. Please connect to the internet and re-load. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
        }
    }
    
    static func descriptions<T>(ofError error: Error?, andResult result: GraphQLResult<T>?) -> String {
        if let error = error as? AWSAppSyncClientError {
            return "\(error.errorDescription ?? "") \(error.recoverySuggestion ?? "")"
        } else if let error = error {
            return error.localizedDescription
        } else if let errors = result?.errors {
            return errors.description
        } else {
            return ""
        }
    }
    
    static func recordAnalyticsEvent(eventType: String, attributes: [String:String] = [:], metrics: [String: Double] = [:]) {
        //Now for Firebase Analytics
        Analytics.logEvent(eventType, parameters: (attributes as [String:Any]).merging((metrics as [String:Any]), uniquingKeysWith: {val1,val2 in attributes[val1 as! String] as Any}))
    }
}
