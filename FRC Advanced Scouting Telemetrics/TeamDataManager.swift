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
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func saveTeamNumber(number: String) -> Team {
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: managedContext)
        
        let team = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Team
        
        //Set the value we want
        team.teamNumber = number
        
        //Add it to the root draft board
        do {
            let rootDraftBoard = try getRootDraftBoard()
            let draftBoardTeams = rootDraftBoard.teams!.mutableCopy() as! NSMutableOrderedSet
            draftBoardTeams.addObject(team)
            rootDraftBoard.teams = draftBoardTeams.copy() as? NSOrderedSet
            
        } catch {
            NSLog("Could not save team to draft board")
        }
        
        //Try to save
        save()
        return team
    }
    
    func deleteTeam(teamForDeletion: Team) {
        
        managedContext.deleteObject(teamForDeletion)
        
        save()
    }
    
    func save() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            NSLog("Could not save: \(error), \(error.userInfo)")
        }
    }
    
    func getRootDraftBoard() throws -> DraftBoard {
        //Create a fetch request for the draft board
        let fetchRequest = NSFetchRequest(entityName: "DraftBoard")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            if results.count > 1 {
                NSLog("Somehow multiple draft boards were created. Select the one for deletion")
            } else if results.count == 1 {
                NSLog("One Draftboard")
                return results[0] as! DraftBoard
            } else if results.count == 0 {
                NSLog("Creating new draft board")
                //Create a new draft board and return it
                let newDraftBoard = DraftBoard(entity: NSEntityDescription.entityForName("DraftBoard", inManagedObjectContext: managedContext)!, insertIntoManagedObjectContext: managedContext)
                save()
                return newDraftBoard
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        throw DraftBoardError.UnableToFetch
    }
    
    enum DraftBoardError: ErrorType {
        case UnableToFetch
    }
    
    func moveTeam(fromIndex: Int, toIndex: Int) throws {
        do {
            let rootDraftBoard = try getRootDraftBoard()
            
            //Move the team in the draft board array
            let mutableArray = rootDraftBoard.teams?.mutableCopy() as! NSMutableOrderedSet
            let movedTeam = mutableArray[fromIndex]
            mutableArray.removeObjectAtIndex(fromIndex)
            mutableArray.insertObject(movedTeam, atIndex: toIndex)
            
            rootDraftBoard.teams = mutableArray.copy() as? NSOrderedSet
        } catch {
            throw error
        }
        
        save()
    }
    
    func getTeams(Predicate predicate: NSPredicate?) -> [Team] {
        var teams: [Team] = [Team]()
        
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            teams = results as! [Team]
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        
        return teams
    }
    
    func getTeams(numberForSorting: String) -> [Team] {
        return getTeams(Predicate: NSPredicate(format: "%K like %@", argumentArray: ["teamNumber", "\(numberForSorting)"]))
    }
    
    func getTeams() -> [Team] {
        return getTeams(Predicate: nil)
    }
    
    func getDraftBoard() throws -> [Team]{
        do {
            NSLog("Num of draftBoardTeams: \(try getRootDraftBoard().teams?.count)")
            return try getRootDraftBoard().teams?.array as! [Team]
        } catch {
            throw error
        }
    }
}