//
//  Statistics.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation

///Would like to redo the entire statistics handling to be more simplistic as follows:
//One function that you pass an object and it returns stats on the object (i.e. func stats(object: NSManagedObject) -> ApplicableStats)
//Then another option to specify a stat that you would like calculated on an object (to be used for easy sorting without calculating all stats)
//Or instead just add the stats as properties into the NSManagedObject Subclasses to call them directly and have them manage their own caching

enum StatValue: CustomStringConvertible, Equatable, Comparable {
    case Integer(Int)
    case Double(Double)
    case Bool(Bool)
    case String(String)
    case Percent(Double)
    case NoValue
    
    static func initWithOptional(value: Int?) -> StatValue {
        if let val = value {
            return StatValue.Integer(val)
        } else {
            return StatValue.NoValue
        }
    }
    
    static func initWithOptional(value: Double?) -> StatValue {
        if let val = value {
            if val.isNaN || val.isInfinite {
                return StatValue.NoValue
            } else {
                return StatValue.Double(val)
            }
        } else {
            return StatValue.NoValue
        }
    }
    
    static func initWithOptional(value: Bool?) -> StatValue {
        if let val = value {
            return StatValue.Bool(val)
        } else {
            return StatValue.NoValue
        }
    }
    
    static func initWithOptional(value: String?) -> StatValue {
        if let val = value {
            return StatValue.String(val)
        } else {
            return StatValue.NoValue
        }
    }
    
    static func initWithOptionalPercent(value: Double?) -> StatValue {
        if let val = value {
            if val.isNaN || val.isInfinite {
                return .NoValue
            } else {
                return StatValue.Percent(val)
            }
        } else {
            return .NoValue
        }
    }
    
    var description: String {
        get {
            switch self {
            case .Integer(let value):
                return value.description
            case .Double(let value):
                return value.description(roundedAt: 2)
            case .Percent(let value):
                return "\((value * 100).description(roundedAt: 1))%"
            case .Bool(let value):
                return value.description.capitalized
            case .String(let value):
                return value.description
            case .NoValue:
                return "No Value"
            }
        }
    }
    
    static func ==(lhs: StatValue, rhs: StatValue) -> Bool {
        switch (lhs, rhs) {
        case (.Integer(let a), .Integer(let b)) where a == b:
            return true
        case (.Double(let a), .Double(let b)) where a == b:
            return true
        case (.Bool(let a), .Bool(let b)) where a == b:
            return true
        case (.String(let a), .String(let b)) where a == b:
            return true
        case (.Percent(let a), .Percent(let b)) where a == b:
            return true
        default:
            return false
        }
    }
    
    static func <(lhs: StatValue, rhs: StatValue) -> Bool {
        switch (lhs, rhs) {
        case (.Integer(let a), .Integer(let b)) where a < b:
            return true
        case (.Double(let a), .Double(let b)) where a < b:
            return true
        case (.Percent(let a), .Percent(let b)) where a < b:
            return true
        case (.Bool(let a), .Bool(let b)):
            switch (a,b) {
            case (true, true):
                return false
            case (true, false):
                return false
            case (false, true):
                return true
            case (false, false):
                return false
            }
        case (.String(let a), .String(let b)) where a < b:
            return true
        case (.NoValue, _):
            return true
        case (_, .NoValue):
            return false
        default:
            return false
        }
    }
    
    static func >(lhs: StatValue, rhs: StatValue) -> Bool {
        switch (lhs, rhs) {
        case (.Integer(let a), .Integer(let b)) where a > b:
            return true
        case (.Double(let a), .Double(let b)) where a > b:
            return true
        case (.Percent(let a), .Percent(let b)) where a > b:
            return true
        case (.Bool(let a), .Bool(let b)):
            switch (a,b) {
            case (true, true):
                return false
            case (true, false):
                return true
            case (false, true):
                return false
            case (false, false):
                return false
            }
        case (.String(let a), .String(let b)) where a > b:
            return true
        case (.NoValue, _):
            return false
        case (_, .NoValue):
            return true
        default:
            return false
        }
    }
    
    static func <=(lhs: StatValue, rhs: StatValue) -> Bool {
        switch (lhs, rhs) {
        case (.Integer(let a), .Integer(let b)) where a <= b:
            return true
        case (.Double(let a), .Double(let b)) where a <= b:
            return true
        case (.Percent(let a), .Percent(let b)) where a <= b:
            return true
        case (.Bool(let a), .Bool(let b)):
            switch (a,b) {
            case (true, true):
                return true
            case (true, false):
                return false
            case (false, true):
                return true
            case (false, false):
                return true
            }
        case (.String(let a), .String(let b)) where a <= b:
            return true
        default:
            return false
        }
    }
    
    static func >=(lhs: StatValue, rhs: StatValue) -> Bool {
        switch (lhs, rhs) {
        case (.Integer(let a), .Integer(let b)) where a >= b:
            return true
        case (.Double(let a), .Double(let b)) where a >= b:
            return true
        case (.Percent(let a), .Percent(let b)) where a >= b:
            return true
        case (.Bool(let a), .Bool(let b)):
            switch (a,b) {
            case (true, true):
                return true
            case (true, false):
                return true
            case (false, true):
                return false
            case (false, false):
                return true
            }
        case (.String(let a), .String(let b)) where a >= b:
            return true
        default:
            return false
        }
    }
}

//To make a percent
func /(lhs: StatValue, rhs: StatValue) -> StatValue {
    switch (lhs, rhs) {
    case (.Double(let a), .Double(let b)):
        return StatValue.initWithOptionalPercent(value: a / b)
    case (.Integer(let a), .Integer(let b)):
        return StatValue.initWithOptionalPercent(value: Double(a) / Double(b))
    case (.Double(let a), .Integer(let b)):
        return StatValue.initWithOptionalPercent(value: a / Double(b))
    case (.Integer(let a), .Double(let b)):
        return StatValue.initWithOptionalPercent(value: Double(a) / b)
    default:
        return StatValue.NoValue
    }
}

extension Double {
    func description(roundedAt decimalsToRound: Int) -> String {
        return (floor(self * pow(10, Double(decimalsToRound))) / pow(Double(10), Double(decimalsToRound))).description
    }
}

//Grabbed off of http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift
//Provides a way to map the values in a dictionary with a single function
extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    ///Map through the values in a dictionary and return a dictionary with the same keys and new values
    func map<OutValue>( _ transform: (Value) throws -> OutValue) rethrows -> [Key: OutValue] {
        return Dictionary<Key, OutValue>(try map { (k, v) in (k, try transform(v)) })
    }
}

protocol HasStats {
    associatedtype StatName: StatNameable, Hashable
    var stats: [StatName:()->StatValue] {get} //A list of all the stats a class has and a function to compute it
}

protocol StatNameable {
    associatedtype StatName: Hashable
    static var allValues: [StatName] {get}
}

//This provides the basic stat functions to all stat-able classes using their stats property
extension HasStats {
    func allStats() -> [StatName] {
        return Array(stats.keys)
    }
    
    func statsAndValues() -> [StatName : StatValue?] {
        return stats.map {$0()}
    }
    
    func statValue(forStat stat: StatName) -> StatValue {
        return stats[stat]?() ?? StatValue.NoValue
    }
}
