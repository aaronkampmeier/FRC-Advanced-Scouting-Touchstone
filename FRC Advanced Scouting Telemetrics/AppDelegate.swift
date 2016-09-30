
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
	
	var teamListTableVC: TeamListTableViewController? {
		get {
			if let master = teamListMasterVC {
				return master
			} else if let splitVC = window?.rootViewController as? TeamListSplitViewController {
				if let master = splitVC.viewControllers.first as? TeamListTableViewController {
					teamListMasterVC = master
					return master
				} else {
					return nil
				}
			}
			return nil
		}
		
		set {
			teamListMasterVC = newValue
			teamListMasterVC?.delegate = teamListSecondaryVC
		}
	}
	weak private var teamListMasterVC: TeamListTableViewController?
	
	var teamListDetailVC: TeamListDetailViewController? {
		get {
			if let secondary = teamListSecondaryVC {
				return secondary
			} else if let splitVC = window?.rootViewController as? TeamListSplitViewController {
				if let secondary = splitVC.viewControllers.last as? TeamListDetailViewController {
					teamListSecondaryVC = secondary
					return secondary
				} else {
					return nil
				}
			}
			return nil
		}
		
		set {
			teamListSecondaryVC = newValue
			teamListMasterVC?.delegate = teamListSecondaryVC
		}
	}
	weak private var teamListSecondaryVC: TeamListDetailViewController?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
		Fabric.with([Answers.self, Crashlytics.self])
		Crashlytics.sharedInstance().setUserIdentifier(UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
		
		DataSyncer.begin()
		
		checkForUpdate()
		
		clearTMPFolder()
		
        return true
    }
	
	func clearTMPFolder() {
//		do {
//			print(NSTemporaryDirectory())
//			try NSFileManager.defaultManager().removeItemAtPath(NSTemporaryDirectory())
//		} catch {
//			CLSNSLogv("Unable to clear temporary directory.", getVaList([]))
//		}
	}
	
	func checkForUpdate(forceful: Bool = false) {
		if forceful {
			//Set the skipped version to 0
			UserDefaults.standard.set(0, forKey: skippedVersionKey)
		}
		//Check if there is a new version of the app
		Alamofire.request(.GET, latestVersionStringURL).responseString(completionHandler: didReceiveCurrentVersionResponse)
	}
	
	private func didReceiveCurrentVersionResponse(_ response: Response<String, NSError>) {
		let notificationCenter = NotificationCenter.default
		if response.result.isSuccess {
			//Get the current version of the app on the device
			let onDeviceVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
			if let deviceVersion = Double(onDeviceVersion ?? "Huh, why would this not work") {
				if let latestVersion = Double((response.result.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!) {
					//Check if they are the same
					if latestVersion == deviceVersion {
						NSLog("App is up-to-date")
						notificationCenter.post(name: Notification.Name(rawValue: "UpdateIsAvailable"), object: self, userInfo: ["isAvailable":false])
					} else if latestVersion > deviceVersion {
						NSLog("This app has a newer version available (\(latestVersion)), please download and install it. Current: \(deviceVersion)")
						notificationCenter.post(name: Notification.Name(rawValue: "UpdateIsAvailable"), object: self, userInfo: ["isAvailable":true])
						
						//Check if the user has opted to skip this version
						let userDefaults = UserDefaults.standard
						let versionToSkip = userDefaults.double(forKey: skippedVersionKey) ?? 0
						
						if versionToSkip != latestVersion {
							//Create an alert and present it to the user
							let newVersionAlert = UIAlertController(title: "New Version Available", message: "A new version (\(latestVersion)) of the app is available for download. Please download and install it now or as soon as possible. Your current version is \(deviceVersion).", preferredStyle: .alert)
							newVersionAlert.addAction(UIAlertAction(title: "Download Now", style: .default) {_ in self.downloadNewVersionOfApp()})
							newVersionAlert.addAction(UIAlertAction(title: "Download Later", style: .default, handler: nil))
							newVersionAlert.addAction(UIAlertAction(title: "Skip Version \(latestVersion)", style: .destructive) {_ in self.skipVersion(versionToSkip: latestVersion)})
							window?.rootViewController?.present(newVersionAlert, animated: true, completion: nil)
						} else {
							//The user has opted to skip this version
							NSLog("Skipping version \(versionToSkip)")
						}
					} else if deviceVersion > latestVersion {
						NSLog("You're running a prerelease version, hooray!")
						notificationCenter.post(name: Notification.Name(rawValue: "UpdateIsAvailable"), object: self, userInfo: ["isAvailable":false])
					}
				} else {
					NSLog("Unable to check for new version")
				}
			} else {
				NSLog("An error occured while checking for the current version on this deivce")
			}
		} else {
			NSLog("Unable to check for updates")
		}
	}
	
	private func downloadNewVersionOfApp() {
		//Remove the skipped version user default
		let userDefaults = UserDefaults.standard
		userDefaults.set(0, forKey: skippedVersionKey)
		//Open the link to the manifest file and let iOS handle the rest
		UIApplication.shared.openURL(URL(string: appManifestStringURL)!)
	}
	
	private func skipVersion(versionToSkip version: Double) {
		//Save the version to skip in user defaults
		let userDefaults = UserDefaults.standard
		userDefaults.set(version, forKey: skippedVersionKey)
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
		checkForUpdate()
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
		DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(0))).async {
			self.managedObjectContext.perform() {
				self.saveContext()
				DataSyncer.sharedDataSyncer().ensemble.processPendingChangesWithCompletion() {error in
					if let error = error {NSLog("Unable to process pending changes in the background with error: \(error)")} else {NSLog("Processing pending changes in the background completed.")}
					UIApplication.sharedApplication().endBackgroundTask(backgroundTaskIdentifier)
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
        let urls = FileManager.default.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.urlForResource("FRC_Advanced_Scouting_Telemetrics", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
	
	var managedObjectModelURL: URL {
		return Bundle.main.urlForResource("FRC_Advanced_Scouting_Telemetrics", withExtension: "momd")!
	}

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        //Options for Lightweight migration
        var options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode":"DELETE"],
        ] as [String : Any]
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = try! self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
		managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return managedObjectContext
    }()
	
	lazy var coreDataURL: URL = {
		return try! self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
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
                abort()
            }
        }
    }

}

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
