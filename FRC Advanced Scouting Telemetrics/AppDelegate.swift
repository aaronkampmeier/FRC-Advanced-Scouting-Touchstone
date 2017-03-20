//  AppDelegate.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Fabric
import Crashlytics

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		Fabric.with([Answers.self, Crashlytics.self])
		Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
		
		DataSyncer.begin()
		
		clearTMPFolder()
		
        return true
    }
	
	func clearTMPFolder() {
        do {
            try FileManager.default.removeItem(atPath: NSTemporaryDirectory())
        } catch {
            CLSNSLogv("Unable to clear temporary directory.", getVaList([]))
        }
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		processEnsembleChanges()
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
        self.saveContext()
		processEnsembleChanges()
    }
	
	func processEnsembleChanges() {
		let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
		DispatchQueue.global().async {
			self.managedObjectContext.perform() {
				self.saveContext()
				DataSyncer.sharedDataSyncer().ensemble.processPendingChanges() {error in
					if let error = error {NSLog("Unable to process pending changes in the background with error: \(error)")} else {NSLog("Processing pending changes in the background completed.")}
					UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
				}
			}
		}
	}
	
	func presentViewControllerOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		DispatchQueue.main.async {
			self.window?.rootViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: flag, completion: completion)
		}
	}

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.kampmeier.FRC_Advanced_Scouting_Telemetrics" in the application's documents Application Support directory.
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = Bundle.main.url(forResource: "FRC_Advanced_Scouting_Telemetrics", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
	
	var managedObjectModelURL: URL {
		return Bundle.main.url(forResource: "FRC_Advanced_Scouting_Telemetrics", withExtension: "momd")!
	}

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        CLSNSLogv("Creating Persistent Store Coordinator", getVaList([]))
        //Options for Lightweight migration
        var options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode":"DELETE"],
        ] as [String : Any]
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		//Get the url for both persistent stores
        let url = self.applicationDocumentsDirectory.appendingPathComponent("UniversalData.sqlite")
		let localDataURL = self.applicationDocumentsDirectory.appendingPathComponent("LocalData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
			//Add both persistent stores
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "Universal", at: url, options: options)
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "Local", at: localDataURL, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "FAST-CD Error Domain", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            CLSNSLogv("Unresolved error \(wrappedError), \(wrappedError.userInfo)", getVaList([]))
            Crashlytics.sharedInstance().recordError(wrappedError)
            
            //Error code 134110 means that the coordinator was unable to migrate the store to a newer model version. If this happens then alert the user and present them with the option to erase all data and recreate the store.
            let restoreDataAction = UIAlertAction(title: "Restore and Exit", style: .destructive) {alertAction in
                do {
                    try FileManager.default.removeItem(at: url)
                    try FileManager.default.removeItem(at: localDataURL)
                    NSLog("Removed old persistent stores to restore data.")
                    exit(2)
                } catch {
                    
                }
            }
            let freezeDataAction = UIAlertAction(title: "Keep Data and Wait for a Fix", style: .default) {action in
                let alert = UIAlertController(title: "Apologies", message: "We are extremely sorry for any inconvenience and are working on a fix.", preferredStyle: .alert)
                appDelegate.presentViewControllerOnTop(alert, animated: true)
            }
            
            if (error as NSError).code == 134110 {
                let alert = UIAlertController(title: "Internal Error", message: "A problem was detected with the saved data. It is necessary to restore all data. Reopen the app after completion. (This is to be expected if you have updated from a version previous to 2.2.1 (618))", preferredStyle: .alert)
                alert.addAction(freezeDataAction)
                alert.addAction(restoreDataAction)
                
                appDelegate.presentViewControllerOnTop(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Internal Error", message: "There was a problem initializing the saved data.", preferredStyle: .alert)
                alert.addAction(freezeDataAction)
                alert.addAction(restoreDataAction)
                appDelegate.presentViewControllerOnTop(alert, animated: true)
            }
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        CLSNSLogv("Getting Managed Object Context", getVaList([]))
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
		managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return managedObjectContext
    }()
	
	lazy var localPersistentStoreURL: URL = {
		return self.applicationDocumentsDirectory.appendingPathComponent("LocalData.sqlite")
	}()
	
	lazy var universalPersistentStoreURL: URL = {
		return self.applicationDocumentsDirectory.appendingPathComponent("UniversalData.sqlite")
	}()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                Crashlytics.sharedInstance().recordError(nserror)
                
                let alert = UIAlertController(title: "Error Saving", message: "There was an error saving data.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                presentViewControllerOnTop(alert, animated: true)
            }
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
