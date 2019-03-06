//  AppDelegate.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AWSAppSync
import AWSMobileClient
import AWSAuthCore
import AWSAuthUI
import Firebase
import AWSS3

internal struct Globals {
    static unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let isSpectatorModeKey = "FAST-IsInSpectatorMode"
    static var isInSpectatorMode: Bool {
        return UserDefaults.standard.value(forKey: isSpectatorModeKey) as? Bool ?? false
    }
    static var asyncLoadingManager: TBAUpdatingDataReloader?
    
    ///Handles AppSync errors inline by logging and recording them
    ///- Returns: A bool signifiying if the query was successful or not
    static func handleAppSyncErrors<T>(forQuery queryIdentifier: String, result: GraphQLResult<T>?, error: Error?) -> Bool {
        var wereErrors = false
        if let error = error {
            if let error = error as? AWSAppSyncClientError {
                switch error {
                case .requestFailed( _,  _, let err):
                    if let nserr = err as NSError? {
                        if nserr.code == -999 {
                            //The error is that the operation was cancelled, do not treat as error
                            CLSNSLogv("Operation \(queryIdentifier) cancelled", getVaList([]))
                            break
                        }
                        fallthrough
                    }
                    fallthrough
                default:
                    CLSNSLogv("Error performing \(queryIdentifier): \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    break
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
//        let event = Globals.appDelegate.pinpoint?.analyticsClient.createEvent(withEventType: eventType)
//        for attribute in attributes {
//            event?.addAttribute(attribute.value, forKey: attribute.key)
//        }
//        for metric in metrics {
//            event?.addMetric(NSNumber(value: metric.value), forKey: metric.key)
//        }
//
//        Globals.appDelegate.pinpoint?.analyticsClient.record(event!)
//        Globals.appDelegate.pinpoint?.analyticsClient.submitEvents()
        
        //Now for Firebase Analytics
        Analytics.logEvent(eventType, parameters: (attributes as [String:Any]).merging((metrics as [String:Any]), uniquingKeysWith: {val1,val2 in attributes[val1 as! String] as Any}))
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var appSyncClient: AWSAppSyncClient?
//    var pinpoint: AWSPinpoint?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        ///AWS Cognito Initialization
        AWSMobileClient.sharedInstance().initialize {userState, error in
            if let userState = userState {
                CLSNSLogv("User State: \(userState)", getVaList([]))
                Analytics.setUserID(AWSMobileClient.sharedInstance().username)
                Crashlytics.sharedInstance().setUserName(AWSMobileClient.sharedInstance().username)
                Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.name)
                
                switch userState {
                case .signedOut:
                    //Let the onboarding show to sign in; Do nothing
                    break
                case .signedIn:
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                    Analytics.setUserProperty(AWSMobileClient.sharedInstance().username, forName: "teamNumber")
                case .guest:
                    if Globals.isInSpectatorMode {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                    }
                default:
                    CLSNSLogv("Signing out due to invalid userState", getVaList([]))
                    AWSMobileClient.sharedInstance().signOut()
                }
            } else if let error = error {
                CLSNSLogv("Error: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            } else {
                assertionFailure()
            }
        }
        
        ///AWS App Sync Config
        let databaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("FASTAppSyncDatabase")
        do {
            
            let serviceConfig = try AWSAppSyncServiceConfig()
            
//            let appSyncConfig = try AWSAppSyncClientConfiguration(url: URL(string: "")!, serviceRegion: .USEast1, userPoolsAuthProvider: FASTCognitoUserPoolsAuthProvider(), databaseURL: databaseURL, connectionStateChangeHandler: FASTAppSyncStateChangeHandler(), s3ObjectManager: AWSS3TransferUtility.default())
//            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: serviceConfig, databaseURL: databaseURL)
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncClientInfo: AWSAppSyncClientInfo(), userPoolsAuthProvider: FASTCognitoUserPoolsAuthProvider(), databaseURL: databaseURL)
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            appSyncClient?.apolloClient?.cacheKeyForObject = {
                switch $0["__typename"] as! String {
                case "EventRanking":
                    return "ranking_\($0["eventKey"]!)"
                case "ScoutedTeam":
                    return "scouted_\($0["eventKey"]!)_\($0["teamKey"]!)"
                case "TeamEventOPR":
                    return "opr_\($0["eventKey"]!)_\($0["teamKey"]!)"
                case "TeamEventStatus":
                    return "status_\($0["eventKey"]!)_\($0["teamKey"]!)"
                default:
                    return $0["key"]
                }
            }
        } catch {
            CLSNSLogv("Error starting AppSync: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
            assertionFailure()
        }
        
        AWSMobileClient.sharedInstance().addUserStateListener(self) { (state, attributes) in
            CLSNSLogv("New User State: \(state)", getVaList([]))
            
            //Update the pinpoint endpoint profile
//            if let targetingClient = self.pinpoint?.targetingClient {
//                let endpoint = targetingClient.currentEndpointProfile()
//
//                let user = AWSPinpointEndpointProfileUser()
//
//                if state == UserState.signedIn {
//                    user.userId = AWSMobileClient.sharedInstance().username
//                } else {
//                    user.userId = nil
//                }
//
//                endpoint.user = user
//                targetingClient.update(endpoint)
//            }
            
            if state == UserState.signedOut {
                self.appSyncClient?.clearCache()
                Globals.asyncLoadingManager = nil
                
                //Clear the Images cache
                TeamImageLoader.default.clearCache()
            } else if state == UserState.signedIn {
                Globals.asyncLoadingManager = TBAUpdatingDataReloader()
            }
            
            
            Analytics.setUserID(AWSMobileClient.sharedInstance().username)
            Analytics.setUserProperty(AWSMobileClient.sharedInstance().username, forName: "teamNumber")
            Crashlytics.sharedInstance().setUserName(AWSMobileClient.sharedInstance().username)
        }
        
        //Set up the reloading manager
        if AWSMobileClient.sharedInstance().currentUserState == .signedIn {
            Globals.asyncLoadingManager = TBAUpdatingDataReloader()
        }
        
        return true
//        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func displayLogin(isRegistering: Bool, onVC currentVC: UIViewController) {
        //Present log in screen
        let loginVC = LoginViewController(style: .darkOpaque)
        loginVC.isCancelButtonHidden = false
        loginVC.isCopyrightLabelHidden = true
        
        loginVC.authenticationProvider = AWSCognitoAuthenticationProvider()
        
        loginVC.loginSuccessfulHandler = {result in
            UserDefaults.standard.set(false, forKey: Globals.isSpectatorModeKey)
            loginVC.dismiss(animated: false, completion: nil)
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
        }
        
        loginVC.setRegistering(isRegistering, animated: false)
        
        currentVC.present(loginVC, animated: true, completion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func presentViewControllerOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.window?.rootViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

//Adds a function to UIViewController to allow presenting views (i.e. alerts) on the top view controller from lower view controllers
extension UIViewController {
    func presentViewControllerFromVisibleViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let navigationController = self as? UINavigationController, let topViewController = navigationController.topViewController {
            topViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else if (presentedViewController != nil) {
            presentedViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}

extension AWSMobileClientError {
    var message: String {
        get {
            switch self {
            case .aliasExists(let mesg):
                return mesg
            case .codeDeliveryFailure(let mesg):
                return mesg
            case .codeMismatch(let mesg):
                return mesg
            case .expiredCode(let mesg):
                return mesg
            case .groupExists(let mesg):
                return mesg
            case .internalError(let mesg):
                return mesg
            case .invalidLambdaResponse(let mesg):
                return mesg
            case .invalidOAuthFlow(let mesg):
                return mesg
            case .invalidParameter(let mesg):
                return mesg
            case .invalidPassword(let mesg):
                return mesg
            case .invalidUserPoolConfiguration(let mesg):
                return mesg
            case .limitExceeded(let mesg):
                return mesg
            case .mfaMethodNotFound(let mesg):
                return mesg
            case .notAuthorized(let mesg):
                return mesg
            case .passwordResetRequired(let mesg):
                return mesg
            case .resourceNotFound(let mesg):
                return mesg
            case .scopeDoesNotExist(let mesg):
                return mesg
            case .softwareTokenMFANotFound(let mesg):
                return mesg
            case .tooManyFailedAttempts(let mesg):
                return mesg
            case .tooManyRequests(let mesg):
                return mesg
            case .unexpectedLambda(let mesg):
                return mesg
            case .userLambdaValidation(let mesg):
                return mesg
            case .userNotConfirmed(let mesg):
                return mesg
            case .userNotFound(let mesg):
                return mesg
            case .usernameExists(let mesg):
                return mesg
            case .unknown(let mesg):
                return mesg
            case .notSignedIn(let mesg):
                return mesg
            case .identityIdUnavailable(let mesg):
                return mesg
            case .guestAccessNotAllowed(let mesg):
                return mesg
            case .federationProviderExists(let mesg):
                return mesg
            case .cognitoIdentityPoolNotConfigured(let mesg):
                return mesg
            case .unableToSignIn(let mesg):
                return mesg
            case .invalidState(let mesg):
                return mesg
            case .userPoolNotConfigured(let mesg):
                return mesg
            case .userCancelledSignIn(let mesg):
                return mesg
            }
        }
    }
}
