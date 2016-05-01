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
	
	//MARK: Teams
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
				try getRootDraftBoard().teams = (draftBoard.copy() as! NSOrderedSet)
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
		var defenses = team.autonomousDefensesAbleToShootArray
		
		if canShootFrom {
			if !defenses.contains(defense) {
				defenses.append(defense)
			}
		} else {
			if let index = defenses.indexOf(defense) {
				defenses.removeAtIndex(index)
			}
		}
		
		team.autonomousDefensesAbleToShootArray = defenses
	}
    
	func addDefense(defense: Defense, toTeam team: Team, forPart part: GamePart) {
		var defenses: [Defense]
		//Retrieve the current defenses
		switch part {
		case .Autonomous:
			defenses = team.autonomousDefensesAbleToCrossArray
		case .Teleop:
			defenses = team.defensesAbleToCrossArray
		}
		
		//Add it if it isn't already there
		if !defenses.contains(defense) {
			defenses.append(defense)
		}
		
		//Set the data back
		switch part {
		case .Autonomous:
			team.autonomousDefensesAbleToCrossArray = defenses
		case .Teleop:
			team.defensesAbleToCrossArray = defenses
		}
	}
	
	func removeDefense(defense: Defense, fromTeam team: Team, forPart part: GamePart) {
		var defenses: [Defense]
		//Retrieve the current defenses
		switch part {
		case .Autonomous:
			defenses = team.autonomousDefensesAbleToCrossArray
		case .Teleop:
			defenses = team.defensesAbleToCrossArray
		}
		
		//Remove it if it is there
		if let index = defenses.indexOf(defense) {
			defenses.removeAtIndex(index)
		}
		
		//Set the data back
		switch part {
		case .Autonomous:
			team.autonomousDefensesAbleToCrossArray = defenses
		case .Teleop:
			team.defensesAbleToCrossArray = defenses
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
	
    //MARK: Regionals
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
    
    //MARK: Matches
    func createNewMatch(matchNumber: Int, inRegional regional: Regional) throws -> Match {
        //First, check to make sure it doesn't already exist
        guard (regional.regionalMatches?.allObjects as! [Match]).filter({return $0.matchNumber == matchNumber}).isEmpty else {
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
	
	
	//MARK: Defenses and Matches
	func setDefenses(inMatch match: Match, redOrBlue color: AllianceColor, defenseA: CategoryADefense, defenseB: CategoryBDefense, defenseC: CategoryCDefense, defenseD: CategoryDDefense) {
		let defenses = [defenseA.defense, defenseB.defense, defenseC.defense, defenseD.defense]
		
		switch color {
		case .Red:
			match.redDefensesArray = defenses
		case .Blue:
			match.blueDefensesArray = defenses
		}
	}
	
	func setDefenses(inMatch match: Match, redOrBlue color: AllianceColor, withDefenseArray defenses: [Defense]) throws {
		if !(defenses.count == 4) {throw DataManagingError.InvalidNumberOfDefenses}
		
		var defenseA: CategoryADefense?
		var defenseB: CategoryBDefense?
		var defenseC: CategoryCDefense?
		var defenseD: CategoryDDefense?
		
		for defense in defenses {
			if defense.category == .A {
				defenseA = CategoryADefense(rawValue: defense.rawValue)
			} else if defense.category == .B {
				defenseB = CategoryBDefense(rawValue: defense.rawValue)
			} else if defense.category == .C {
				defenseC = CategoryCDefense(rawValue: defense.rawValue)
			} else if defense.category == .D {
				defenseD = CategoryDDefense(rawValue: defense.rawValue)
			}
		}
		
		if defenseA == nil || defenseB == nil || defenseC == nil || defenseD == nil {
			throw DataManagingError.InvalidDefenseCategoryRepresentation
		}
		
		setDefenses(inMatch: match, redOrBlue: color, defenseA: defenseA!, defenseB: defenseB!, defenseC: defenseC!, defenseD: defenseD!)
	}
	
	enum AllianceColor: Int {
		case Blue = 0
		case Red = 1
	}
    
    func getTeamsForMatch(match: Match) -> [TeamMatchPerformance] {
        let teamPerformances = match.teamPerformances?.allObjects as! [TeamMatchPerformance]
        return teamPerformances
    }
	
    func getTimeOfMatch(match: Match) -> NSDate {
        return match.time!
    }
    
	func getMatches(forRegional regional: Regional) -> [Match]{
        return regional.regionalMatches?.allObjects as! [Match]
    }
	
	//MARK: Shots
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
	
	enum ShotGoal: Int {
		case Low
		case High
		case Both //Specifically for stats
	}
	
	//MARK: AutonomousCycles
	func createAutonomousCycle(inMatchPerformance matchPerformance: TeamMatchPerformance, atPlace place: Int) -> AutonomousCycle {
		let newCycle = AutonomousCycle(entity: NSEntityDescription.entityForName("AutonomousCycle", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		let mutableSet = matchPerformance.autonomousCycles?.mutableCopy() as! NSMutableOrderedSet
		mutableSet.insertObject(newCycle, atIndex: place)
		matchPerformance.autonomousCycles = (mutableSet.copy() as! NSOrderedSet)
		
		return newCycle
	}
	
	//MARK: Defenses
	func setDefense(defense: Defense, state: DefenseState, inMatchPerformance matchPerformance: TeamMatchPerformance) {
		let allianceColor = matchPerformance.allianceColor?.integerValue
		var allianceBreachedDefenses: [Defense]
		
		if allianceColor == 0 {
			allianceBreachedDefenses = matchPerformance.match?.blueBreachedDefensesArray ?? []
		} else {
			allianceBreachedDefenses = matchPerformance.match?.redBreachedDefensesArray ?? []
		}
		
		switch state {
		case .Breached:
			if !allianceBreachedDefenses.contains(defense) {
				allianceBreachedDefenses.append(defense)
			}
		case .NotBreached:
			if let index = allianceBreachedDefenses.indexOf(defense) {
				allianceBreachedDefenses.removeAtIndex(index)
			}
		}
		
		if allianceColor == 0 {
			matchPerformance.match?.blueBreachedDefensesArray = allianceBreachedDefenses
		} else {
			matchPerformance.match?.redBreachedDefensesArray = allianceBreachedDefenses
		}
	}
	
	enum DefenseState {
		case Breached
		case NotBreached
	}
	
	//MARK: Time Markers
	func addTimeMarker(withEvent event: TimeMarkerEventType, atTime time: NSTimeInterval, inMatchPerformance matchPerformance: TeamMatchPerformance) {
		let newMarker = TimeMarker(entity: NSEntityDescription.entityForName("TimeMarker", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newMarker.event = event.rawValue
		newMarker.time = time
		newMarker.teamMatchPerformance = matchPerformance
	}
	
	enum TimeMarkerEventType: Int, CustomStringConvertible {
		case BallPickedUp
		case AttemptedShot
		case MovedToOffenseCourtyard
		case MovedToDefenseCourtyard
		case CrossedDefense
		case MovedToNeutral
		case Contact
		case ContactDisruptingShot
		case BallPickedUpFromDefense
		case BallPickedUpFromNeutral
		case BallPickedUpFromOffense
		case SuccessfulHighShot
		case FailedHighShot
		case SuccessfulLowShot
		case FailedLowShot
		case Error
		
		var description: String {
			switch self {
			case .BallPickedUp:
				return "Ball Picked Up"
			case .AttemptedShot:
				return "Attempted Shot"
			case .MovedToOffenseCourtyard:
				return "Moved to Offense Courtyard"
			case .MovedToDefenseCourtyard:
				return "Moved to Defense Courtyard"
			case .CrossedDefense:
				return "Crossed Defense"
			case .MovedToNeutral:
				return "Moved to Neutral Zone"
			case .Contact:
				return "Contact"
			case .ContactDisruptingShot:
				return "Contact Disrupting Shot"
			case .BallPickedUpFromDefense:
				return "Ball Picked Up From Defense Courtyard"
			case .BallPickedUpFromNeutral:
				return "Ball Picked Up From Neutral Zone"
			case .BallPickedUpFromOffense:
				return "Ball Picked Up From Offense Courtyard"
			case .SuccessfulHighShot:
				return "Successful High Goal Shot"
			case .FailedHighShot:
				return "Failed High Goal Shot"
			case .SuccessfulLowShot:
				return "Successful Low Goal Shot"
			case .FailedLowShot:
				return "Failed Low Goal Shot"
			case .Error:
				return "Error: Unknown Time Marker"
			}
		}
	}
	
	struct TimeMarkerEvent {
		let time: NSTimeInterval
		let type: TimeMarkerEventType
		
		init(type: TimeMarkerEventType, atTime time: NSTimeInterval) {
			self.time = time
			self.type = type
		}
	}
	
	func timeOverview(forMatchPerformance matchPerformance: TeamMatchPerformance) -> [TimeMarkerEvent] {
		var timeOverview = [TimeMarkerEvent]()
		for timeMarker in matchPerformance.timeMarkers?.array as! [TimeMarker] {
			timeOverview.append(TimeMarkerEvent(type: timeMarker.timeMarkerEventType, atTime: timeMarker.time?.doubleValue ?? -1))
		}
		return timeOverview.sort() {first, second in
			return first.time < second.time
		}
	}
	
	//MARK: Defense Cross Timing
	func addDefenseCrossTime(forMatchPerformance matchPerformance: TeamMatchPerformance, inDefense defense: Defense, atTime time: NSTimeInterval) {
		let newCrossTime = DefenseCrossTime(entity: NSEntityDescription.entityForName("DefenseCrossTime", inManagedObjectContext: TeamDataManager.managedContext)!, insertIntoManagedObjectContext: TeamDataManager.managedContext)
		
		newCrossTime.endTime = time
		newCrossTime.duration = 0
		newCrossTime.teamMatchPerformance = matchPerformance
		newCrossTime.defense = defense.rawValue
	}
    
    enum DataManagingError: ErrorType {
        case DuplicateTeams
        case DuplicateStatsBoards
        case DuplicateMatchBoards
        case UnableToFetch
        case TypeAlreadyExists
        case UnableToGetStatsBoard
        case MatchAlreadyExists
		case InvalidNumberOfDefenses
		case InvalidDefenseCategoryRepresentation
        
        var errorDescription: String {
            switch self {
            case .DuplicateTeams:
                return "There are more than one team entities with the specified team number."
			case .InvalidNumberOfDefenses:
				return "There are the wrong number of defenses to be set in to a match."
			case .InvalidDefenseCategoryRepresentation:
				return "There was not a defense from every category in the defenses to be set in to the match."
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
	
	enum Defense: String, CustomStringConvertible, Hashable {
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
			return self.rawValue
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
		
		static var allDefenses: [Defense] {
			return [.Portcullis, .ChevalDeFrise, .Moat, .Ramparts, .Drawbridge, .SallyPort, .RockWall, .RoughTerrain, .LowBar]
		}
	}
	
	enum DefenseCategory: Int {
		case A
		case B
		case C
		case D
		case LowBar
		
		var defenses: [Defense] {
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
	
	enum CategoryADefense: String {
		case Portcullis = "Portcullis"
		case ChevalDeFrise = "Cheval de Frise"
		
		var defense: Defense {
			switch self {
			case .Portcullis:
				return .Portcullis
			case .ChevalDeFrise:
				return .ChevalDeFrise
			}
		}
	}
	
	enum CategoryBDefense: String {
		case Moat = "Moat"
		case Ramparts = "Ramparts"
		
		var defense: Defense {
			switch self {
			case .Moat:
				return .Moat
			case .Ramparts:
				return .Ramparts
			}
		}
	}
	
	enum CategoryCDefense: String {
		case Drawbridge = "Drawbridge"
		case SallyPort = "Sally Port"
		
		var defense: Defense {
			switch self {
			case .Drawbridge:
				return .Drawbridge
			case .SallyPort:
				return .SallyPort
			}
		}
	}
	
	enum CategoryDDefense: String {
		case RockWall = "Rock Wall"
		case RoughTerrain = "Rough Terrain"
		
		var defense: Defense {
			switch self {
			case .RockWall:
				return .RockWall
			case .RoughTerrain:
				return .RoughTerrain
			}
		}
	}