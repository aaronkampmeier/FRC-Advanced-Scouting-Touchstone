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

public class TeamMatchPerformance: NSManagedObject {
    
    enum Alliance: String {
        case Red = "Red"
        case Blue = "Blue"
    }
    
    var rankingPoints: Int {
        switch allianceColor {
        case "Blue":
            return match?.local.blueRankingPoints?.intValue ?? 0
        case "Red":
            return match?.local.redRankingPoints?.intValue ?? 0
        default:
            assertionFailure()
            return -1
        }
    }
    
    var finalScore: Double {
        switch allianceColor {
        case "Blue":
            return match?.local.blueFinalScore?.doubleValue ?? 0
        case "Red":
            return match?.local.redFinalScore?.doubleValue ?? 0
        default:
            assertionFailure()
            return -1
        }
    }
    
    var winningMargin: Double {
        let selfFinalScore = finalScore
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
