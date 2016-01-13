//
//  TeamDataManager.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TeamDataManager {
    
    func saveTeamNumber(number: String) -> NSManagedObject {
        //Get the AppDelegate and get the managed context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: managedContext)
        
        let team = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //Set the value we want
        team.setValue(number, forKey: "teamNumber")
        
        //Try to save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save: \(error), \(error.userInfo)")
        }
        return team
    }
}