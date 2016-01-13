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
    
    func saveTeamNumber(number: String) -> Team {
        //Get the AppDelegate and get the managed context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: managedContext)
        
        let team = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Team
        
        //Set the value we want
        team.teamNumber = number
        
        //Try to save
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save: \(error), \(error.userInfo)")
        }
        return team
    }
    
    func getTeams() -> [Team] {
        var teams: [Team] = [Team]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            teams = results as! [Team]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return teams
    }
}