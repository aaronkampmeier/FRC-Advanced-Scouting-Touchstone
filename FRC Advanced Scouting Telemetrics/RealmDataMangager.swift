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
import AWSCognitoIdentityProvider
import AWSMobileClient

let DidLogIntoSyncServerNotification = NSNotification.Name(rawValue: "DidLogIntoSyncServer")
private let rosServerAddress = "fastapp.tech:9443"

class RealmController {
    
    static var realmController: RealmController = RealmController()
    
    var generalRealm: Realm!
    
    var syncedRealm: Realm!
    
    let syncAuthURL = URL(string: "https://\(rosServerAddress)")!
    var syncedRealmURL: URL?
    var generalRealmURL: URL?
    var currentSyncUser: SyncUser?
    
    private init() {
        generalRealm = nil
        
        syncedRealm = nil
        if let currentUser = SyncUser.current {
            //Use this user to log in
            currentSyncUser = currentUser
            openSyncedRealm(withSyncUser: currentUser)
        } else {
            //Is not logged in
            currentSyncUser = nil
        }
        
        SyncManager.shared.errorHandler = {error, session in
            CLSNSLogv("Realm Sync Error: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    func openSyncedRealm(withSyncUser syncUser: SyncUser) {
        
        let scoutedRealmURL = URL(string: "realms://\(rosServerAddress)/~/scouted_data")!
        syncedRealmURL = scoutedRealmURL
        
        //Create sync config with sync user
        let scoutedSyncConfig = SyncConfiguration(user: syncUser, realmURL: scoutedRealmURL)
        var scoutedRealmConfig = Realm.Configuration(syncConfiguration: scoutedSyncConfig)
        
        //Set the object types to be used in the Synced Realm to keep it separate from the other realm
        scoutedRealmConfig.objectTypes = [GeneralRanker.self, EventRanker.self, ScoutedTeam.self, ScoutedMatch.self, ScoutedMatchPerformance.self, TimeMarker.self, ComputedStats.self, TeamComment.self]
        
        //Now for the general realm
        let generalStructureRealmURL = URL(string: "realms://\(rosServerAddress)/~/general_structure")!
        generalRealmURL = generalStructureRealmURL
        let generalSyncConfig = SyncConfiguration(user: syncUser, realmURL: generalStructureRealmURL)
        var generalRealmConfig = Realm.Configuration(syncConfiguration: generalSyncConfig)
        generalRealmConfig.objectTypes = [Team.self,Match.self,TeamEventPerformance.self,Event.self,TeamMatchPerformance.self]
        
        do {
            //Attempt to open the realm
            self.generalRealm = try Realm(configuration: generalRealmConfig)
            self.syncedRealm = try Realm(configuration: scoutedRealmConfig)
            NotificationCenter.default.post(name: DidLogIntoSyncServerNotification, object: self)
            CLSNSLogv("Did log into and open realms", getVaList([]))
            Answers.logLogin(withMethod: "ROS", success: true, customAttributes: nil)
            
            //Now perform sanity checks quickly
            syncedRealm.beginWrite()
            
            //First remove duplicates
            let ranker = getGeneralTeamRanker()
            var seen = [ScoutedTeam]()
            var didRemoveDuplicates = false
            for team in ranker.rankedTeams {
                if seen.contains(team) {
                    ranker.rankedTeams.remove(at: ranker.rankedTeams.index(of: team)!)
                    didRemoveDuplicates = true
                } else {
                    seen.append(team)
                }
            }
            if didRemoveDuplicates {
                CLSNSLogv("Removing duplicates in general ranker", getVaList([]))
                Crashlytics.sharedInstance().recordCustomExceptionName("Did have to remove duplicate teams from ranker", reason: "There were duplicate teams in the ranker", frameArray: [])
            }
            
            //- FIXME: Now migrate notes if necessary,
            let scoutedTeams = syncedRealm.objects(ScoutedTeam.self)
            for scoutedTeam in scoutedTeams {
                if scoutedTeam.notes != "" && scoutedTeam.comments.count == 0 {
                    //There are old style notes and no comments so migrate these notes over
                    let comment = TeamComment()
                    comment.bodyText = scoutedTeam.notes
                    comment.datePosted = Date()
                    
                    syncedRealm.add(comment)
                    scoutedTeam.comments.append(comment)
                    
                    scoutedTeam.notes = "-UPDATE APP TO ADD/VIEW NOTES-"
                }
            }
            
            do {
                try syncedRealm.commitWrite()
            } catch {
                CLSNSLogv("Unable to commit sanity checks: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
        } catch {
            CLSNSLogv("Error opening realms: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
            Answers.logLogin(withMethod: "ROS", success: false, customAttributes: nil)
        }
    }
    
    func delete(object: Object) {
        delete(objects: [object])
    }
    
    func delete<T: Object>(objects: [T]) {
        let realm = objects.first?.realm
        
        var didStartWrite = false
        if !(realm?.isInWriteTransaction ?? false) {
            didStartWrite = true
            realm?.beginWrite()
        }
        
        for object in objects {
            realm?.delete(object)
        }
        
        if didStartWrite {
            do {
                try realm?.commitWrite()
            } catch {
                CLSNSLogv("Unable to delete objects", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
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
            
            if syncedRealm.isInWriteTransaction {
                syncedRealm.add(newRanker)
            } else {
                try! syncedRealm.write {
                    syncedRealm.add(newRanker)
                }
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
        if let eventRanker = getTeamRanker(forEvent: event) {
            return Array(eventRanker.rankedTeams)
        } else {
            return []
        }
    }
    
    func teamRanking(forEvent event: Event) -> [Team] {
        let rankedTeams: [ScoutedTeam] = teamRanking(forEvent: event)
        
        return rankedTeams.map {$0.general!}
    }
    
    ///Returns an array of Team objects ordered by their local ranking for specified event
    func teamRanking(_ event: Event? = nil) -> [Team] {
        return event != nil ? teamRanking(forEvent: event!) : simpleTeamRanking()
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
        if realm.realm.isInWriteTransaction {
            //If it's already in a write transaction just execute it
            try? blockToWrite()
            return true
        } else {
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
                
                if universalObject == nil {
                    //TODO: There is no general object for the scouted object, we should throw an error
                }
                
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
                let localObject = fetchScoutedObject()
                
                if let object = localObject {
                    self.cache = object
                    return object
                } else {
                    //There is no scouted equivalent, this is a problem
                    assertionFailure("No scouted object for local object")
                    Crashlytics.sharedInstance().recordCustomExceptionName("No scouted object for local object", reason: "Key: \(self.key)", frameArray: [])
                    exit(EXIT_FAILURE)
                }
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
    
    static let allValues: [ClimbStatus] = [.Successful, .Attempted, .NotAttempted]
}

enum ClimbAssistStatus: String, CustomStringConvertible {
    case SuccessfullyAssisted = "Successfully Assisted"
    case AttemptedAssist = "Attempted Assist"
    case DidNotAssist = "Did Not Assist"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static let allValues: [ClimbAssistStatus] = [.SuccessfullyAssisted, .AttemptedAssist, .DidNotAssist]
}

//2018
enum CubeSource: String, CustomStringConvertible {
    case Pile
    case Line
    case Portal
    case Other
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static let allValues: [CubeSource] = [.Pile, .Line, .Portal, .Other]
}

enum CubeDestination: String, CustomStringConvertible {
    case Scale
    case Switch
    case OpponentSwitch = "Opponent's Switch"
    case Vault
    case Dropped
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    static let allValues: [CubeDestination] = [.Scale, .Switch, .OpponentSwitch, .Vault, .Dropped]
}
