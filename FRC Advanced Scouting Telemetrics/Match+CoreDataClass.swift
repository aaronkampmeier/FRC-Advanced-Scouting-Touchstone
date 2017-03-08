//
//  Match+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


open class Match: NSManagedObject, Comparable {
    var competitionLevelEnum: CompetitionLevel {
        return CompetitionLevel(rawValue: self.competitionLevel!)!
    }
    
    enum CompetitionLevel: String, CustomStringConvertible {
        case Qualifier
        case Eliminator
        case QuarterFinal = "Quarter Finals"
        case SemiFinal = "Semi Final"
        case Final
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        var rankedPosition: Int {
            get {
                switch self {
                case .Qualifier:
                    return 0
                case .Eliminator:
                    return 1
                case .QuarterFinal:
                    return 2
                case .SemiFinal:
                    return 3
                case .Final:
                    return 4
                }
            }
        }
    }
    
    func teamMatchPerformance(forColor color: TeamMatchPerformance.Alliance, andSlot slot: TeamMatchPerformance.Slot) -> TeamMatchPerformance {
        let performances = (self.teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.alliance == color && $0.slot == slot})
        
        assert(performances.count == 1)
        
        return performances.first!
    }
    
    override open var description: String {
        get {
            if let setNumber = self.setNumber?.intValue {
                if self.competitionLevelEnum == .QuarterFinal || self.competitionLevelEnum == .SemiFinal {
                    return "\(self.competitionLevelEnum) \(setNumber) Match \(self.matchNumber!)"
                } else {
                    return "\(self.competitionLevelEnum) \(self.matchNumber!)"
                }
            } else {
                return "\(self.competitionLevelEnum) \(self.matchNumber!)"
            }
        }
    }
    
    static func ==(lhs: Match, rhs: Match) -> Bool {
        return (lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition && lhs.setNumber!.intValue == rhs.setNumber!.intValue && lhs.matchNumber!.intValue == rhs.matchNumber!.intValue)
    }
    
    public static func >(lhs: Match, rhs: Match) -> Bool {
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber!.intValue == rhs.setNumber!.intValue {
                return lhs.matchNumber!.intValue > rhs.matchNumber!.intValue
            } else {
                return lhs.setNumber!.intValue > rhs.setNumber!.intValue
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition > rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func >=(lhs: Match, rhs: Match) -> Bool {
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber!.intValue == rhs.setNumber!.intValue {
                return lhs.matchNumber!.intValue >= rhs.matchNumber!.intValue
            } else {
                return lhs.setNumber!.intValue >= rhs.setNumber!.intValue
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition >= rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func <(lhs: Match, rhs: Match) -> Bool {
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber!.intValue == rhs.setNumber!.intValue {
                return lhs.matchNumber!.intValue < rhs.matchNumber!.intValue
            } else {
                return lhs.setNumber!.intValue < rhs.setNumber!.intValue
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition < rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func <=(lhs: Match, rhs: Match) -> Bool {
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber!.intValue == rhs.setNumber!.intValue {
                return lhs.matchNumber!.intValue <= rhs.matchNumber!.intValue
            } else {
                return lhs.setNumber!.intValue <= rhs.setNumber!.intValue
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition <= rhs.competitionLevelEnum.rankedPosition
        }
    }
}
