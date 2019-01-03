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
import AWSAppSync

//let DidLogIntoSyncServerNotification = NSNotification.Name(rawValue: "DidLogIntoSyncServer")
//private let rosServerAddress = "fastapp.tech:9443"

//class RealmController {
//
//    static var realmController: RealmController = RealmController()
//
//    var generalRealm: Realm!
//    var syncedRealm: Realm!
//
//    let syncAuthURL = URL(string: "https://\(rosServerAddress)")!
//    var syncedRealmURL: URL?
//    var generalRealmURL: URL?
//    var scoutedRealmConfig: Realm.Configuration?
//    var generalRealmConfig: Realm.Configuration?
//    var currentSyncUser: SyncUser?
//
//    var tbaUpdatingReloader: TBAUpdatingDataReloader?
//
//    static let isSpectatorModeKey = "FAST-IsInSpectatorMode"
//    static var isInSpectatorMode: Bool {
//        return UserDefaults.standard.value(forKey: isSpectatorModeKey) as? Bool ?? false
//    }
//
//    private init() {
//
//    }
//}

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

enum ClimberType: String, CustomStringConvertible {
    case None
    case SlideBar = "Slide Bar"
    case HalfBar = "Half Bar"
    case FullBar = "Full Bar"
    case Deployable
    case BuddyDouble = "Buddy Double"
    case BuddyTriple = "Buddy Triple"
    
    var description: String {
        return self.rawValue
    }
    
    static let allValues: [ClimberType] = [.None, .SlideBar, .HalfBar, .FullBar, .Deployable, .BuddyDouble, .BuddyTriple]
}
