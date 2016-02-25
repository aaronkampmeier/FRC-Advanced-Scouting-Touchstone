//
//  AppDelegate.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
		let dataManager = TeamDataManager()
		//Set up and manage all the defenses. They should always be constant: Two defenses for 4 categories and a low bar.
		//Set up category A
		let catADefenses = dataManager.getDefenses(inCategory: "A")
		if catADefenses.filter({$0.defenseName == "Portcullis"}).isEmpty {
			//There is no portcullis defense, make one
			NSLog("Making Portcullis Defense")
			dataManager.createDefense(withName: "Portcullis", inCategory: "A")
		}
		if catADefenses.filter({$0.defenseName == "Cheval de Frise"}).isEmpty {
			//There is no Cheval de Frise, make one
			NSLog("Making Cheval De Frise Defense")
			dataManager.createDefense(withName: "Cheval de Frise", inCategory: "A")
		}
		
		//Set up category B
		let catBDefenses = dataManager.getDefenses(inCategory: "B")
		if catBDefenses.filter({$0.defenseName == "Moat"}).isEmpty {
			//There is no Moat defense, make one
			NSLog("Making Moat Defense")
			dataManager.createDefense(withName: "Moat", inCategory: "B")
		}
		if catBDefenses.filter({$0.defenseName == "Ramparts"}).isEmpty {
			//There is no Ramparts, make one
			NSLog("Making Ramparts Defense")
			dataManager.createDefense(withName: "Ramparts", inCategory: "B")
		}
		
		//Set up category C
		let catCDefenses = dataManager.getDefenses(inCategory: "C")
		if catCDefenses.filter({$0.defenseName == "Drawbridge"}).isEmpty {
			//There is no Drawbridge defense, make one
			NSLog("Making Drawbridge Defense")
			dataManager.createDefense(withName: "Drawbridge", inCategory: "C")
		}
		if catCDefenses.filter({$0.defenseName == "Sally Port"}).isEmpty {
			//There is no Sally Port, make one
			NSLog("Making Sally Port Defense")
			dataManager.createDefense(withName: "Sally Port", inCategory: "C")
		}
		
		//Set up category D
		let catDDefenses = dataManager.getDefenses(inCategory: "D")
		if catDDefenses.filter({$0.defenseName == "Rock Wall"}).isEmpty {
			//There is no Rock Wall defense, make one
			NSLog("Making Rock Wall Defense")
			dataManager.createDefense(withName: "Rock Wall", inCategory: "D")
		}
		if catDDefenses.filter({$0.defenseName == "Rough Terrain"}).isEmpty {
			//There is no Rough Terrain, make one
			NSLog("Making Rough Terrain Defense")
			dataManager.createDefense(withName: "Rough Terrain", inCategory: "D")
		}
		
		//Set up category E (an imaginary one to hold the low bar)
		let catEDefenses = dataManager.getDefenses(inCategory: "E")
		if catEDefenses.filter({$0.defenseName == "Low Bar"}).isEmpty {
			//There is no Low Bar, make one
			NSLog("Making Low Bar Defense")
			dataManager.createDefense(withName: "Low Bar", inCategory: "E")
		}
		
		//Save all the defenses
		dataManager.save()
		
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.kampmeier.FRC_Advanced_Scouting_Telemetrics" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FRC_Advanced_Scouting_Telemetrics", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        //Options for Lightweight migration
        var options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
        ]
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
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

