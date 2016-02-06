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
            team.draftBoard = rootDraftBoard
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
        throw DataManagingError.UnableToFetch
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
    
    //FUNCTIONS FOR MANAGING TEAM STATISTICS
    
    func getStatsForTeam(team: Team) -> [Stat]{
        return team.stats?.allObjects as! [Stat]
    }
    
    func getStatsForTeam(teamNumber: String) throws -> [Stat] {
        let team = getTeams(teamNumber)
        
        if team.count > 1 {
            throw DataManagingError.DuplicateTeams
        }
        
        return getStatsForTeam(team[0])
    }
    
    func getStatTypes() throws -> [StatType] {
        let statsBoard: StatsBoard?
        do {
            statsBoard = try getRootStatsBoard()
        } catch {
            throw DataManagingError.UnableToFetch
        }
        
        if let board = statsBoard {
            return board.types?.allObjects as! [StatType]
        }
    }
    
    func createNewStatType(name: String) throws -> StatType {
        //Check if the Stat Type already exists
        do {
            for type in try getRootStatsBoard().types?.allObjects as! [StatType] {
                if type.name == name {
                    throw DataManagingError.TypeAlreadyExists
                }
            }
        } catch {
            NSLog("Unable to Check if type already existed")
            throw DataManagingError.UnableToGetStatsBoard
        }
        
        let newStatType = StatType(entity: NSEntityDescription.entityForName("StatType", inManagedObjectContext: managedContext)!, insertIntoManagedObjectContext: managedContext)
        
        //Set the new statType's name
        newStatType.name = name
        do {
            newStatType.statsBoard = try getRootStatsBoard()
        } catch let error as DataManagingError {
            NSLog(error.errorDescription)
            throw error
        }
        
        /*do {
            //Add the new stat type to the stats board
            let rootStatsBoard = try getRootStatsBoard()
            let typesMutableCopy = rootStatsBoard.types?.mutableCopy() as! NSMutableSet
            typesMutableCopy.addObject(newStatType)
            rootStatsBoard.types = typesMutableCopy.copy() as? NSSet
        } catch let error as dataManagingError {
            NSLog(error.errorDescription)
            throw error
        } catch {
            throw error
        }*/
        
        save()
        
        return newStatType
    }
    
    func addStatToTeam(team: Team, statType: StatType, statValue: Double) {
        let newStat = Stat(entity: NSEntityDescription.entityForName("Stat", inManagedObjectContext: managedContext)!, insertIntoManagedObjectContext: managedContext)
        
        newStat.value = statValue
        newStat.statType = statType
        newStat.team = team
        newStat.statsBoard = statType.statsBoard
        
        save()
    }
    
    func getRootStatsBoard() throws -> StatsBoard {
        //Create a fetch request for the draft board
        let fetchRequest = NSFetchRequest(entityName: "StatsBoard")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            if results.count > 1 {
                NSLog("Somehow multiple stats boards were created. Select the one for deletion")
                throw DataManagingError.DuplicateStatsBoards
            } else if results.count == 1 {
                NSLog("One Statsboard")
                return results[0] as! StatsBoard
            } else if results.count == 0 {
                NSLog("Creating new stats board")
                //Create a new draft board and return it
                let newStatsBoard = StatsBoard(entity: NSEntityDescription.entityForName("StatsBoard", inManagedObjectContext: managedContext)!, insertIntoManagedObjectContext: managedContext)
                return newStatsBoard
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        throw DataManagingError.UnableToFetch
    }
    
    enum DataManagingError: ErrorType {
        case DuplicateTeams
        case DuplicateStatsBoards
        case UnableToFetch
        case TypeAlreadyExists
        case UnableToGetStatsBoard
        
        var errorDescription: String {
            switch self {
            case .DuplicateTeams:
                return "There are more than one team entities with the specified team number."
            default:
                return "A problem occured with data management."
            }
        }
    }
}