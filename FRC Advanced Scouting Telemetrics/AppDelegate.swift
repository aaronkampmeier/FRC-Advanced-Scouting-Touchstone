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
    
    // MARK: App Did Finish Launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isUsingScenes = (UIDevice.current.systemVersion as NSString).floatValue >= 13
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        // AWS Cognito Initialization
        AWSMobileClient.default().initialize {userState, error in
            if let userState = userState {
                CLSNSLogv("User State: \(userState)", getVaList([]))
                
                switch userState {
                case .signedOut:
                    if !isUsingScenes {
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "onboarding")
                    }
                    break
                case .signedIn:
                    if !isUsingScenes {
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                    }
                case .guest:
                    if !isUsingScenes {
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "onboarding")
                    }
                    break
                default:
                    CLSNSLogv("Signing out due to invalid userState", getVaList([]))
                    AWSMobileClient.default().signOut()
                }
            } else if let error = error {
                CLSNSLogv("Error: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            } else {
                assertionFailure()
            }
        }
        
        Globals.dataManager = AWSDataManager()
        
        if !isUsingScenes {
            AWSMobileClient.default().addUserStateListener(self) { (state, attributes) in
                DispatchQueue.main.async {
                    switch state {
                    case .signedOut:
                        //Show the sign in flow
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "onboarding")
                    case .signedIn:
                        self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                    case .guest:
                        if Globals.isInSpectatorMode {
                            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "teamListMasterVC")
                        } else {
                            //Show sign in
                            self.window?.rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "onboarding")
                        }
                    default:
                        break
                    }
                }
            }
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
    
    func performAnyStandardMigrations() {
        //Check if there needs to be a migration to the new user system introduced in FAST version 5
        let hasMigratedTo5Authentication = "hasMigratedTo5Authentication"
        if !(UserDefaults.standard.value(forKey: hasMigratedTo5Authentication) as? Bool ?? false) {
            //Migrate to the new system by logging out the current user and deatuhenticating their tokens
            
        }
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
