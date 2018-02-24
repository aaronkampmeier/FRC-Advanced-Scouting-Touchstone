//  AppDelegate.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import AWSMobileClient

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		Fabric.with([Answers.self, Crashlytics.self])
        
        //Check if the user is logged in
        if RealmController.realmController.currentSyncUser != nil {
            //We are logged in, switch to the team list view
        } else {
            //Show log in page
            displayLogin()
        }
		
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
//        clearTMPFolder()
		
//        return true
    }
    
    func displayLogin() {
        //Present log in screen
        let loginVC = LoginViewController(style: .darkOpaque)
        loginVC.isCancelButtonHidden = true
        loginVC.serverURL = RealmController.realmController.syncAuthURL.absoluteString
        loginVC.isSecureConnection = true
        loginVC.isServerURLFieldHidden = true
        
        //TODO: Extract these into seperate file (or don't to make them harder to find)
        loginVC.authenticationProvider = AWSCognitoAuthenticationProvider()
        
        loginVC.loginSuccessfulHandler = {user,teamNumber in
            RealmController.realmController.currentSyncUser = user
            RealmController.realmController.openSyncedRealm(withSyncUser: user)
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        }
        self.window?.rootViewController = loginVC
    }
	
	func clearTMPFolder() {
        //Clear the temporary folder as it can build up lots of unneeded ensembles data. However, at this time Fabric is probably downloading some settings from the cloud so we need to avoid deleting those files.
        do {
            for file in try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
                if !file.hasPrefix("CFNetworkDownload") {
                    try FileManager.default.removeItem(atPath: NSTemporaryDirectory().appending(file))
                }
            }
        } catch {
            CLSNSLogv("Unable to clear temporary directory with error: \(error)", getVaList([]))
        }
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
