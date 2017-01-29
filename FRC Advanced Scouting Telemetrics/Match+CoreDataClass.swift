//
//  Match+CoreDataClass.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


public class Match: NSManagedObject {
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
}
