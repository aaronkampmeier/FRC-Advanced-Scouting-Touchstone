//
//  Team.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/15/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

extension CompetitionLevel: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .ef:
                return "Elimination Final"
            case .f:
                return "Final"
            case .qf:
                return "Quarterfinal"
            case .qm:
                return "Qualifier"
            case .sf:
                return "Semifinal"
            case .unknown(let value):
                return value
            }
        }
    }
    
    var rankedPosition: Int {
        get {
            switch self {
            case .qm:
                return 0
            case .ef:
                return 1
            case .qf:
                return 2
            case .sf:
                return 3
            case .f:
                return 4
            case .unknown(_):
                return -1
            }
        }
    }

}

extension Match {
    
    var description: String {
        get {
            if let setNumber = self.setNumber {
                if self.compLevel == .qf || self.compLevel == .sf {
                    return "\(self.compLevel) \(setNumber) Match \(self.matchNumber)"
                } else {
                    return "\(self.compLevel) \(self.matchNumber)"
                }
            } else {
                return "\(self.compLevel) \(self.matchNumber)"
            }
        }
    }
    
    static func ==(lhs: Match, rhs: Match) -> Bool {
        return (lhs.compLevel.rankedPosition == rhs.compLevel.rankedPosition && lhs.setNumber == rhs.setNumber && lhs.matchNumber == rhs.matchNumber)
    }
    
    public static func >(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate > secondDate
        }
        
        if lhs.compLevel.rankedPosition == rhs.compLevel.rankedPosition {
            if lhs.setNumber == rhs.setNumber {
                return lhs.matchNumber > rhs.matchNumber
            } else {
                return lhs.setNumber ?? 0 > rhs.setNumber ?? 0
            }
        } else {
            return lhs.compLevel.rankedPosition > rhs.compLevel.rankedPosition
        }
    }
    
    public static func >=(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate >= secondDate
        }
        
        if lhs.compLevel.rankedPosition == rhs.compLevel.rankedPosition {
            if lhs.setNumber == rhs.setNumber {
                return lhs.matchNumber >= rhs.matchNumber
            } else {
                return lhs.setNumber ?? 0 >= rhs.setNumber ?? 0
            }
        } else {
            return lhs.compLevel.rankedPosition >= rhs.compLevel.rankedPosition
        }
    }
    
    public static func <(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate < secondDate
        }
        
        if lhs.compLevel.rankedPosition == rhs.compLevel.rankedPosition {
            if lhs.setNumber == rhs.setNumber {
                return lhs.matchNumber < rhs.matchNumber
            } else {
                return lhs.setNumber ?? 0 < rhs.setNumber ?? 0
            }
        } else {
            return lhs.compLevel.rankedPosition < rhs.compLevel.rankedPosition
        }
    }
    
    public static func <=(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate <= secondDate
        }
        
        if lhs.compLevel.rankedPosition == rhs.compLevel.rankedPosition {
            if lhs.setNumber == rhs.setNumber {
                return lhs.matchNumber <= rhs.matchNumber
            } else {
                return lhs.setNumber ?? 0 <= rhs.setNumber ?? 0
            }
        } else {
            return lhs.compLevel.rankedPosition <= rhs.compLevel.rankedPosition
        }
    }
}
