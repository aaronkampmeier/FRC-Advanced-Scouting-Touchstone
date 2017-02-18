//
//  TeamMatchPerformance+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
import Crashlytics

open class TeamMatchPerformance: NSManagedObject {
    
    enum Alliance: String {
        case Red = "Red"
        case Blue = "Blue"
    }
    
    enum Slot: Int {
        case One = 1
        case Two = 2
        case Three = 3
    }
    
    var alliance: Alliance {
        get {
            return Alliance(rawValue: self.allianceColor)!
        }
    }
    
    var slot: Slot {
        get {
            return Slot(rawValue: self.allianceTeam?.intValue ?? 0)!
        }
    }
    
    var rankingPoints: Int? {
        switch allianceColor {
        case "Blue":
            return match?.local.blueRankingPoints?.intValue
        case "Red":
            return match?.local.redRankingPoints?.intValue
        default:
            assertionFailure()
            return -1
        }
    }
    
    var finalScore: Double? {
        switch allianceColor {
        case "Blue":
            return match?.local.blueFinalScore?.doubleValue
        case "Red":
            return match?.local.redFinalScore?.doubleValue
        default:
            assertionFailure()
            return -1
        }
    }
    
    var winningMargin: Double {
        let selfFinalScore = finalScore ?? 0
        switch allianceColor {
        case "Blue":
            return selfFinalScore - (match?.local.redFinalScore?.doubleValue ?? 0)
        case "Red":
            return selfFinalScore - (match?.local.blueFinalScore?.doubleValue ?? 0)
        default:
            assertionFailure()
            return -1
        }
    }
}
