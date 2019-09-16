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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    ///DEPRECATED  in iOS 13. Use SceneDelegate's window instead.
    var window: UIWindow?
    
    var supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    var appSyncClient: AWSAppSyncClient?
    
    // MARK: App Did Finish Launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        Globals.dataManager = AWSDataManager()
        
        // AWS Cognito Initialization
        AWSMobileClient.sharedInstance().initialize {userState, error in
            if let userState = userState {
                CLSNSLogv("User State: \(userState)", getVaList([]))
                Analytics.setUserID(AWSMobileClient.sharedInstance().username)
                Crashlytics.sharedInstance().setUserName(AWSMobileClient.sharedInstance().username)
                Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.name)
                
                switch userState {
                case .signedOut:
                    break
                case .signedIn:
                    Analytics.setUserProperty(AWSMobileClient.sharedInstance().username, forName: "teamNumber")
                case .guest:
                    break
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
        
        // AWS App Sync Config
        _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("FASTAppSyncDatabase")
        do {
            let serviceConfig = try AWSAppSyncServiceConfig()
			let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: serviceConfig, userPoolsAuthProvider: FASTCognitoUserPoolsAuthProvider(), connectionStateChangeHandler: FASTAppSyncStateChangeHandler())
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
		
		appSyncClient?.offlineMutationDelegate = FASTOfflineMutationDelegate()
        
        AWSMobileClient.sharedInstance().addUserStateListener(self) { (state, attributes) in
            CLSNSLogv("New User State: \(state)", getVaList([]))
            
            if state == UserState.signedOut {
                let _ = self.appSyncClient?.clearCache()
                Globals.asyncLoadingManager = nil
                
                //Clear the Images cache
                TeamImageLoader.default.clearCache()
            } else if state == UserState.signedIn {
                Globals.asyncLoadingManager = FASTAsyncManager()
            }
			
			if state == UserState.signedOutUserPoolsTokenInvalid || state == UserState.signedOutFederatedTokensInvalid {
				//Show the sign in screen
				AWSDataManager.default.signOut()
			}
            
            
            Analytics.setUserID(AWSMobileClient.sharedInstance().username)
            Analytics.setUserProperty(AWSMobileClient.sharedInstance().username, forName: "teamNumber")
            Crashlytics.sharedInstance().setUserName(AWSMobileClient.sharedInstance().username)
        }
        
        // Set up the reloading manager
        if AWSMobileClient.sharedInstance().currentUserState == .signedIn {
            Globals.asyncLoadingManager = FASTAsyncManager()
        }
        
        return true
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
    
    //MARK: Scene Support
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Dynamic", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        config.storyboard = UIStoryboard(name: "Main", bundle: nil)
        return config
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedInterfaceOrientations
    }
}

//MARK: - Additional stuff
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
			case .badRequest(let message):
				return message
			case .expiredRefreshToken(let message):
				return message
			case .errorLoadingPage(let message):
				return message
			case .securityFailed(let message):
				return message
			case .idTokenNotIssued(let message):
				return message
			case .idTokenAndAcceessTokenNotIssued(let message):
				return message
			case .invalidConfiguration(let message):
				return message
			case .deviceNotRemembered(let message):
				return message
			}
        }
    }
}
