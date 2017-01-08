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
    lazy var cachedLocal: LocalMatchPerformance = {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdatedTeams"), object: nil, queue: nil) {_ in self.cachedLocal = self.local()}
        return self.local()
    }()
    
    var rankingPoints: Int {
        switch allianceColor {
        case "Blue":
            return match?.cachedLocal.blueRankingPoints?.intValue ?? 0
        case "Red":
            return match?.cachedLocal.redRankingPoints?.intValue ?? 0
        default:
            assertionFailure()
            return -1
        }
    }
    
    var finalScore: Double {
        switch allianceColor {
        case "Blue":
            return match?.cachedLocal.blueFinalScore?.doubleValue ?? 0
        case "Red":
            return match?.cachedLocal.redFinalScore?.doubleValue ?? 0
        default:
            assertionFailure()
            return -1
        }
    }
    
    var winningMargin: Double {
        let selfFinalScore = finalScore
        switch allianceColor {
        case "Blue":
            return selfFinalScore - (match?.cachedLocal.redFinalScore?.doubleValue ?? 0)
        case "Red":
            return selfFinalScore - (match?.cachedLocal.blueFinalScore?.doubleValue ?? 0)
        default:
            assertionFailure()
            return -1
        }
    }
}
