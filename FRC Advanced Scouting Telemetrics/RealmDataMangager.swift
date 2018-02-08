//
//  RealmDataMangager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/7/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

//NOTE: With realm, you can only use objects on the thread they were created! See Realm Swift Model docs. You can use ThreadSafeReference to pass objects.

import Foundation
import RealmSwift
import Crashlytics

let DidLogIntoSyncServerNotification = NSNotification.Name(rawValue: "DidLogIntoSyncServer")
private let rosServerAddress = "192.168.2.124:9080"

class RealmController {
    
    static var realmController: RealmController = RealmController()
    
    let generalRealm: Realm
    
    var syncedRealm: Realm
    
    let syncAuthURL = URL(string: "http://\(rosServerAddress)")!
    var currentRealmURL:URL?
    var currentSyncUser: SyncUser?
    
    private init() {
        var generalRealmConfig = Realm.Configuration()
        
        generalRealmConfig.fileURL = generalRealmConfig.fileURL?.deletingLastPathComponent().appendingPathComponent("General Realm.realm")
        generalRealmConfig.objectTypes = [Team.self,Match.self,TeamEventPerformance.self,Event.self,TeamMatchPerformance.self]
        
        generalRealm = try! Realm(configuration: generalRealmConfig)
        
        syncedRealm = try! Realm()
        if let currentUser = SyncUser.current {
            //Use this user to log in
            currentSyncUser = currentUser
            openSyncedRealm(withSyncUser: currentUser)
        } else {
            //Is not logged in
            currentSyncUser = nil
        }
    }
    
    //Right now just logging in user, not registering new ones
    func logIn(toTeam teamNumber: String, withUsername username: String, andPassword password: String, completionHandler: @escaping (Error?)->Void) {
        SyncUser.logIn(with: SyncCredentials.usernamePassword(username: username, password: password, register: true), server: syncAuthURL) {syncUser, error in
            if let error = error {
                CLSNSLogv("Error Signing In: \(error)", getVaList([]))
                completionHandler(error)
            } else {
                //User sync user
                self.openSyncedRealm(withSyncUser: syncUser!)
                completionHandler(nil)
                self.currentSyncUser = syncUser
            }
        }
    }
    
    func openSyncedRealm(withSyncUser syncUser: SyncUser) {
        let realmURL = URL(string: "realm://\(rosServerAddress)/~/scouted_data")!
        currentRealmURL = realmURL
        
        //Create sync config with sync user
        let syncConfig = SyncConfiguration(user: syncUser, realmURL: realmURL)
        var scoutedRealmConfig = Realm.Configuration(syncConfiguration: syncConfig)
        
        //Set the object types to be used in the Synced Realm to keep it separate from the other realm
        scoutedRealmConfig.objectTypes = [GeneralRanker.self, EventRanker.self, ScoutedTeam.self, ScoutedMatch.self, ScoutedMatchPerformance.self, TimeMarker.self]
        
        do {
            //Attempt to open the realm
            self.syncedRealm = try Realm(configuration: scoutedRealmConfig)
            NotificationCenter.default.post(name: DidLogIntoSyncServerNotification, object: self)
            CLSNSLogv("Did log into and open synced realm", getVaList([]))
        } catch {
            CLSNSLogv("Error opening synced realm: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    func delete(object: Object) {
        do {
            try object.realm?.write {
                object.realm?.delete(object)
            }
        } catch {
            CLSNSLogv("Unable to delete object", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    func delete(objects: [Object]) {
        for object in objects {
            self.delete(object: object)
        }
    }
    
    //MARK: - Team Ranking
    func getGeneralTeamRanker() -> GeneralRanker {
        let generalRanker = syncedRealm.object(ofType: GeneralRanker.self, forPrimaryKey: "General Ranker")
        
        if let ranker = generalRanker {
            return ranker
        } else {
            //Create a ranker
            let newRanker = GeneralRanker()
            try! syncedRealm.write {
                syncedRealm.add(newRanker)
            }
            return newRanker
        }
    }
    
    private func simpleTeamRanking() -> [Team] {
        var  orderedTeams = Array(getGeneralTeamRanker().rankedTeams)
        
        //TODO: Better managment of scouted teams that aren't tracked on device
        orderedTeams = orderedTeams.filter {$0.general != nil}
        
        return orderedTeams.map {$0.general!}
    }
    
    func getTeamRanker(forEvent event: Event) -> EventRanker? {
        return syncedRealm.object(ofType: EventRanker.self, forPrimaryKey: event.key)
    }
    
    func teamRanking(forEvent event: Event) -> [ScoutedTeam] {
        let eventRanker = getTeamRanker(forEvent: event)
        return Array(eventRanker!.rankedTeams)
    }
    
    func teamRanking(forEvent event: Event) -> [Team] {
        let rankedTeams: [ScoutedTeam] = teamRanking(forEvent: event)
        
        return rankedTeams.map {$0.general!}
    }
    
    ///Returns an array of Team objects ordered by their local ranking for specified event
    func teamRanking(forEvent event: Event? = nil) -> [Team] {
        return event != nil ? teamRanking(forEvent: event) : simpleTeamRanking()
    }
    
    func moveTeam(from fromIndex: Int, to toIndex: Int, inEvent event: Event? = nil) {
        try! syncedRealm.write {
            if let event = event {
                let ranker = getTeamRanker(forEvent: event)
                ranker!.rankedTeams.move(from: fromIndex, to: toIndex)
            } else {
                let teamRankingObject = getGeneralTeamRanker()
                
                teamRankingObject.rankedTeams.move(from: fromIndex, to: toIndex)
            }
        }
    }
    
    //MARK: - Teams
    func team(forTeamNumber teamNumber: String) -> Team? {
        if let team = generalRealm.object(ofType: Team.self, forPrimaryKey: "frc\(teamNumber)") {
            return team
        } else {
            CLSNSLogv("Unable to find team for team number: \(teamNumber)", getVaList([]))
            return nil
        }
    }
    
    func eventPerformance(forTeam team: Team, atEvent event: Event) -> TeamEventPerformance {
        let eventPerformances = Set(event.teamEventPerformances)
        let teamPerformances = Set(team.eventPerformances)
        
        let teamEventPerformance = eventPerformances.intersection(teamPerformances).first!
        return teamEventPerformance
    }
    
    //MARK: - Editing a realm
    enum RealmType {
        case General
        case Synced
        
        var realm: Realm {
            get {
                switch self {
                case .General:
                    return RealmController.realmController.generalRealm
                case .Synced:
                    return RealmController.realmController.syncedRealm
                }
            }
        }
    }
    @discardableResult func genericWrite(onRealm realm: RealmType, blockToWrite: (() throws ->Void)) -> Bool {
        do {
            try realm.realm.write(blockToWrite)
            return true
        } catch {
            CLSNSLogv("Failed to write to realm with error: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
            return false
        }
    }
}

//MARK: - General vs Scouted Models
protocol HasScoutedEquivalent: class {
    associatedtype SelfObject: Object
    associatedtype ScoutedType: Object
    var key: String {get set}
    var cache: ScoutedType? {get set}
}

protocol HasGeneralEquivalent: class {
    associatedtype SelfObject: Object
    associatedtype GeneralType: Object, HasScoutedEquivalent
    var key: String {get set}
    var cache: GeneralType? {get set}
}

extension HasGeneralEquivalent {
    ///Returns the universal object and sets the transient property for quick future fetching
    var general: GeneralType? {
        get {
            if let universalObject = cache {
                return universalObject
            } else {
                let universalObject = fetchGeneralObject()
                self.cache = universalObject
                return universalObject
            }
        }
    }
    
    ///Fetches the universal object, does not set it into the transient property
    func fetchGeneralObject() -> GeneralType? {
        return RealmController.realmController.generalRealm.object(ofType: GeneralType.self, forPrimaryKey: key)
    }
}

extension HasScoutedEquivalent {
    ///Returns the local object and sets the transient property for quick future fetching
    var scouted: ScoutedType {
        get {
            if let localObject = cache {
                return localObject
            } else {
                let localObject = fetchScoutedObject()!
                self.cache = localObject
                return localObject
            }
        }
    }
    
    ///Fetches the local object, does not set it into the transient property
    func fetchScoutedObject() -> ScoutedType? {
        return RealmController.realmController.syncedRealm.object(ofType: ScoutedType.self, forPrimaryKey: key)
    }
}

//MARK: - Enums
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

enum GamePlayStrategy: String, CustomStringConvertible {
    case Offensive
    case Defensive
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static var allValues: [GamePlayStrategy] {
        get {
            return [.Offensive, .Defensive]
        }
    }
    
    static var allStringValues: [String] {
        get {
            return GamePlayStrategy.allValues.map({$0.description})
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

enum ClimbStatus: String, CustomStringConvertible {
    case Successful
    case Attempted
    case NotAttempted = "Not Attempted"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}
