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

///DEPRECATED Use DataManager instead

class TeamDataManager {
    
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
	
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
	func saveTeamNumber(_ number: String, atRank rank: Int? = nil, performCommit shouldSave: Bool = true) -> Team {
        //Get the entity for a Team and then create a new one
        let entity = NSEntityDescription.entity(forEntityName: "Team", in: TeamDataManager.managedContext)
        
        let team = Team(entity: entity!, insertInto: TeamDataManager.managedContext)
        
        //Set the value we want
        team.teamNumber = number
        
        //Add it to the root draft board
//		if rank == nil {
//			do {
//				let rootDraftBoard = try getRootDraftBoard()
//				team.draftBoard = rootDraftBoard
//			} catch {
//				NSLog("Could not save team to draft board")
//			}
//		} else {
//			do {
//				let draftBoard = try getRootDraftBoard().teams?.mutableCopy() as! NSMutableOrderedSet
//				draftBoard.insert(team, at: rank!)
//				try getRootDraftBoard().teams = (draftBoard.copy() as! NSOrderedSet)
//			} catch {
//				NSLog("Could not save team to draft board")
//			}
//		}
		
		if shouldSave {
			//Try to save
			commitChanges()
		}
        return team
    }
    
    func deleteTeam(_ teamForDeletion: Team) {
        TeamDataManager.managedContext.delete(teamForDeletion)
        
        save()
    }
	
//	func delete(_ objectsToDelete: NSManagedObject...) {
//		for object in objectsToDelete {
//			TeamDataManager.managedContext.delete(object)
//		}
//	}
	
//	func setDefenseAbleToShootFrom(_ defense: Defense, toTeam team: Team, canShootFrom: Bool) {
//		var defenses = team.autonomousDefensesAbleToShootArray
//		
//		if canShootFrom {
//			if !defenses.contains(defense) {
//				defenses.append(defense)
//			}
//		} else {
//			if let index = defenses.index(of: defense) {
//				defenses.remove(at: index)
//			}
//		}
//		
//		team.autonomousDefensesAbleToShootArray = defenses
//	}
//    
//	func addDefense(_ defense: Defense, toTeam team: Team, forPart part: GamePart) {
//		var defenses: [Defense]
//		//Retrieve the current defenses
//		switch part {
//		case .autonomous:
//			defenses = team.autonomousDefensesAbleToCrossArray
//		case .teleop:
//			defenses = team.defensesAbleToCrossArray
//		}
//		
//		//Add it if it isn't already there
//		if !defenses.contains(defense) {
//			defenses.append(defense)
//		}
//		
//		//Set the data back
//		switch part {
//		case .autonomous:
//			team.autonomousDefensesAbleToCrossArray = defenses
//		case .teleop:
//			team.defensesAbleToCrossArray = defenses
//		}
//	}
//	
//	func removeDefense(_ defense: Defense, fromTeam team: Team, forPart part: GamePart) {
//		var defenses: [Defense]
//		//Retrieve the current defenses
//		switch part {
//		case .autonomous:
//			defenses = team.autonomousDefensesAbleToCrossArray
//		case .teleop:
//			defenses = team.defensesAbleToCrossArray
//		}
//		
//		//Remove it if it is there
//		if let index = defenses.index(of: defense) {
//			defenses.remove(at: index)
//		}
//		
//		//Set the data back
//		switch part {
//		case .autonomous:
//			team.autonomousDefensesAbleToCrossArray = defenses
//		case .teleop:
//			team.defensesAbleToCrossArray = defenses
//		}
//	}
	
//    func getRootDraftBoard() throws -> DraftBoard {
//        //Create a fetch request for the draft board
//        let fetchRequest = NSFetchRequest<DraftBoard>(entityName: "DraftBoard")
//        
//        do {
//            let results = try TeamDataManager.managedContext.fetch(fetchRequest)
//            
//            if results.count > 1 {
//                NSLog("Somehow multiple draft boards were created. This could be the result of a sync error.")
//				//Attempt to merge them
//				var board1Mutable = results[0].teams?.array as! [Team]
//				let board2Mutable = results[1].teams?.array as! [Team]
//				for team in board2Mutable {
//					board1Mutable.append(team)
//				}
//				TeamDataManager.managedContext.delete(results[1])
//				results[0].teams = NSOrderedSet(array: board1Mutable)
//				return try getRootDraftBoard()
//            } else if results.count == 1 {
//                return results.first!
//            } else if results.count == 0 {
//                NSLog("Creating new draft board")
//                //Create a new draft board and return it
//                let newDraftBoard = DraftBoard(entity: NSEntityDescription.entity(forEntityName: "DraftBoard", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
//                return newDraftBoard
//            }
//        } catch let error as NSError {
//            NSLog("Could not fetch \(error), \(error.userInfo)")
//        }
//        throw DataManagingError.unableToFetch
//    }
    
//    func moveTeam(_ fromIndex: Int, toIndex: Int) throws {
//        do {
//            let rootDraftBoard = try getRootDraftBoard()
//            
//            //Move the team in the draft board array
//            let mutableArray = rootDraftBoard.teams?.mutableCopy() as! NSMutableOrderedSet
//            let movedTeam = mutableArray[fromIndex]
//            mutableArray.removeObject(at: fromIndex)
//            mutableArray.insert(movedTeam, at: toIndex)
//            
//            rootDraftBoard.teams = mutableArray.copy() as? NSOrderedSet
//        } catch {
//            throw error
//        }
//        
//        save()
//    }
    
    func getTeams(Predicate predicate: NSPredicate?) -> [Team] {
        var teams: [Team] = [Team]()
        
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        
        fetchRequest.predicate = predicate
        
        do {
            teams = try TeamDataManager.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        
        return teams
    }
    
//    func getTeams(_ numberForSorting: String) -> [Team] {
//        return getTeams(Predicate: NSPredicate(format: "%K like %@", argumentArray: ["teamNumber", "\(numberForSorting)"]))
//    }
    
//    func getTeams() -> [Team] {
//        return getTeams(Predicate: nil)
//    }
//	
//	func getTeams(inRegional regional: Regional) -> [TeamRegionalPerformance]{
//		return regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance]
//	}
//
//    func getDraftBoard() throws -> [Team]{
//        do {
//            return try getRootDraftBoard().teams?.array as! [Team]
//        } catch {
//            throw error
//        }
//    }
	
    //MARK: Regionals
    /*
    func addRegional(regionalNumber num: Int, withName name: String) -> Regional {
        //Check to make sure that the regional doesn't exist
        let previousRegionals = getAllRegionals().filter({$0.regionalNumber!.intValue == num})
        guard previousRegionals.isEmpty else {
            return previousRegionals[0]
        }
        
        let newRegional = Regional(entity: NSEntityDescription.entity(forEntityName: "Regional", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
        
        newRegional.name = name
        newRegional.regionalNumber = num as NSNumber?
        return newRegional
    }
    
    func getAllRegionals() -> [Regional] {
        let fetchRequest = NSFetchRequest<Regional>(entityName: "Regional")
        
        var regionals = [Regional]()
        do {
            regionals = try TeamDataManager.managedContext.fetch(fetchRequest)
        } catch {
            regionals = []
        }
        
        return regionals
    }
	
	func getRegional(withNumber num: Int) -> Regional? {
		let fetchRequest = NSFetchRequest<Regional>(entityName: "Regional")
		
		fetchRequest.predicate = NSPredicate(format: "%k like %@", argumentArray: ["regionalNumber", "\(num)"])
		
		do {
			let results = try TeamDataManager.managedContext.fetch(fetchRequest)
			assert(results.count <= 1)
			return results[0]
		} catch {
			return nil
		}
	}
 */
    
//    func addTeamToRegional(_ team: Team, regional: Regional) -> TeamRegionalPerformance {
//		//Check if there is already a regional performance for it
//        let previousPerformances = (team.regionalPerformances?.allObjects as! [TeamRegionalPerformance]).filter({$0.regional == regional})
//        guard previousPerformances.isEmpty else {
//            return previousPerformances[0]
//        }
//		
//		//If there isn't, then create one
//        let newRegionalPerformance = TeamRegionalPerformance(entity: NSEntityDescription.entity(forEntityName: "TeamRegionalPerformance", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
//        
//        newRegionalPerformance.regional = regional
//        newRegionalPerformance.team = team
//        return newRegionalPerformance
//    }
	
    /*
	func delete(Regional regional: Regional) {
		TeamDataManager.managedContext.delete(regional)
	}
    
    //MARK: Matches
    func createNewMatch(_ matchNumber: Int, inRegional regional: Regional) throws -> Match {
        //First, check to make sure it doesn't already exist
        guard (regional.regionalMatches?.allObjects as! [Match]).filter({return $0.matchNumber!.intValue == matchNumber}).isEmpty else {
            throw DataManagingError.matchAlreadyExists
        }
        
        let newMatch = Match(entity: NSEntityDescription.entity(forEntityName: "Match", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
        
        newMatch.matchNumber = matchNumber as NSNumber?
        
        newMatch.regional = regional
		return newMatch
    }
    
    func deleteMatch(_ match: Match) {
        TeamDataManager.managedContext.delete(match)
    }
 */
	
    /*
	//Newer and preferred method for setting teams in a match
	func setTeamsInMatch(_ teamsAndPlaces: [TeamAndMatchPlace], inMatch match: Match) {
		for teamAndPlace in teamsAndPlaces {
			let team = teamAndPlace.team
			
			//Check if there is a previous match performance for this place
			var alreadyExists: Bool = false
			var preExistentTeamPerformance: TeamMatchPerformance?
			for teamPerformance in match.teamPerformances!.allObjects as! [TeamMatchPerformance] {
				if teamPerformance.allianceColor?.intValue == teamAndPlace.allianceColorAndTeam["Color"] && teamPerformance.allianceTeam?.intValue == teamAndPlace.allianceColorAndTeam["Team"] {
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
					matchPerformance.allianceColor = teamAndPlace.allianceColorAndTeam["Color"] as NSNumber?
					matchPerformance.allianceTeam = teamAndPlace.allianceColorAndTeam["Team"] as NSNumber?
					
					//Add it to the participating teams
					//participatingTeamPerformances.addObject(matchPerformance)
				} else {
					//Check to see if the pre-existent match performance is the same team as the new team
					if preExistentTeamPerformance?.regionalPerformance?.value(forKey: "Team") as! Team == team {
						//The team is the same, we're done
					} else {
						//The team is different, delete the old one and make a new one
						deleteMatchPerformance(preExistentTeamPerformance!)
						
						let matchPerformance = createNewMatchPerformance(withTeam: team, inMatch: match)
						
						//Set the alliance color and team
						matchPerformance.allianceColor = teamAndPlace.allianceColorAndTeam["Color"] as NSNumber?
						matchPerformance.allianceTeam = teamAndPlace.allianceColorAndTeam["Team"] as NSNumber?
						
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
 */
	/*
	func deleteMatchPerformance(_ matchPerformance: TeamMatchPerformance) {
		//Get the regional performance before deletion
		let regionalPerformance = matchPerformance.regionalPerformance!
		
		//Delete the match performance
		TeamDataManager.managedContext.delete(matchPerformance)
		
		//Check if it is the last match performance in the regional performance
		if regionalPerformance.matchPerformances?.count == 0 {
			//It was the last match performance, delete the regional performance now, too
			TeamDataManager.managedContext.delete(regionalPerformance)
		}
	}
	
	func createNewMatchPerformance(withTeam team: Team, inMatch match: Match) -> TeamMatchPerformance {
		//Get the regional performance for the team
		let regionalPerformance = addTeamToRegional(team, regional: match.regional!)
		
		//Create the new match performance
		let newMatchPerformance = TeamMatchPerformance(entity: NSEntityDescription.entity(forEntityName: "TeamMatchPerformance", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
		
		newMatchPerformance.regionalPerformance = regionalPerformance
		newMatchPerformance.match = match
		
		return newMatchPerformance
	}
 */
	
	enum TeamAndMatchPlace {
		case blue1(Team?)
		case blue2(Team?)
		case blue3(Team?)
		case red1(Team?)
		case red2(Team?)
		case red3(Team?)
		
		var team: Team? {
			switch self {
			case .blue1(let x):
				return x
			case .blue2(let x):
				return x
			case .blue3(let x):
				return x
			case .red1(let x):
				return x
			case .red2(let x):
				return x
			case .red3(let x):
				return x
			}
		}
		
		var allianceColorAndTeam: [String:Int] {
			switch self {
			case .blue1(_):
				return ["Color":0, "Team":1]
			case .blue2(_):
				return ["Color":0, "Team":2]
			case .blue3(_):
				return ["Color":0, "Team":3]
			case .red1(_):
				return ["Color":1, "Team":1]
			case .red2(_):
				return ["Color":1, "Team":2]
			case .red3(_):
				return ["Color":1, "Team":3]
			}
		}
	}
//	
//	func set(_ didCaptureTower: Bool, inMatch match: Match, forAlliance alliance: AllianceColor) {
//		switch alliance {
//		case .red:
//			match.redCapturedTower = didCaptureTower as NSNumber?
//		case .blue:
//			match.blueCapturedTower = didCaptureTower as NSNumber?
//		}
//	}
	
	
	//MARK: Defenses and Matches
//	func setDefenses(inMatch match: Match, redOrBlue color: AllianceColor, defenseA: CategoryADefense, defenseB: CategoryBDefense, defenseC: CategoryCDefense, defenseD: CategoryDDefense) {
//		let defenses = [defenseA.defense, defenseB.defense, defenseC.defense, defenseD.defense]
//		
//		switch color {
//		case .red:
//			match.redDefensesArray = defenses
//		case .blue:
//			match.blueDefensesArray = defenses
//		}
//	}
	
//	func setDefenses(inMatch match: Match, redOrBlue color: AllianceColor, withDefenseArray defenses: [Defense]) throws {
//		if !(defenses.count == 4) {throw DataManagingError.invalidNumberOfDefenses}
//		
//		var defenseA: CategoryADefense?
//		var defenseB: CategoryBDefense?
//		var defenseC: CategoryCDefense?
//		var defenseD: CategoryDDefense?
//		
//		for defense in defenses {
//			if defense.category == .a {
//				defenseA = CategoryADefense(rawValue: defense.rawValue)
//			} else if defense.category == .b {
//				defenseB = CategoryBDefense(rawValue: defense.rawValue)
//			} else if defense.category == .c {
//				defenseC = CategoryCDefense(rawValue: defense.rawValue)
//			} else if defense.category == .d {
//				defenseD = CategoryDDefense(rawValue: defense.rawValue)
//			}
//		}
//		
//		if defenseA == nil || defenseB == nil || defenseC == nil || defenseD == nil {
//			throw DataManagingError.invalidDefenseCategoryRepresentation
//		}
//		
//		setDefenses(inMatch: match, redOrBlue: color, defenseA: defenseA!, defenseB: defenseB!, defenseC: defenseC!, defenseD: defenseD!)
//	}
	
	enum AllianceColor: Int {
		case blue = 0
		case red = 1
	}
    
    func getTeamsForMatch(_ match: Match) -> [TeamMatchPerformance] {
        let teamPerformances = match.teamPerformances?.allObjects as! [TeamMatchPerformance]
        return teamPerformances
    }
	
    func getTimeOfMatch(_ match: Match) -> Date {
        return match.time! as Date
    }
    
//	func getMatches(forRegional regional: Regional) -> [Match]{
//        return regional.regionalMatches?.allObjects as! [Match]
//    }
	
	//MARK: Shots
//	func createShot(atPoint location: CGPoint) -> Shot {
//		let newShot = Shot(entity: NSEntityDescription.entity(forEntityName: "Shot", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
//		
//		//Set the location
//		newShot.xLocation = location.x as NSNumber?
//		newShot.yLocation = location.y as NSNumber?
//		
//		return newShot
//	}
//	
//	func remove(_ shot: Shot) {
//		TeamDataManager.managedContext.delete(shot)
//	}
//	
//	enum ShotGoal: Int {
//		case low
//		case high
//		case both //Specifically for stats
//	}
	
	//MARK: AutonomousCycles
	func createAutonomousCycle(inMatchPerformance matchPerformance: TeamMatchPerformance, atPlace place: Int) -> AutonomousCycle {
		let newCycle = AutonomousCycle(entity: NSEntityDescription.entity(forEntityName: "AutonomousCycle", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
		
//		let mutableSet = matchPerformance.autonomousCycles?.mutableCopy() as! NSMutableOrderedSet
//		mutableSet.insert(newCycle, at: place)
//		matchPerformance.autonomousCycles = (mutableSet.copy() as! NSOrderedSet)
		
		return newCycle
	}
	
	//MARK: Defenses
//	func setDefense(_ defense: Defense, state: DefenseState, inMatchPerformance matchPerformance: TeamMatchPerformance) {
//		let allianceColor = matchPerformance.allianceColor?.intValue
//		var allianceBreachedDefenses: [Defense]
//		
//		if allianceColor == 0 {
//			allianceBreachedDefenses = matchPerformance.match?.blueBreachedDefensesArray ?? []
//		} else {
//			allianceBreachedDefenses = matchPerformance.match?.redBreachedDefensesArray ?? []
//		}
//		
//		switch state {
//		case .breached:
//			if !allianceBreachedDefenses.contains(defense) {
//				allianceBreachedDefenses.append(defense)
//			}
//		case .notBreached:
//			if let index = allianceBreachedDefenses.index(of: defense) {
//				allianceBreachedDefenses.remove(at: index)
//			}
//		}
//		
//		if allianceColor == 0 {
//			matchPerformance.match?.blueBreachedDefensesArray = allianceBreachedDefenses
//		} else {
//			matchPerformance.match?.redBreachedDefensesArray = allianceBreachedDefenses
//		}
//	}
//	
//	enum DefenseState {
//		case breached
//		case notBreached
//	}
	
	//MARK: Time Markers
//	func addTimeMarker(withEvent event: TimeMarkerEventType, atTime time: TimeInterval, inMatchPerformance matchPerformance: TeamMatchPerformance) {
//		let newMarker = TimeMarker(entity: NSEntityDescription.entity(forEntityName: "TimeMarker", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
//		
//		newMarker.event = event.rawValue as NSNumber?
//		newMarker.time = time as NSNumber?
////		newMarker.teamMatchPerformance = matchPerformance
//	}
	
	enum TimeMarkerEventType: Int, CustomStringConvertible {
		case ballPickedUp
		case attemptedShot
		case movedToOffenseCourtyard
		case movedToDefenseCourtyard
		case crossedDefense
		case movedToNeutral
		case contact
		case contactDisruptingShot
		case ballPickedUpFromDefense
		case ballPickedUpFromNeutral
		case ballPickedUpFromOffense
		case successfulHighShot
		case failedHighShot
		case successfulLowShot
		case failedLowShot
		case error
		
		var description: String {
			switch self {
			case .ballPickedUp:
				return "Ball Picked Up"
			case .attemptedShot:
				return "Attempted Shot"
			case .movedToOffenseCourtyard:
				return "Moved to Offense Courtyard"
			case .movedToDefenseCourtyard:
				return "Moved to Defense Courtyard"
			case .crossedDefense:
				return "Crossed Defense"
			case .movedToNeutral:
				return "Moved to Neutral Zone"
			case .contact:
				return "Contact"
			case .contactDisruptingShot:
				return "Contact Disrupting Shot"
			case .ballPickedUpFromDefense:
				return "Ball Picked Up From Defense Courtyard"
			case .ballPickedUpFromNeutral:
				return "Ball Picked Up From Neutral Zone"
			case .ballPickedUpFromOffense:
				return "Ball Picked Up From Offense Courtyard"
			case .successfulHighShot:
				return "Successful High Goal Shot"
			case .failedHighShot:
				return "Failed High Goal Shot"
			case .successfulLowShot:
				return "Successful Low Goal Shot"
			case .failedLowShot:
				return "Failed Low Goal Shot"
			case .error:
				return "Error: Unknown Time Marker"
			}
		}
	}
	
    
	struct TimeMarkerEvent {
		let time: TimeInterval
		let type: TimeMarkerEventType
		
		init(type: TimeMarkerEventType, atTime time: TimeInterval) {
			self.time = time
			self.type = type
		}
	}
	
	func timeOverview(forMatchPerformance matchPerformance: TeamMatchPerformance) -> [TimeMarkerEvent] {
		var timeOverview = [TimeMarkerEvent]()
//		for timeMarker in matchPerformance.timeMarkers?.array as! [TimeMarker] {
//			timeOverview.append(TimeMarkerEvent(type: timeMarker.timeMarkerEventType, atTime: timeMarker.time?.doubleValue ?? -1))
//		}
		return timeOverview.sorted() {first, second in
			return first.time < second.time
		}
	}
	
	//MARK: Defense Cross Timing
//	func addDefenseCrossTime(forMatchPerformance matchPerformance: TeamMatchPerformance, inDefense defense: Defense, atTime time: TimeInterval) {
//		let newCrossTime = DefenseCrossTime(entity: NSEntityDescription.entity(forEntityName: "DefenseCrossTime", in: TeamDataManager.managedContext)!, insertInto: TeamDataManager.managedContext)
//		
//		newCrossTime.endTime = time as NSNumber?
//		newCrossTime.duration = 0
//		newCrossTime.teamMatchPerformance = matchPerformance
//		newCrossTime.defense = defense.rawValue
//	}
    
    enum DataManagingError: Error {
        case duplicateTeams
        case duplicateStatsBoards
        case duplicateMatchBoards
        case unableToFetch
        case typeAlreadyExists
        case unableToGetStatsBoard
        case matchAlreadyExists
		case invalidNumberOfDefenses
		case invalidDefenseCategoryRepresentation
        
        var errorDescription: String {
            switch self {
            case .duplicateTeams:
                return "There are more than one team entities with the specified team number."
			case .invalidNumberOfDefenses:
				return "There are the wrong number of defenses to be set in to a match."
			case .invalidDefenseCategoryRepresentation:
				return "There was not a defense from every category in the defenses to be set in to the match."
            default:
                return "A problem occured with data management."
            }
        }
    }
}
	
enum GamePart {
	case autonomous
	case teleop
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
				return .a
			case .Moat, .Ramparts:
				return .b
			case .Drawbridge, .SallyPort:
				return .c
			case .RockWall, .RoughTerrain:
				return .d
			case .LowBar:
				return .lowBar
			}
		}
		
		static var allDefenses: [Defense] {
			return [.Portcullis, .ChevalDeFrise, .Moat, .Ramparts, .Drawbridge, .SallyPort, .RockWall, .RoughTerrain, .LowBar]
		}
	}
	
	enum DefenseCategory: Int {
		case a
		case b
		case c
		case d
		case lowBar
		
		var defenses: [Defense] {
			switch self {
			case .a:
				return [.Portcullis, .ChevalDeFrise]
			case .b:
				return [.Moat, .Ramparts]
			case .c:
				return [.Drawbridge, .SallyPort]
			case .d:
				return [.RockWall, .RoughTerrain]
			case .lowBar:
				return [.LowBar]
			}
		}
		
		init(category: Character) {
			switch category {
			case "A":
				self = .a
			case "B":
				self = .b
			case "C":
				self = .c
			case "D":
				self = .d
			default:
				self = .lowBar
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
