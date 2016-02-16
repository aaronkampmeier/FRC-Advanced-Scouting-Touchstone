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
        
        let team = Team(entity: entity!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
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
	
	func getTeams(inRegional regional: Regional) -> [TeamRegionalPerformance]{
		return regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance]
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
                //Create a new stats board and return it
                let newStatsBoard = StatsBoard(entity: NSEntityDescription.entityForName("StatsBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
                save()
                return newStatsBoard
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        throw DataManagingError.UnableToFetch
    }
    
    //FUNCTIONS FOR REGIONALS
    func addRegional(regionalNumber num: Int, withName name: String) -> Regional {
        //Check to make sure that the regional doesn't exist
        let previousRegionals = getAllRegionals().filter({$0.regionalNumber == num})
        guard previousRegionals.isEmpty else {
            return previousRegionals[0]
        }
        
        let newRegional = Regional(entity: NSEntityDescription.entityForName("Regional", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newRegional.name = name
        newRegional.regionalNumber = num
        save()
        return newRegional
    }
    
    func getAllRegionals() -> [Regional] {
        let fetchRequest = NSFetchRequest(entityName: "Regional")
        
        var regionals = [Regional]()
        do {
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest) as? [Regional]
			if let x = results {
				regionals = x
			}
        } catch {
            regionals = []
        }
        
        return regionals
    }
	
	func getRegional(withNumber num: Int) -> Regional? {
		let fetchRequest = NSFetchRequest(entityName: "Regional")
		
		fetchRequest.predicate = NSPredicate(format: "%k like %@", argumentArray: ["regionalNumber", "\(num)"])
		
		do {
			let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
			return results[0] as? Regional
		} catch {
			return nil
		}
	}
    
    func addTeamToRegional(team: Team, regional: Regional) -> TeamRegionalPerformance {
        let previousPerformances = (team.regionalPerformances?.allObjects as! [TeamRegionalPerformance]).filter({$0.regional == regional})
        guard previousPerformances.isEmpty else {
            return previousPerformances[0]
        }
        
        let newRegionalPerformance = TeamRegionalPerformance(entity: NSEntityDescription.entityForName("TeamRegionalPerformance", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newRegionalPerformance.regional = regional
        newRegionalPerformance.team = team
        save()
        return newRegionalPerformance
    }
    
    //FUNCTIONS FOR MATCHES
    func createNewMatch(matchNumber: Int, inRegional regional: Regional) throws {
        //First, check to make sure it doesn't already exist
        guard (regional.matches?.allObjects as! [Match]).filter({return $0.matchNumber == matchNumber}).isEmpty else {
            throw DataManagingError.MatchAlreadyExists
        }
        
        let newMatch = Match(entity: NSEntityDescription.entityForName("Match", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newMatch.matchNumber = matchNumber
        
        newMatch.regional = regional
        
        save()
    }
    
    func deleteMatch(match: Match) {
        TeamDataManager.managedContext.deleteObject(match)
        save()
    }
    
    func addTeamsToMatch(teamsAndPlaces: [RegionalTeamPlaceInMatch], match: Match) {
        let participatingTeamsSet = match.teamPerformances!.mutableCopy() as! NSMutableSet
        //
        participatingTeamsSet.removeAllObjects()
        //
        for teamAndPlace in teamsAndPlaces {
            //Create a new Match Performance
            let newMatchPerformance = TeamMatchPerformance(entity: NSEntityDescription.entityForName("TeamMatchPerformance", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
            
            newMatchPerformance.regionalPerformance = teamAndPlace.teamRegionalPerformance
            switch teamAndPlace {
            case .Blue1(let regionalTeam):
                newMatchPerformance.allianceColor = 0
                newMatchPerformance.allianceTeam = 1
            case .Blue2(let regionalTeam):
                newMatchPerformance.allianceColor = 0
                newMatchPerformance.allianceTeam = 2
            case .Blue3(let regionalTeam):
                newMatchPerformance.allianceColor = 0
                newMatchPerformance.allianceTeam = 3
            case .Red1(let regionalTeam):
                newMatchPerformance.allianceColor = 1
                newMatchPerformance.allianceTeam = 1
            case .Red2(let regionalTeam):
                newMatchPerformance.allianceColor = 1
                newMatchPerformance.allianceTeam = 2
            case .Red3(let regionalTeam):
                newMatchPerformance.allianceColor = 1
                newMatchPerformance.allianceTeam = 3
            }
            participatingTeamsSet.addObject(newMatchPerformance)
        }
        match.teamPerformances = participatingTeamsSet.copy() as? NSSet
        save()
    }
    
    /* DEPRECATED
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
    
    func getTeamsForMatchDeprecated(match: Match) -> [TeamPlaceInMatch] {
        return [TeamPlaceInMatch.Blue1(match.b1), TeamPlaceInMatch.Blue2(match.b2), TeamPlaceInMatch.Blue3(match.b3), TeamPlaceInMatch.Red1(match.r1), TeamPlaceInMatch.Red2(match.r2), TeamPlaceInMatch.Red3(match.r3)]
    }
    */
    
    func getTeamsForMatch(match: Match) -> [TeamMatchPerformance] {
        let teamPerformances = match.teamPerformances?.allObjects as! [TeamMatchPerformance]
        return teamPerformances
    }
	
    func getTimeOfMatch(match: Match) -> NSDate {
        return match.time!
    }
    
	func getMatches(forRegional regional: Regional) -> [Match]{
        return regional.matches?.allObjects as! [Match]
    }
    
    /* Deprecated
    func getMatchesForTeam(team: Team) -> [Match]{
        return team.matches?.allObjects as! [Match]
    }
	*/
    
    enum TeamPlaceInMatch {
        case Blue1(Team?)
        case Blue2(Team?)
        case Blue3(Team?)
        case Red1(Team?)
        case Red2(Team?)
        case Red3(Team?)
    }
    
    enum RegionalTeamPlaceInMatch {
        case Blue1(TeamRegionalPerformance?)
        case Blue2(TeamRegionalPerformance?)
        case Blue3(TeamRegionalPerformance?)
        case Red1(TeamRegionalPerformance?)
        case Red2(TeamRegionalPerformance?)
        case Red3(TeamRegionalPerformance?)
        
        var teamRegionalPerformance: TeamRegionalPerformance {
            switch self {
            case .Blue1(let x):
                return x!
            case .Blue2(let x):
                return x!
            case .Blue3(let x):
                return x!
            case .Red1(let x):
                return x!
            case .Red2(let x):
                return x!
            case .Red3(let x):
                return x!
            }
        }
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