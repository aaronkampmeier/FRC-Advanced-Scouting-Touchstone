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
	
	private func save() {
        do {
            try TeamDataManager.managedContext.save()
        } catch let error as NSError {
            NSLog("Could not save: \(error), \(error.userInfo)")
        }
    }
	
	func commitChanges() {
		NSLog("Committing Changes")
		save()
	}
	
	func discardChanges() {
		NSLog("Discarding Changes")
		TeamDataManager.managedContext.rollback()
	}
	
	func saveTeamNumber(number: String, atRank rank: Int? = nil, performCommit shouldSave: Bool = true) -> Team {
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: TeamDataManager.managedContext)
        
        let team = Team(entity: entity!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        //Set the value we want
        team.teamNumber = number
        
        //Add it to the root draft board
		if rank == nil {
			do {
				let rootDraftBoard = try getRootDraftBoard()
				team.draftBoard = rootDraftBoard
			} catch {
				NSLog("Could not save team to draft board")
			}
		} else {
			do {
				let draftBoard = try getRootDraftBoard().teams?.mutableCopy() as! NSMutableOrderedSet
				draftBoard.insertObject(team, atIndex: rank!)
				try getRootDraftBoard().teams = draftBoard.copy() as! NSOrderedSet
			} catch {
				NSLog("Could not save team to draft board")
			}
		}
		
		if shouldSave {
			//Try to save
			commitChanges()
		}
        return team
    }
    
    func deleteTeam(teamForDeletion: Team) {
        TeamDataManager.managedContext.deleteObject(teamForDeletion)
        
        save()
    }
	
	func delete(objectsToDelete: NSManagedObject...) {
		for object in objectsToDelete {
			TeamDataManager.managedContext.deleteObject(object)
		}
	}
	
	func setDefenseAbleToShootFrom(defense: Defense, toTeam team: Team, canShootFrom: Bool) {
		let defenseSet = team.autonomousDefensesAbleToShoot?.mutableCopy() as! NSMutableSet
		
		if canShootFrom == true {
			if defenseSet.containsObject(defense) {
				return
			}
			
			defenseSet.addObject(defense)
		} else {
			if defenseSet.containsObject(defense) {
				defenseSet.removeObject(defense)
			}
		}
		
		team.autonomousDefensesAbleToShoot = (defenseSet.copy() as! NSSet)
	}
    
	func addDefense(defense: Defense, toTeam team: Team, forPart part: GamePart) {
		var defenseSet: NSSet
		switch part {
		case .Autonomous:
			defenseSet = team.autonomousDefensesAbleToCross!
		case .Teleop:
			defenseSet = team.defensesAbleToCross!
		}
		
		let mutableDefensesSet = defenseSet.mutableCopy() as! NSMutableSet
		
		//Check if it is already there
		if mutableDefensesSet.containsObject(defense) {
			//The defense is already there, return
			return
		}
		
		mutableDefensesSet.addObject(defense)
		
		//Set the data back in the team
		switch part {
		case .Autonomous:
			team.autonomousDefensesAbleToCross = (mutableDefensesSet.copy() as! NSSet)
		case .Teleop:
			team.defensesAbleToCross = (mutableDefensesSet.copy() as! NSSet)
		}
	}
	
	func removeDefense(defense: Defense, fromTeam team: Team, forPart part: GamePart) {
		var defenseSet: NSSet
		switch part {
		case .Autonomous:
			defenseSet = team.autonomousDefensesAbleToCross!
		case .Teleop:
			defenseSet = team.defensesAbleToCross!
		}
		
		let mutableDefensesSet = defenseSet.mutableCopy() as! NSMutableSet
		
		//Check if the defense is actually in the set
		if !mutableDefensesSet.containsObject(defense) {
			//The defense isn't even in the set, return
			return
		}
		
		mutableDefensesSet.removeObject(defense)
		
		//Set the data back into the team
		switch part {
		case .Autonomous:
			team.autonomousDefensesAbleToCross = (mutableDefensesSet.copy() as! NSSet)
		case .Teleop:
			team.defensesAbleToCross = (mutableDefensesSet.copy() as! NSSet)
		}
	}
	
    func getRootDraftBoard() throws -> DraftBoard {
        //Create a fetch request for the draft board
        let fetchRequest = NSFetchRequest(entityName: "DraftBoard")
        
        do {
            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest) as! [DraftBoard]
            
            if results.count > 1 {
                NSLog("Somehow multiple draft boards were created. This could be the result of a sync error.")
				//Attempt to merge them
				var board1Mutable = results[0].teams?.array as! [Team]
				let board2Mutable = results[1].teams?.array as! [Team]
				for team in board2Mutable {
					board1Mutable.append(team)
				}
				TeamDataManager.managedContext.deleteObject(results[1])
				results[0].teams = NSOrderedSet(array: board1Mutable)
				return try getRootDraftBoard()
            } else if results.count == 1 {
                return results.first!
            } else if results.count == 0 {
                NSLog("Creating new draft board")
                //Create a new draft board and return it
                let newDraftBoard = DraftBoard(entity: NSEntityDescription.entityForName("DraftBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
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
            return try getRootDraftBoard().teams?.array as! [Team]
        } catch {
            throw error
        }
    }
    
    //FUNCTIONS FOR MANAGING TEAM STATISTICS
//    DEPRECATED
//    func getStatsForTeam(team: Team) -> [Stat]{
//        return team.stats?.allObjects as! [Stat]
//    }
//    
//    func getStatsForTeam(teamNumber: String) throws -> [Stat] {
//        let team = getTeams(teamNumber)
//        
//        if team.count > 1 {
//            throw DataManagingError.DuplicateTeams
//        }
//        
//        return getStatsForTeam(team[0])
//    }
//    
//    func getStatTypes() throws -> [StatType] {
//        let statsBoard: StatsBoard?
//        do {
//            statsBoard = try getRootStatsBoard()
//        } catch {
//            throw DataManagingError.UnableToFetch
//        }
//        
//        if let board = statsBoard {
//            return board.types?.allObjects as! [StatType]
//        }
//    }
//    
//    func createNewStatType(name: String) throws -> StatType {
//        //Check if the Stat Type already exists
//        do {
//            for type in try getRootStatsBoard().types?.allObjects as! [StatType] {
//                if type.name == name {
//                    throw DataManagingError.TypeAlreadyExists
//                }
//            }
//        } catch {
//            NSLog("Unable to Check if type already existed")
//            throw DataManagingError.UnableToGetStatsBoard
//        }
//        
//        let newStatType = StatType(entity: NSEntityDescription.entityForName("StatType", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
//        
//        //Set the new statType's name
//        newStatType.name = name
//        do {
//            newStatType.statsBoard = try getRootStatsBoard()
//        } catch let error as DataManagingError {
//            NSLog(error.errorDescription)
//            throw error
//        }
//        
//        save()
//        
//        return newStatType
//    }
//    
//    func addStatToTeam(team: Team, statType: StatType, statValue: Double) {
//        let newStat = Stat(entity: NSEntityDescription.entityForName("Stat", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
//        
//        newStat.value = statValue
//        newStat.statType = statType
//        newStat.team = team
//        newStat.statsBoard = statType.statsBoard
//        
//        save()
//    }
//    
//    func getRootStatsBoard() throws -> StatsBoard {
//        //Create a fetch request for the draft board
//        let fetchRequest = NSFetchRequest(entityName: "StatsBoard")
//        
//        do {
//            let results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest)
//            
//            if results.count > 1 {
//                NSLog("Somehow multiple stats boards were created. Select the one for deletion")
//                throw DataManagingError.DuplicateStatsBoards
//            } else if results.count == 1 {
//                NSLog("One Statsboard")
//                return results[0] as! StatsBoard
//            } else if results.isEmpty {
//                NSLog("Creating new stats board")
//                //Create a new stats board and return it
//                let newStatsBoard = StatsBoard(entity: NSEntityDescription.entityForName("StatsBoard", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
//                save()
//                return newStatsBoard
//            }
//        } catch let error as NSError {
//            NSLog("Could not fetch \(error), \(error.userInfo)")
//        }
//        throw DataManagingError.UnableToFetch
//    }
	
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
		//Check if there is already a regional performance for it
        let previousPerformances = (team.regionalPerformances?.allObjects as! [TeamRegionalPerformance]).filter({$0.regional == regional})
        guard previousPerformances.isEmpty else {
            return previousPerformances[0]
        }
		
		//If there isn't, then create one
        let newRegionalPerformance = TeamRegionalPerformance(entity: NSEntityDescription.entityForName("TeamRegionalPerformance", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newRegionalPerformance.regional = regional
        newRegionalPerformance.team = team
        return newRegionalPerformance
    }
	
	func delete(Regional regional: Regional) {
		TeamDataManager.managedContext.deleteObject(regional)
	}
    
    //FUNCTIONS FOR MATCHES
    func createNewMatch(matchNumber: Int, inRegional regional: Regional) throws -> Match {
        //First, check to make sure it doesn't already exist
        guard (regional.matches?.allObjects as! [Match]).filter({return $0.matchNumber == matchNumber}).isEmpty else {
            throw DataManagingError.MatchAlreadyExists
        }
        
        let newMatch = Match(entity: NSEntityDescription.entityForName("Match", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
        
        newMatch.matchNumber = matchNumber
        
        newMatch.regional = regional
		return newMatch
    }
    
    func deleteMatch(match: Match) {
        TeamDataManager.managedContext.deleteObject(match)
    }
	
	//Newer and preferred method for setting teams in a match
	func setTeamsInMatch(teamsAndPlaces: [TeamAndMatchPlace], inMatch match: Match) {
		for teamAndPlace in teamsAndPlaces {
			let team = teamAndPlace.team
			
			//Check if there is a previous match performance for this place
			var alreadyExists: Bool = false
			var preExistentTeamPerformance: TeamMatchPerformance?
			for teamPerformance in match.teamPerformances!.allObjects as! [TeamMatchPerformance] {
				if teamPerformance.allianceColor == teamAndPlace.allianceColorAndTeam["Color"] && teamPerformance.allianceTeam == teamAndPlace.allianceColorAndTeam["Team"] {
					alreadyExists = true
					preExistentTeamPerformance = teamPerformance
				}
			}
			
			if let team = team {
				if !alreadyExists {
					//This is a new team for that place
					//If its match performance doesn't already exist, then add it.
					let matchPerformance = createNewMatchPerformance(withTeam: team, inMatch: match)
					
					//Set the alliance color and team
					matchPerformance.allianceColor = teamAndPlace.allianceColorAndTeam["Color"]
					matchPerformance.allianceTeam = teamAndPlace.allianceColorAndTeam["Team"]
					
					//Add it to the participating teams
					//participatingTeamPerformances.addObject(matchPerformance)
				} else {
					//Check to see if the pre-existent match performance is the same team as the new team
					if preExistentTeamPerformance?.regionalPerformance?.valueForKey("Team") as! Team == team {
						//The team is the same, we're done
					} else {
						//The team is different, delete the old one and make a new one
						deleteMatchPerformance(preExistentTeamPerformance!)
						
						let matchPerformance = createNewMatchPerformance(withTeam: team, inMatch: match)
						
						//Set the alliance color and team
						matchPerformance.allianceColor = teamAndPlace.allianceColorAndTeam["Color"]
						matchPerformance.allianceTeam = teamAndPlace.allianceColorAndTeam["Team"]
						
						//Add it to the participating teams
						//participatingTeamPerformances.addObject(matchPerformance)
					}
				}
			} else {
				//There isn't a team for that color and place, delete whatever was previously there
				if let performance = preExistentTeamPerformance {
					deleteMatchPerformance(performance)
				}
			}
		}
	}
	
	func deleteMatchPerformance(matchPerformance: TeamMatchPerformance) {
		//Get the regional performance before deletion
		let regionalPerformance = matchPerformance.regionalPerformance!
		
		//Delete the match performance
		TeamDataManager.managedContext.deleteObject(matchPerformance)
		
		//Check if it is the last match performance in the regional performance
		if regionalPerformance.matchPerformances?.count == 0 {
			//It was the last match performance, delete the regional performance now, too
			TeamDataManager.managedContext.deleteObject(regionalPerformance)
		}
	}
	
	func createNewMatchPerformance(withTeam team: Team, inMatch match: Match) -> TeamMatchPerformance {
		//Get the regional performance for the team
		let regionalPerformance = addTeamToRegional(team, regional: match.regional!)
		
		//Create the new match performance
		let newMatchPerformance = TeamMatchPerformance(entity: NSEntityDescription.entityForName("TeamMatchPerformance", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newMatchPerformance.regionalPerformance = regionalPerformance
		newMatchPerformance.match = match
		
		return newMatchPerformance
	}
	
	enum TeamAndMatchPlace {
		case Blue1(Team?)
		case Blue2(Team?)
		case Blue3(Team?)
		case Red1(Team?)
		case Red2(Team?)
		case Red3(Team?)
		
		var team: Team? {
			switch self {
			case .Blue1(let x):
				return x
			case .Blue2(let x):
				return x
			case .Blue3(let x):
				return x
			case .Red1(let x):
				return x
			case .Red2(let x):
				return x
			case .Red3(let x):
				return x
			}
		}
		
		var allianceColorAndTeam: [String:Int] {
			switch self {
			case .Blue1(_):
				return ["Color":0, "Team":1]
			case .Blue2(_):
				return ["Color":0, "Team":2]
			case .Blue3(_):
				return ["Color":0, "Team":3]
			case .Red1(_):
				return ["Color":1, "Team":1]
			case .Red2(_):
				return ["Color":1, "Team":2]
			case .Red3(_):
				return ["Color":1, "Team":3]
			}
		}
	}
	
	func set(didCaptureTower: Bool, inMatch match: Match, forAlliance alliance: AllianceColor) {
		switch alliance {
		case .Red:
			match.redCapturedTower = didCaptureTower
		case .Blue:
			match.blueCapturedTower = didCaptureTower
		}
	}
	
	func setDefenses(inMatch match: Match, redOrBlue color: AllianceColor, defenseA: CategoryADefense, defenseB: CategoryBDefense, defenseC: CategoryCDefense, defenseD: CategoryDDefense) {
		//Get the defense objects
		let a = getDefense(withName: defenseA.string)
		let b = getDefense(withName: defenseB.string)
		let c = getDefense(withName: defenseC.string)
		let d = getDefense(withName: defenseD.string)
		
		//Make a set with these defenses
		let defensesSet = NSSet(array: [a!, b!, c!, d!])
		
		switch color {
		case .Red:
			match.redDefenses = defensesSet
		case .Blue:
			match.blueDefenses = defensesSet
		}
	}
	
	enum AllianceColor: Int {
		case Blue = 0
		case Red = 1
	}
	
	enum DefenseType: String, CustomStringConvertible, Hashable {
		case Portcullis = "Portcullis"
		case ChevalDeFrise = "Cheval de Frise"
		case Moat = "Moat"
		case Ramparts = "Ramparts"
		case Drawbridge = "Drawbridge"
		case SallyPort = "Sally Port"
		case RockWall = "Rock Wall"
		case RoughTerrain = "Rough Terrain"
		case LowBar = "Low Bar"
		
		var description: String {
			switch self {
			case .Portcullis:
				return "Portcullis"
			case .ChevalDeFrise:
				return "Cheval de Frise"
			case .Moat:
				return "Moat"
			case .Ramparts:
				return "Ramparts"
			case .Drawbridge:
				return "Drawbridge"
			case .SallyPort:
				return "Sally Port"
			case .RockWall:
				return "Rock Wall"
			case .RoughTerrain:
				return "Rough Terrain"
			case .LowBar:
				return "Low Bar"
			}
		}
		
		var category: DefenseCategory {
			switch self {
			case .Portcullis, .ChevalDeFrise:
				return .A
			case .Moat, .Ramparts:
				return .B
			case .Drawbridge, .SallyPort:
				return .C
			case .RockWall, .RoughTerrain:
				return .D
			case .LowBar:
				return .LowBar
			}
		}
		
		var defense: Defense {
			return TeamDataManager().getDefense(withName: self.description)!
		}
	}
	
	enum DefenseCategory: Int {
		case A
		case B
		case C
		case D
		case LowBar
		
		var defenses: [DefenseType] {
			switch self {
			case .A:
				return [.Portcullis, .ChevalDeFrise]
			case .B:
				return [.Moat, .Ramparts]
			case .C:
				return [.Drawbridge, .SallyPort]
			case .D:
				return [.RockWall, .RoughTerrain]
			case .LowBar:
				return [.LowBar]
			}
		}
		
		init(category: Character) {
			switch category {
			case "A":
				self = .A
			case "B":
				self = .B
			case "C":
				self = .C
			case "D":
				self = .D
			default:
				self = .LowBar
			}
		}
	}
	
	enum CategoryADefense: Int {
		case Portcullis
		case ChevalDeFrise
		
		var string: String {
			switch self {
			case .Portcullis:
				return "Portcullis"
			case .ChevalDeFrise:
				return "Cheval de Frise"
			}
		}
	}
	
	enum CategoryBDefense: Int {
		case Moat
		case Ramparts
		
		var string: String {
			switch self {
			case .Moat:
				return "Moat"
			case .Ramparts:
				return "Ramparts"
			}
		}
	}
	
	enum CategoryCDefense: Int {
		case Drawbridge
		case SallyPort
		
		var string: String {
			switch self {
			case .Drawbridge:
				return "Drawbridge"
			case .SallyPort:
				return "Sally Port"
			}
		}
	}
	
	enum CategoryDDefense: Int {
		case RockWall
		case RoughTerrain
		
		var string: String {
			switch self {
			case .RockWall:
				return "Rock Wall"
			case .RoughTerrain:
				return "Rough Terrain"
			}
		}
	}
    
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
	
	//METHODS FOR SHOTS
	func createShot(atPoint location: CGPoint) -> Shot {
		let newShot = Shot(entity: NSEntityDescription.entityForName("Shot", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		//Set the location
		newShot.xLocation = location.x
		newShot.yLocation = location.y
		
		return newShot
	}
	
	func remove(shot: Shot) {
		TeamDataManager.managedContext.deleteObject(shot)
	}
	
	//METHODS FOR AUTONOMOUS CYCLES
	func createAutonomousCycle(inMatchPerformance matchPerformance: TeamMatchPerformance) -> AutonomousCycle {
		let newCycle = AutonomousCycle(entity: NSEntityDescription.entityForName("AutonomousCycle", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		newCycle.matchPerformance = matchPerformance
		
		return newCycle
	}
	
	//METHODS FOR DEFENSES
	func createDefense(withName name: String, inCategory category: Character) -> Defense {
		//Format the strings first
		let categoryString = String(category)
		categoryString.uppercaseString
		
		//First check if this defense already exists
		let currentDefenses = getDefenses(inCategory: category)
		for defense in currentDefenses {
			if defense.defenseName == name {
				return defense
			}
		}
		
		let newDefense = Defense(entity: NSEntityDescription.entityForName("Defense", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newDefense.defenseName = name
		newDefense.category = categoryString
		
		return newDefense
	}
	
	func setDidBreachDefense(defense: Defense, inMatchPerformance matchPerformance: TeamMatchPerformance) {
		//Check if the defense is already labeled as breached
		//Get the alliance color
		let allianceColor = matchPerformance.allianceColor?.integerValue
		var allianceBreachedDefenses: [Defense]
		if allianceColor == 0 {
			allianceBreachedDefenses = matchPerformance.match?.blueDefensesBreached?.allObjects as! [Defense]
		} else {
			allianceBreachedDefenses = matchPerformance.match?.redDefensesBreached?.allObjects as! [Defense]
		}
		
		for breachedDefense in allianceBreachedDefenses {
			if breachedDefense == defense {
				//The breached defense is already saved, return
				return
			}
		}
		
		//Add the defense to the set
		allianceBreachedDefenses.append(defense)
		
		if allianceColor == 0 {
			matchPerformance.match?.blueDefensesBreached = NSSet(array: allianceBreachedDefenses)
		} else {
			matchPerformance.match?.redDefensesBreached = NSSet(array: allianceBreachedDefenses)
		}
	}
	
	func setDidNotBreachDefense(defense: Defense, inMatchPerformance matchPerformance: TeamMatchPerformance) {
		//Check to see if it is actually there
		let allianceColor = matchPerformance.allianceColor?.integerValue
		var allianceBreachedDefenses: [Defense]
		if allianceColor == 0 {
			allianceBreachedDefenses = matchPerformance.match?.blueDefensesBreached?.allObjects as! [Defense]
		} else {
			allianceBreachedDefenses = matchPerformance.match?.redDefensesBreached?.allObjects as! [Defense]
		}
		
		if !allianceBreachedDefenses.contains(defense) {
			//The defense is already not there, return
			return
		}
		
		//Remove the defense from the list of breached ones
		allianceBreachedDefenses.removeAtIndex(allianceBreachedDefenses.indexOf(defense)!)
		
		//Set it back in the match
		if allianceColor == 0 {
			matchPerformance.match?.blueDefensesBreached = NSSet(array: allianceBreachedDefenses)
		} else {
			matchPerformance.match?.redDefensesBreached = NSSet(array: allianceBreachedDefenses)
		}
	}
	
	func getLowBar() -> Defense {
		return getDefense(withName: "Low Bar")!
	}
	
	func getAllDefenses() -> [Defense] {
		return getDefenses(withPredicate: nil)
	}
	
	func getDefenses(inCategory category: Character) -> [Defense] {
		let predicate = NSPredicate(format: "%K like %@", "category", String(category))
		
		return getDefenses(withPredicate: predicate)
	}
	
	func getDefense(withName name: String) -> Defense? {
		let predicate = NSPredicate(format: "%K like %@", "defenseName", name)
		
		let defenses = getDefenses(withPredicate: predicate)
		
		return defenses.first
	}
	
	func getDefenses(withPredicate predicate: NSPredicate?) -> [Defense] {
		let fetchRequest = NSFetchRequest(entityName: "Defense")
		fetchRequest.predicate = predicate
		var results = [Defense]()
		do {
			results = try TeamDataManager.managedContext.executeFetchRequest(fetchRequest) as! [Defense]
		} catch {
			NSLog("Unable to retrieve defenses")
		}
		
		return results
	}
	
	//METHODS FOR TIME MARKERS
	func addTimeMarker(withEvent event: TimeMarkerEvent, atTime time: NSTimeInterval, inMatchPerformance matchPerformance: TeamMatchPerformance) {
		let newMarker = TimeMarker(entity: NSEntityDescription.entityForName("TimeMarker", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newMarker.event = event.rawValue
		newMarker.time = time
		newMarker.teamMatchPerformance = matchPerformance
	}
	
	//METHODS FOR DEFENSE CROSS TIMING
	func addDefenseCrossTime(forMatchPerformance matchPerformance: TeamMatchPerformance, inDefense defense: Defense, withTime time: NSTimeInterval) {
		let newCrossTime = DefenseCrossTime(entity: NSEntityDescription.entityForName("DefenseCrossTime", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newCrossTime.time = time
		newCrossTime.teamMatchPerformance = matchPerformance
		newCrossTime.defense = defense
	}
	
	enum TimeMarkerEvent: Int {
		case BallPickedUp
		case OffenseAttemptedShot
		case MovedToOffenseCourtyard
		case MovedToDefenseCourtyard
		case StartedCrossingDefense
		case FinishedCrossingDefense
		case MovedToNeutral
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
	
enum GamePart {
	case Autonomous
	case Teleop
}