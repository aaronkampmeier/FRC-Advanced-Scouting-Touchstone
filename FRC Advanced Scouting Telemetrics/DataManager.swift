//
//  DataManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//Remake of TeamDataManager for the newer data model

class DataManager {
	
	static let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
	
	//MARK: Saving and deleting
	fileprivate func save() {
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
	
	func delete(_ objectsToDelete: NSManagedObject...) {
		for object in objectsToDelete {
			DataManager.managedContext.delete(object)
		}
	}
    
    func delete(_ objectsToDelete: [NSManagedObject]) {
        for object in objectsToDelete {
            DataManager.managedContext.delete(object)
        }
    }
    
	
	//MARK: - Team Ranking
	func getLocalTeamRankingObject() -> LocalTeamRanking {
        let fetchedObjects: [LocalTeamRanking]
        do {
            fetchedObjects = try DataManager.managedContext.fetch(LocalTeamRanking.fetchRequest())
        } catch {
            fetchedObjects = []
            NSLog("Problem fetching LocalTeamRanking object")
        }
		
		if fetchedObjects.count == 1 {
			return fetchedObjects[0]
		} else if fetchedObjects.count == 0 {
			//Create new localTeamRanking object
			let newObject = LocalTeamRanking(entity: NSEntityDescription.entity(forEntityName: "LocalTeamRanking", in: DataManager.managedContext)!, insertInto: DataManager.managedContext)
			return newObject
		} else {
			//There is more than one LocalTeamRanking objects, compile them into one
			let newObject = LocalTeamRanking(entity: NSEntityDescription.entity(forEntityName: "LocalTeamRanking", in: DataManager.managedContext)!, insertInto: DataManager.managedContext)
			
			let compiledObject = fetchedObjects.reduce(newObject) {reducedObject, partialRanker in
				reducedObject.addToLocalTeams(partialRanker.localTeams ?? NSOrderedSet())
				self.delete(partialRanker)
				return reducedObject
			}
			
			return compiledObject
		}
	}
	
	///Returns an array of Team objects ordered by their local general ranking
	fileprivate func simpleLocalTeamRanking() -> [Team] {
		let orderedLocalTeams = getLocalTeamRankingObject().localTeams?.array as! [LocalTeam]
		
        return LocalToUniversalConversion<LocalTeam,Team>(localObjects: orderedLocalTeams).convertToUniversal()!
	}
	
    //Use this function when getting local team rankings, not the simpleLocalTeamRanking
	///Returns an array of Team objects ordered by their local ranking for specified event
	func localTeamRanking(forEvent event: Event? = nil) -> [Team] {
        return event != nil ? localTeamRanking(forLocalEvent: event!.local) : simpleLocalTeamRanking()
	}
    
    func localTeamRanking(forEvent event: Event) -> [LocalTeam] {
        return localTeamRanking(forLocalEvent: event.local)
    }
	
	///Returns an array of Team objects ordered by their local ranking for specified event
    func localTeamRanking(forLocalEvent localEvent: LocalEvent) -> [Team] {
        let orderedLocalTeams: [LocalTeam] = localTeamRanking(forLocalEvent: localEvent)
		
		return LocalToUniversalConversion<LocalTeam,Team>(localObjects: orderedLocalTeams).convertToUniversal()!
	}
    
    func localTeamRanking(forLocalEvent localEvent: LocalEvent) -> [LocalTeam] {
        return localEvent.rankedTeams?.array as! [LocalTeam]
    }
    
    //Reorder the team ranking
    func moveTeam(from fromIndex: Int, to toIndex: Int, inEvent event: LocalEvent? = nil) {
        if let localEvent = event {
            let movedTeam = localEvent.rankedTeams?.array[fromIndex] as! LocalTeam
            localEvent.removeFromRankedTeams(at: fromIndex)
            localEvent.insertIntoRankedTeams(movedTeam, at: toIndex)
        } else {
            let teamRankingObject = getLocalTeamRankingObject()
            let movedTeam = teamRankingObject.localTeams?.array[fromIndex] as! LocalTeam
            teamRankingObject.removeFromLocalTeams(at: fromIndex)
            teamRankingObject.insertIntoLocalTeams(movedTeam, at: toIndex)
        }
        commitChanges()
    }
    
    func moveTeam(from fromIndex: Int, to toIndex: Int, inEvent event: Event? = nil) {
        moveTeam(from: fromIndex, to: toIndex, inEvent: event?.local)
    }
    
    //MARK: - Teams
    ///Fetches one team with the specified number. Only use if fetching one team do not use sequentially.
    func team(withTeamNumber teamNumber: String) -> Team? {
        let fetchRequest: NSFetchRequest<Team> = Team.specificFR()
        fetchRequest.predicate = NSPredicate(format: "teamNumber like %@", argumentArray: [teamNumber])
        
        let teams: [Team]
        do {
            teams = try DataManager.managedContext.fetch(fetchRequest)
        } catch {
            NSLog("Unable to fetch team with error: \(error)")
            teams = []
        }
        
        assert(teams.count <= 1)
        return teams.first
    }
    
    func teamEventPerformances(inEvent event: Event) -> [TeamEventPerformance] {
        return event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
    }
	
	func getEvents() -> [Event] {
		var events = [Event]()
		if #available(iOS 10.0, *) {
			do {
				events = try DataManager.managedContext.fetch(Event.specificFR())
			} catch {
				
			}
		} else {
			// Fallback on earlier versions
			do {
				events = try DataManager.managedContext.fetch(Event.specificFR())
			} catch {
				
			}
		}
		return events
	}
    
    func eventPerformance(forTeam team: Team, inEvent event: Event) -> TeamEventPerformance {
        //Get two sets
        let eventPerformances: Set<TeamEventPerformance> = Set(event.teamEventPerformances?.allObjects as! [TeamEventPerformance])
        
        let teamPerformances = Set(team.eventPerformances?.allObjects as! [TeamEventPerformance])
        
        //Combine the two sets to find the one in both
        let teamEventPerformance = Array(eventPerformances.intersection(teamPerformances)).first!
        return teamEventPerformance
    }
    
    //MARK: - Events
    func events() -> [Event] {
        let events: [Event]
        do {
            events = try DataManager.managedContext.fetch(Event.specificFR())
        } catch {
            NSLog("Unable to fetch events")
            events = []
        }
        
        return events
    }
    
    //MARK: - Matches
    func matches(inEvent event: Event) -> [Match] {
        return event.matches?.allObjects as! [Match]
    }
    
    func matches() -> [Match] {
        let fetchRequest: NSFetchRequest<Match> = Match.specificFR()
        let matches: [Match]
        do {
            matches = try DataManager.managedContext.fetch(fetchRequest)
        } catch {
            matches = []
            NSLog("Unable to fetch all matches")
        }
        return matches
    }
}

enum TimeMarkerEvent: String, CustomStringConvertible {
    case LoadedFuel = "Loaded Fuel"
    case ScoredFuel = "Scored Fuel"
    case LoadedGear = "Loaded Gear"
    case ScoredGear = "Scored Gear"
    case Defended
    
    case Error
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}


enum ProgrammingLanguage: String, CustomStringConvertible {
    case Java
    case CPlusPlus = "C++"
    case LabView = "Lab View"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static var allValues: [ProgrammingLanguage] {
        get {
            return [.Java, .CPlusPlus, .LabView]
        }
    }
    
    static var allStringValues: [String] {
        get {
            return ProgrammingLanguage.allValues.map({$0.description})
        }
    }
}

//MARK: - Game-Specific Properties
enum StartingPosition: String, CustomStringConvertible {
    case LoadingStation = "Loading Station"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static var allPositions: [StartingPosition] {
        get {
            return [.LoadingStation]
        }
    }
}

enum Peg: String, CustomStringConvertible {
    case Peg1 = "Peg 1"
    case Peg2 = "Peg 2"
    case Peg3 = "Peg 3"
    
    var description: String {
        get {
            return rawValue
        }
    }
    
    var pegNumber: Int {
        get {
            switch self {
            case .Peg1:
                return 1
            case .Peg2:
                return 2
            case .Peg3:
                return 3
            }
        }
    }
    
    static func peg(forNumber number: Int) -> Peg? {
        switch number {
        case 1:
            return .Peg1
        case 2:
            return .Peg2
        case 3:
            return .Peg3
        default:
            return nil
        }
    }
    
    static var allValues: [Peg] {
        get {
            return [.Peg1, .Peg2, .Peg3]
        }
    }
    
    static var allStringValues: [String] {
        get {
            return Peg.allValues.map({$0.description})
        }
    }
}

enum Capability: String, CustomStringConvertible {
    case Yes
    case Somewhat
    case No
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static var allValues: [Capability] {
        get {
            return [.Yes, .Somewhat, .No]
        }
    }
    
    static var allStringValues: [String] {
        get {
            return Capability.allValues.map({$0.description})
        }
    }
}

enum SimpleCapability: String, CustomStringConvertible {
    case Yes
    case No
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static var allValues: [SimpleCapability] {
        get {
            return [.Yes, .No]
        }
    }
    
    static var allStringValues: [String] {
        get {
            return SimpleCapability.allValues.map({$0.description})
        }
    }
}

enum RopeClimbStatus: String, CustomStringConvertible {
    case Successful
    case Attempted
    case NotAttempted = "Not Attempted"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}

enum DefenseType: String, CustomStringConvertible {
    case Shooting
    case Moving
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}


//MARK: - Universal-Local Translations

//For the NSManagedObject Subclasses to inherit
protocol HasLocalEquivalent: class {
    associatedtype SelfObject: NSManagedObject
    associatedtype LocalType: NSManagedObject
    var localEntityName: String {get}
    var key: String? {get set}
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject>
    static func specificFR() -> NSFetchRequest<SelfObject>
    var transientLocal: LocalType? {get set}
}

protocol HasUniversalEquivalent: class {
    associatedtype SelfObject: NSManagedObject
    associatedtype UniversalType: HasLocalEquivalent
    var universalEntityName: String {get}
    var key: String? {get set}
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject>
    static func specificFR() -> NSFetchRequest<SelfObject>
    var transientUniversal: UniversalType.SelfObject? {get set}
}

extension HasUniversalEquivalent {
    ///Returns the universal object and sets the transient property for quick future fetching
    var universal: UniversalType.SelfObject? {
        get {
            if let universalObject = transientUniversal {
                return universalObject
            } else {
                let universalObject = fetchUniversalObject()
                self.transientUniversal = universalObject
                return universalObject
            }
        }
    }
    
    ///Fetches the universal object, does not set it into the transient property
    func fetchUniversalObject() -> UniversalType.SelfObject? {
        let fetchRequest = NSFetchRequest<UniversalType.SelfObject>(entityName: universalEntityName)
        fetchRequest.predicate = NSPredicate(format: "key LIKE %@", argumentArray: [self.key!])
        do {
            let objects = try DataManager.managedContext.fetch(fetchRequest)
            assert(objects.count <= 1)
            return objects.first
        } catch {
            NSLog("Unable to fetch Universal Objects")
            assertionFailure()
            return nil
        }
    }
}

extension HasLocalEquivalent {
    ///Returns the local object and sets the transient property for quick future fetching
    var local: LocalType {
        get {
            if let localObject = transientLocal {
                return localObject
            } else {
                let localObject = fetchLocalObject()!
                self.transientLocal = localObject
                return localObject
            }
        }
    }
    
    ///Fetches the local object, does not set it into the transient property
    func fetchLocalObject() -> LocalType? {
        let fetchRequest = NSFetchRequest<LocalType>(entityName: localEntityName)
        fetchRequest.predicate = NSPredicate(format: "key LIKE %@", argumentArray: [self.key!])
        do {
            let objects = try DataManager.managedContext.fetch(fetchRequest)
            return objects.first
        } catch {
            NSLog("Unable to fetch Local Objects")
            exit(EXIT_FAILURE)
        }
    }
}

//Used for grouping a universal and its local object together
struct ObjectPair<U:HasLocalEquivalent, L:HasUniversalEquivalent> where L.UniversalType == U, L:NSManagedObject, U:NSManagedObject, L.SelfObject == L, U.SelfObject == U {
    let universal: U
    let local: L
    
    var key: String {
        return universal.key!
    }
    
    init(universal: U, local: L) {
        self.universal = universal
        self.local = local
    }
    
    //Init an array of ObjectPairs from an array of universals and locals. The two arrays must be the same size.
    static func fromArrays(_ universals: [U], locals: [L]) -> [ObjectPair<U,L>]? {
        if universals.count != locals.count {
            return nil
        }
        
        var objectPairs = [ObjectPair<U,L>]()
        for (index, universal) in universals.enumerated() {
            objectPairs.append(ObjectPair<U,L>(universal: universal, local: locals[index]))
        }
        return objectPairs
    }
    
    static func fromArray(_ universals: [U]) -> [ObjectPair<U,L>]? {
        let locals = UniversalToLocalConversion<U,L>(universalObjects: universals).convertToLocal()
        
        return fromArrays(universals, locals: locals)
    }
    
    static func fromArray(_ locals: [L]) -> [ObjectPair<U,L>]? {
        let universals = LocalToUniversalConversion<L,U>(localObjects: locals).convertToUniversal()!
        
        return fromArrays(universals, locals: locals)
    }
}

//When using fetched properties it is not a good idea to individually access many objects' fetched properties together because then numerous fetch requests will be queued at the same time which can be really slow. Instead this method uses one fetch request to grab all the wanted objects.
///Returns the local objects for the universal objects given (and in the same order). Use this instead of accessing multiple fetched properties back-to-back.
class UniversalToLocalConversion<U:HasLocalEquivalent, L:HasUniversalEquivalent> where L:NSManagedObject, L.SelfObject == L, L.UniversalType == U {
    fileprivate let universalObjects: [U]
    
    init(universalObjects: [U]) {
        self.universalObjects = universalObjects
    }
    
    func convertToLocal() -> [L] {
        let fetchRequest: NSFetchRequest<L> = L.specificFR() 
        
        //Create the array of predicates to compare local key values with universal key values
        var predicates: [NSPredicate] = []
        for object in universalObjects {
            predicates.append(NSPredicate(format: "key like %@", argumentArray: [object.key!]))
        }
        //Add them all to the compound predicate
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = compoundPredicate
        
        let fetchedLocals: [L]
        do {
            fetchedLocals = try DataManager.managedContext.fetch(fetchRequest)
        } catch {
            NSLog("Unable to fetch local objects for multiple universal objects")
            return []
        }
        
        assert(fetchedLocals.count == universalObjects.count)
        
        //Sort the fetched locals to be in the same order as their universal counterparts
        let sortedFetchedLocals = fetchedLocals.sorted() {localFirst, localSecond in
            let universalFirstIndex = universalObjects.index() {$0.key == localFirst.key}
            let universalSecondIndex = universalObjects.index() {$0.key == localSecond.key}
            return universalFirstIndex! < universalSecondIndex!
        }
        
        return sortedFetchedLocals
    }
}

class LocalToUniversalConversion<L: HasUniversalEquivalent, U:HasLocalEquivalent> where U:NSManagedObject, U.SelfObject == U {
    fileprivate let localObjects: [L]
    
    init(localObjects: [L]) {
        self.localObjects = localObjects
    }
    
    func convertToUniversal() -> [U]? {
        let fetchRequest: NSFetchRequest<U> = U.specificFR()
        
        //Create the array of predicates to compare local key values with universal key values
        var predicates: [NSPredicate] = []
        for object in localObjects {
            predicates.append(NSPredicate(format: "key like %@", argumentArray: [object.key!]))
        }
        //Add them all to the compound predicate
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        
        fetchRequest.predicate = compoundPredicate
        
        let fetchedUniversals: [U]
        do {
            fetchedUniversals = try DataManager.managedContext.fetch(fetchRequest)
        } catch {
            NSLog("Unable to fetch local objects for multiple universal objects")
            return []
        }
        
        print("Predicates: \(predicates.count)")
        print("Fetched Universals: \(fetchedUniversals.count)")
        print("Local objects: \(localObjects.count)")
        
        if fetchedUniversals.count != localObjects.count {
            NSLog("Amount of Fetched Universals not equal to the given objects, caused by syncing with someone who has added different events than you")
            //But actually this could happen because it is being synced with other devices that might have different events added
//            return nil
        }
        
        //Sort the fetched locals to be in the same order as their universal counterparts
        let sortedFetchedUniversals = fetchedUniversals.sorted() {localFirst, localSecond in
            let universalFirstIndex = localObjects.index() {$0.key == localFirst.key}
            let universalSecondIndex = localObjects.index() {$0.key == localSecond.key}
            return universalFirstIndex! < universalSecondIndex!
        }
        
        return sortedFetchedUniversals
    }
}
