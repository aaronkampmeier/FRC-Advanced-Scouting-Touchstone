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
    
    static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    func saveTeamNumber(number: String) -> Team {
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: TeamDataManager.managedContext)
        
        let team = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: TeamDataManager.managedContext) as! Team
        
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
        
        TeamDataManager.managedContext.deleteObject(teamForDeletion)
        
        save()
    }
    
    func save() {
        do {
            try TeamDataManager.managedContext.save()
        } catch let error as NSError {
            NSLog("Could not save: \(error), \(error.userInfo)")
        }
    }
    
    func getRootDraftBoard() throws -> DraftBoard {
        //Create a fetch request for the draft board
        let fetchRequest = NSFetchRequest(entityName: "DraftBoard")
        
        do {
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
            
            if results.count > 1 {
                NSLog("Somehow multiple draft boards were created. Select the one for deletion")
            } else if results.count == 1 {
                NSLog("One Draftboard")
                return results[0] as! DraftBoard
            } else if results.count == 0 {
                NSLog("Creating new draft board")
                //Create a new draft board and return it
                let newDraftBoard = DraftBoard(entity: NSEntityDescription.entityForName("DraftBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
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
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
            
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
        
        let newStatType = StatType(entity: NSEntityDescription.entityForName("StatType", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        //Set the new statType's name
        newStatType.name = name
        do {
            newStatType.statsBoard = try getRootStatsBoard()
        } catch let error as DataManagingError {
            NSLog(error.errorDescription)
            throw error
        }
        
        save()
        
        return newStatType
    }
    
    func addStatToTeam(team: Team, statType: StatType, statValue: Double) {
        let newStat = Stat(entity: NSEntityDescription.entityForName("Stat", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
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
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
            
            if results.count > 1 {
                NSLog("Somehow multiple stats boards were created. Select the one for deletion")
                throw DataManagingError.DuplicateStatsBoards
            } else if results.count == 1 {
                NSLog("One Statsboard")
                return results[0] as! StatsBoard
            } else if results.isEmpty {
                NSLog("Creating new stats board")
                //Create a new draft board and return it
                let newStatsBoard = StatsBoard(entity: NSEntityDescription.entityForName("StatsBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
                save()
                return newStatsBoard
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        throw DataManagingError.UnableToFetch
    }
    
    //FUNCTIONS FOR MATCHES
    func getRootMatchBoard() throws -> MatchBoard {
        //Create a fetch request for the draft board
        let fetchRequest = NSFetchRequest(entityName: "MatchBoard")
        
        do {
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
            
            if results.count > 1 {
                NSLog("Somehow multiple match boards were created. Select the one for deletion")
                throw DataManagingError.DuplicateMatchBoards
            } else if results.count == 1 {
                NSLog("One Match Board")
                return results[0] as! MatchBoard
            } else if results.count == 0 {
                NSLog("Creating new match board")
                //Create a new draft board and return it
                let newMatchBoard = MatchBoard(entity: NSEntityDescription.entityForName("MatchBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
                save()
                return newMatchBoard
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        throw DataManagingError.UnableToFetch
    }
    
    func createNewMatch(matchNumber: Int) throws {
        //First, check to make sure it doesn't already exist
        do {
            guard (try getRootMatchBoard().matches?.array as! [Match]).filter({return $0.matchNumber == matchNumber}).isEmpty else {
                throw DataManagingError.MatchAlreadyExists
            }
        } catch {
            throw DataManagingError.MatchAlreadyExists
        }
        
        
        let newMatch = Match(entity: NSEntityDescription.entityForName("Match", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newMatch.matchNumber = matchNumber
        
        do {
            newMatch.matchBoard = try getRootMatchBoard()
        } catch let error as DataManagingError {
            NSLog("\(error.errorDescription)")
        } catch {
            
        }
        
        save()
    }
    
    func deleteMatch(match: Match) {
        TeamDataManager.managedContext.deleteObject(match)
        save()
    }
    
    func addTeamsToMatch(teamsAndPlaces: [TeamPlaceInMatch], match: Match) {
        let participatingTeamsSet = match.participatingTeams?.mutableCopy() as! NSMutableSet
        for teamAndPlace in teamsAndPlaces {
            switch teamAndPlace {
            case .Blue1(let team):
                match.b1 = team
                participatingTeamsSet.addObject(team!)
            case .Blue2(let team):
                match.b2 = team
                participatingTeamsSet.addObject(team!)
            case .Blue3(let team):
                match.b3 = team
                participatingTeamsSet.addObject(team!)
            case .Red1(let team):
                match.r1 = team
                participatingTeamsSet.addObject(team!)
            case .Red2(let team):
                match.r2 = team
                participatingTeamsSet.addObject(team!)
            case .Red3(let team):
                match.r3 = team
                participatingTeamsSet.addObject(team!)
            }
        }
        match.participatingTeams = participatingTeamsSet.copy() as? NSSet
        save()
    }
    
    func addTeamToMatch(team: Team, match: Match, place: TeamPlaceInMatch) {
        let participatingTeamsSet = match.participatingTeams?.mutableCopy() as! NSMutableSet
        participatingTeamsSet.addObject(team)
        match.participatingTeams = participatingTeamsSet.copy() as? NSSet
        
        switch place {
        case .Blue1:
            match.b1 = team
        case .Red1:
            match.r1 = team
        case .Blue2:
            match.b2 = team
        case .Red2:
            match.r2 = team
        case .Blue3:
            match.b3 = team
        case .Red3:
            match.r3 = team
        }
        
        save()
    }
    
    func getTeamsForMatch(match: Match) -> [TeamPlaceInMatch] {
        return [TeamPlaceInMatch.Blue1(match.b1), TeamPlaceInMatch.Blue2(match.b2), TeamPlaceInMatch.Blue3(match.b3), TeamPlaceInMatch.Red1(match.r1), TeamPlaceInMatch.Red2(match.r2), TeamPlaceInMatch.Red3(match.r3)]
    }
    
    func getTimeOfMatch(match: Match) -> NSDate {
        return match.time!
    }
    
    func getMatches() -> [Match]{
        var matchBoard: MatchBoard?
        do {
            matchBoard = try getRootMatchBoard()
        } catch {
            NSLog("Unable to get match board")
        }
        
        return matchBoard!.matches?.array as! [Match]
    }
    
    func getMatchesForTeam(team: Team) -> [Match]{
        return team.matches?.allObjects as! [Match]
    }
    
    enum TeamPlaceInMatch {
        case Blue1(Team?)
        case Blue2(Team?)
        case Blue3(Team?)
        case Red1(Team?)
        case Red2(Team?)
        case Red3(Team?)
    }
    
    enum DataManagingError: ErrorType {
        case DuplicateTeams
        case DuplicateStatsBoards
        case DuplicateMatchBoards
        case UnableToFetch
        case TypeAlreadyExists
        case UnableToGetStatsBoard
        case MatchAlreadyExists
        
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