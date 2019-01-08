//
//  Team.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/15/18.
//  Copyright © 2018 Kampfire Technologies. All rights reserved.
//

import Foundation
import RealmSwift

//@objcMembers class Match: Object, HasScoutedEquivalent {
//    dynamic var competitionLevel = ""
//    dynamic var key = ""
//    dynamic var matchNumber = 0
//    let setNumber = RealmOptional<Int>()
//    dynamic var time: Date?
//
//    let teamPerformances = LinkingObjects(fromType: TeamMatchPerformance.self, property: "match")
//    dynamic var event: Event?
//
//    override static func primaryKey() -> String {
//        return "key"
//    }
//
//    typealias SelfObject = Match
//    typealias LocalType = ScoutedMatch
//    dynamic var cache: ScoutedMatch?
//    override static func ignoredProperties() -> [String] {
//        return ["cache"]
//    }
//
//    var competitionLevelEnum: CompetitionLevel {
//        return CompetitionLevel(rawValue: self.competitionLevel)!
//    }
//
//    enum CompetitionLevel: String, CustomStringConvertible {
//        case Qualifier
//        case Eliminator
//        case QuarterFinal = "Quarter Finals"
//        case SemiFinal = "Semi Final"
//        case Fin/Users/aaron/Documents/Xcode Projects/FRC Advanced Scouting Telemetrics/FRC Advanced Scouting Telemetrics/Event.swiftal
//
//        var description: String {
//            get {
//                return self.rawValue
//            }
//        }
//
//        var rankedPosition: Int {
//            get {
//                switch self {
//                case .Qualifier:
//                    return 0
//                case .Eliminator:
//                    return 1
//                case .QuarterFinal:
//                    return 2
//                case .SemiFinal:
//                    return 3
//                case .Final:
//                    return 4
//                }
//            }
//        }
//    }
//
//    func teamMatchPerformance(forColor color: TeamMatchPerformance.Alliance, andSlot slot: TeamMatchPerformance.Slot) -> TeamMatchPerformance {
//        let performances = (self.teamPerformances).filter({$0.alliance == color && $0.slot == slot})
//
//        assert(performances.count == 1)
//
//        return performances.first!
//    }

extension Match {
    var description: String {
        get {
            if let setNumber = self.setNumber.value {
                if self.competitionLevelEnum == .QuarterFinal || self.competitionLevelEnum == .SemiFinal {
                    return "\(self.competitionLevelEnum) \(setNumber) Match \(self.matchNumber)"
                } else {
                    return "\(self.competitionLevelEnum) \(self.matchNumber)"
                }
            } else {
                return "\(self.competitionLevelEnum) \(self.matchNumber)"
            }
        }
    }
    
    static func ==(lhs: Match, rhs: Match) -> Bool {
        return (lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition && lhs.setNumber.value == rhs.setNumber.value && lhs.matchNumber == rhs.matchNumber)
    }
    
    public static func >(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate > secondDate
        }
        
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber.value == rhs.setNumber.value {
                return lhs.matchNumber > rhs.matchNumber
            } else {
                return lhs.setNumber.value ?? 0 > rhs.setNumber.value ?? 0
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition > rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func >=(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate >= secondDate
        }
        
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber.value == rhs.setNumber.value {
                return lhs.matchNumber >= rhs.matchNumber
            } else {
                return lhs.setNumber.value ?? 0 >= rhs.setNumber.value ?? 0
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition >= rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func <(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate < secondDate
        }
        
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber.value == rhs.setNumber.value {
                return lhs.matchNumber < rhs.matchNumber
            } else {
                return lhs.setNumber.value ?? 0 < rhs.setNumber.value ?? 0
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition < rhs.competitionLevelEnum.rankedPosition
        }
    }
    
    public static func <=(lhs: Match, rhs: Match) -> Bool {
        if let firstDate = lhs.time, let secondDate = rhs.time {
            return firstDate <= secondDate
        }
        
        if lhs.competitionLevelEnum.rankedPosition == rhs.competitionLevelEnum.rankedPosition {
            if lhs.setNumber.value == rhs.setNumber.value {
                return lhs.matchNumber <= rhs.matchNumber
            } else {
                return lhs.setNumber.value ?? 0 <= rhs.setNumber.value ?? 0
            }
        } else {
            return lhs.competitionLevelEnum.rankedPosition <= rhs.competitionLevelEnum.rankedPosition
        }
    }
}
