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
    
    func deleteTeam(teamForDeletion: Team) {
        //Retrieve the Managed Context
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        managedContext.deleteObject(teamForDeletion)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save: \(error), \(error.userInfo)")
        }
    }
    
    func save() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save: \(error), \(error.userInfo)")
        }
    }
    
    func getTeams(Predicate predicate: NSPredicate?) -> [Team] {
        var teams: [Team] = [Team]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            teams = results as! [Team]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return teams
    }
    
    func getTeams(numberForSorting: String) -> [Team] {
        return getTeams(Predicate: NSPredicate(format: "%K like %@", argumentArray: ["teamNumber", "\(numberForSorting)"]))
    }
    
    func getTeams() -> [Team] {
        return getTeams(Predicate: nil)
    }
}