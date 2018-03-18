//
//  TeamEventPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import YCMatrix
import RealmSwift

@objcMembers class TeamEventPerformance: Object {
    dynamic var event: Event?
    dynamic var team: Team?
    let matchPerformances = LinkingObjects(fromType: TeamMatchPerformance.self, property: "teamEventPerformance")
    
    dynamic var key = ""
    override static func primaryKey() -> String {
        return "key"
    }
}

extension TeamEventPerformance: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.ScoutedMatches: {
                    let count = self.matchPerformances.reduce(0) {partialResult, matchPerformance in
                        if matchPerformance.scouted?.hasBeenScouted ?? false {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    return StatValue.Integer(count)
                },
                StatName.TotalMatchPoints:{return StatValue.initWithOptional(value: (Array(self.matchPerformances)).reduce(0) {(result, matchPerformance) in
                    return result + (matchPerformance.finalScore ?? 0)
                    })
                },
                StatName.TotalRankingPoints:{return StatValue.initWithOptional(value: (self.matchPerformances).reduce(0) {(result, matchPerformance) in
                    return result + (matchPerformance.rankingPoints ?? 0)
                    })
                },
                StatName.OPR: {
                    return StatValue.initWithOptional(value: evaluateOPR(forTeamPerformance: self))
                },
                StatName.CCWM: {
                    return StatValue.initWithOptional(value: evaluateCCWM(forTeamPerformance: self))
                },
                StatName.DPR: {
                    if let opr = evaluateOPR(forTeamPerformance: self){
                        if let ccwm = evaluateCCWM(forTeamPerformance: self) {
                            return StatValue.Double(opr - ccwm)
                        }
                    }
                    
                    return StatValue.NoValue
                },
                StatName.Rank: {
                    if let event = self.event {
                        if let computedStats = self.team?.scouted?.computedStats(forEvent: event) {
                            return StatValue.initWithOptional(value: computedStats.rank.value)
                        }
                    }
                    
                    return StatValue.NoValue
                },
                StatName.TotalWins: {
                    var winCount = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.winningMargin ?? 0 > 0 {
                            winCount += 1
                        }
                    }
                    
                    return StatValue.Integer(winCount)
                },
                StatName.TotalLosses: {
                    var lossCount = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.winningMargin ?? 0 < 0 {
                            lossCount += 1
                        }
                    }
                    
                    return StatValue.Integer(lossCount)
                },
                StatName.TotalTies: {
                    var tieCount = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.winningMargin == 0 {
                            tieCount += 1
                        }
                    }
                    
                    return StatValue.Integer(tieCount)
                },
                StatName.NumberOfMatches: {
                    return StatValue.initWithOptional(value: self.matchPerformances.count)
                },
                StatName.RankingScore: {
                    var totalRPs = 0
                    var totalMatchPerformances = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.scouted?.hasBeenScouted ?? false {
                            totalMatchPerformances += 1
                            totalRPs += matchPerformance.rankingPoints ?? 0
                        }
                    }
                    
                    if totalMatchPerformances == 0 {
                        return StatValue.NoValue
                    } else {
                        return StatValue.Double(Double(totalRPs)/Double(totalMatchPerformances))
                    }
                },
                StatName.SuccessfulClimbCount: {
                    let matchPerformances = self.matchPerformances
                    
                    let successfulClimbCount = matchPerformances.reduce(0) {partialResult, matchPerformance in
                        if (matchPerformance.scouted?.hasBeenScouted ?? false) && matchPerformance.scouted!.climbStatus == ClimbStatus.Successful.rawValue {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    return StatValue.Integer(successfulClimbCount)
                },
                StatName.ClimbSuccessRate: {
                    let numOfSuccesses: Int
                    switch self.statValue(forStat: .SuccessfulClimbCount) {
                    case .Integer(let val):
                        numOfSuccesses = val
                    default:
                        numOfSuccesses = 0
                    }
                    
                    let numOfScoutedMatches = (self.matchPerformances).reduce(0) {partialResult, matchPerformance in
                        if matchPerformance.scouted?.hasBeenScouted ?? false {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    if numOfScoutedMatches == 0 {
                        return StatValue.NoValue
                    } else {
                        return StatValue.Integer(numOfSuccesses) / StatValue.Integer(numOfScoutedMatches)
                    }
                },
                
                StatName.MajorityClimbStatus: {
                    return self.average(ofStat: .ClimbingStatus, forMatchPerformances: Array(self.matchPerformances))
                },
                StatName.MajorityClimbAssistStatus: {
                    return self.average(ofStat: .ClimbAssistStatus, forMatchPerformances: Array(self.matchPerformances))
                },
                StatName.ClimbAssistAttempts: {
                    let teamMatchPerformances = self.matchPerformances
                    
                    let climbAttemptCount = teamMatchPerformances.reduce(0) {partialResult, matchPerformance in
                        if (matchPerformance.scouted?.hasBeenScouted ?? false) && matchPerformance.scouted!.climbAssistStatus == ClimbAssistStatus.AttemptedAssist.rawValue || matchPerformance.scouted!.climbAssistStatus == ClimbAssistStatus.SuccessfullyAssisted.rawValue {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    return StatValue.Integer(climbAttemptCount)
                },
                
                
                StatName.AutoLineCrossCount: {
                    let crossCount = self.matchPerformances.reduce(0) {partialResult, matchPerformance in
                        if matchPerformance.scouted?.didCrossAutoLine ?? false {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    return StatValue.Integer(crossCount)
                },
                StatName.TotalGrabbedCubes: {
                    self.sum(ofStat: .TotalGrabbedCubes)
                },
                StatName.AverageGrabbedCubes: {
                    self.average(ofStat: .TotalGrabbedCubes)
                },
                StatName.PercentCubesFromPile: {
                    self.findPercentOfGrabbedCubes(withLocation: CubeSource.Pile.rawValue)
                },
                StatName.PercentCubesFromLine: {
                    self.findPercentOfGrabbedCubes(withLocation: CubeSource.Line.rawValue)
                },
                StatName.PercentCubesFromPortal: {
                    self.findPercentOfGrabbedCubes(withLocation: CubeSource.Portal.rawValue)
                },
                StatName.TotalPlacedCubes: {
                    self.sum(ofStat: .TotalPlacedCubes)
                },
                StatName.AveragePlacedCubes: {
                    self.average(ofStat: .TotalPlacedCubes)
                },
                StatName.StandardDeviationPlacedCubes: {
                    var placedCubeValues: [Double] = []
                    for matchPerformance in self.matchPerformances {
                        switch matchPerformance.statValue(forStat: TeamMatchPerformance.StatName.TotalPlacedCubes) {
                        case .Integer(let val):
                            placedCubeValues.append(Double(val))
                        default:
                            break
                        }
                    }
                    
                    if placedCubeValues.count > 0 {
                        return StatValue.Double(placedCubeValues.sd)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.PercentCubesInScale:{
                    self.findPercentOfPlacedCubes(withLocation: CubeDestination.Scale.rawValue)
                },
                StatName.PercentCubesInSwitch: {
                    self.findPercentOfPlacedCubes(withLocation: CubeDestination.Switch.rawValue)
                },
                StatName.PercentCubesInOpponentSwitch: {
                    self.findPercentOfPlacedCubes(withLocation: CubeDestination.OpponentSwitch.rawValue)
                },
                StatName.PercentCubesInVault: {
                    self.findPercentOfPlacedCubes(withLocation: CubeDestination.Vault.rawValue)
                },
                StatName.PercentCubesDropped: {
                    self.findPercentOfPlacedCubes(withLocation: CubeDestination.Dropped.rawValue)
                },
                
                StatName.MaxCubesInScale: {
                    StatValue.Integer(self.maxCubes(for: CubeDestination.Scale.rawValue))
                },
                StatName.MaxCubesInSwitch: {
                    StatValue.Integer(self.maxCubes(for: CubeDestination.Switch.rawValue))
                },
                StatName.MaxCubesInOpponentSwitch: {
                    StatValue.Integer(self.maxCubes(for: CubeDestination.OpponentSwitch.rawValue))
                },
                StatName.MaxCubesInVault: {
                    StatValue.Integer(self.maxCubes(for: CubeDestination.Vault.rawValue))
                },
                
                StatName.AverageCubesInScale: {
                    StatValue.initWithOptional(value: self.averageTimeMarkers(withLocation: CubeDestination.Scale.rawValue))
                },
                StatName.AverageCubesInSwitch: {
                    StatValue.initWithOptional(value: self.averageTimeMarkers(withLocation: CubeDestination.Switch.rawValue))
                },
                StatName.AverageCubesInOpponentSwitch: {
                    StatValue.initWithOptional(value: self.averageTimeMarkers(withLocation: CubeDestination.OpponentSwitch.rawValue))
                },
                StatName.AverageCubesInVault: {
                    StatValue.initWithOptional(value: self.averageTimeMarkers(withLocation: CubeDestination.Vault.rawValue))
                },
                StatName.AverageCubesDropped: {
                    StatValue.initWithOptional(value: self.averageTimeMarkers(withLocation: CubeDestination.Dropped.rawValue))
                }
            ]
        }
    }
    
    func average(ofStat stat: TeamMatchPerformance.StatName, forMatchPerformances performances: [TeamMatchPerformance]? = nil) -> StatValue {
        let matchPerformances: [TeamMatchPerformance]
        if performances == nil {
            matchPerformances = Array(self.matchPerformances)
        } else {
            matchPerformances = performances!
        }
        var isPercent = false
        var sum = 0.0
        var differentStrings = [String:Int]()
        var numOfAverages = 0
        
        for performance in matchPerformances {
            switch performance.statValue(forStat: stat) {
            case .Integer(let performanceValue):
                sum += Double(performanceValue)
                numOfAverages += 1
            case .Double(let performanceValue):
                sum += performanceValue
                numOfAverages += 1
            case .Percent(let performanceValue):
                isPercent = true
                sum += performanceValue
                numOfAverages += 1
            case .String(let string):
                //For counting the average of strings add all the different strings to a dictionary and keep track of the amount of each
                if differentStrings.keys.contains(string) {
                    differentStrings[string]! += 1
                } else {
                    differentStrings[string] = 1
                }
                numOfAverages += 1
            default:
                break
            }
        }
        
        if numOfAverages == 0 {
            return StatValue.NoValue
        } else if differentStrings.count != 0 {
            var highestCount: (String, Int)?
            for stringAndCount in differentStrings {
                if let highest = highestCount {
                    if stringAndCount.value > highest.1 {
                        highestCount = stringAndCount
                    }
                } else {
                    highestCount = stringAndCount
                }
            }
            
            return StatValue.initWithOptional(value: highestCount?.0)
        } else {
            if isPercent {
                return StatValue.Double(sum) / StatValue.Integer(numOfAverages)
            } else {
                return StatValue.Double(sum/Double(numOfAverages))
            }
        }
    }
    
    func sum(ofStat stat: TeamMatchPerformance.StatName, forMatchPerformances performances: [TeamMatchPerformance]? = nil) -> StatValue {
        let matchPerformances: [TeamMatchPerformance]
        if performances == nil {
            matchPerformances = Array(self.matchPerformances)
        } else {
            matchPerformances = performances!
        }
        
        var sum = 0.0
        var doesHaveValues = false
        var areDoubles = false
        
        for performance in matchPerformances {
            switch performance.statValue(forStat: stat) {
            case .Integer(let pVal):
                sum += Double(pVal)
                doesHaveValues = true
            case .Double(let pVal):
                sum += pVal
                doesHaveValues = true
                areDoubles = true
            default:
                break
            }
        }
        
        if doesHaveValues {
            if areDoubles {
                return StatValue.Double(sum)
            } else {
                return StatValue.Integer(Int(sum))
            }
        } else {
            return StatValue.NoValue
        }
    }
    
    func timeMarkers(withAssociatedLocations assocLocation: String, fromMatchPerformances performances: [TeamMatchPerformance]? = nil) -> [TimeMarker] {
        let matchPerformances: [TeamMatchPerformance]
        if performances == nil {
            matchPerformances = Array(self.matchPerformances)
        } else {
            matchPerformances = performances!
        }
        
        var timeMarkers = [TimeMarker]()
        
        for performance in matchPerformances {
            timeMarkers += performance.getTimeMarkers(withAssociatedLocation: assocLocation)
        }
        
        return timeMarkers
    }
    
    func maxCubes(for location: String) -> Int {
        var greatestCount = 0
        for matchPerformance in self.matchPerformances {
            let tmsCount = matchPerformance.getTimeMarkers(withAssociatedLocation: location).count
            if tmsCount > greatestCount {
                greatestCount = tmsCount
            }
        }
        
        return greatestCount
    }
    
    func averageTimeMarkers(withLocation location: String) -> Double? {
        var totalCount = 0.0
        var numOfMatches = 0.0
        for matchPerformance in self.matchPerformances {
            if matchPerformance.scouted?.hasBeenScouted ?? false {
                numOfMatches += 1
                totalCount += Double(matchPerformance.getTimeMarkers(withAssociatedLocation: location).count)
            }
        }
        
        if numOfMatches == 0 {
            return nil
        } else {
            return totalCount / numOfMatches
        }
    }
    
    func findPercentOfGrabbedCubes(withLocation location: String) -> StatValue {
        return StatValue.Integer(self.timeMarkers(withAssociatedLocations: location).count) / self.sum(ofStat: .TotalGrabbedCubes)
    }
    
    func findPercentOfPlacedCubes(withLocation location: String) -> StatValue {
        let timeMarkers = self.timeMarkers(withAssociatedLocations: location)
        let total = self.sum(ofStat: .AllPlacedCubes)
        
        return StatValue.Integer(timeMarkers.count) / total
    }
    
    //Stat Name Definition
    enum StatName: String, CustomStringConvertible, StatNameable {
        case ScoutedMatches = "Scouted Matches"
        case TotalMatchPoints = "Total Match Points"
        case TotalRankingPoints = "Total Ranking Points"
        case OPR = "OPR"
        case DPR = "DPR"
        case CCWM = "CCWM"
        
        case Rank = "Event Rank"
        
        case MajorityClimbStatus = "Climb Status (Majority)"
        case SuccessfulClimbCount = "Successful Climb Count"
        case ClimbSuccessRate = "Climb Success Rate"
        case TotalWins = "Total Wins"
        case TotalLosses = "Total Losses"
        case TotalTies = "Total Ties"
        case NumberOfMatches = "Number Of Matches"
        case RankingScore = "Ranking Score"
        
        case MajorityClimbAssistStatus = "Climb Assisting Status (Majority)"
        case ClimbAssistAttempts = "Cimb Assist Attempts"
        
        
        //2018
        case AutoLineCrossCount = "Auto Line Cross Count"
        case TotalGrabbedCubes = "Total Grabbed Cubes"
        case AverageGrabbedCubes = "Average Grabbed Cubes"
        case PercentCubesFromPile = "Percent Cubes From Pile"
        case PercentCubesFromLine = "Percent Cubes From Line"
        case PercentCubesFromPortal = "Percent Cubes From Portal"
        
        case TotalPlacedCubes = "Total Placed Cubes"
        case AveragePlacedCubes = "Average Placed Cubes"
        case PercentCubesInScale = "Percent Cubes in Scale"
        case PercentCubesInSwitch = "Percent Cubes in Switch"
        case PercentCubesInOpponentSwitch = "Cubes in Opp. Switch"
        case PercentCubesInVault = "Percent Cubes in Vault"
        case PercentCubesDropped = "Percent Cubes Dropped"
        case StandardDeviationPlacedCubes = "Std. Dev. Placed Cubes"
        
        case MaxCubesInScale = "Max Cubes in Scale"
        case MaxCubesInSwitch = "Max Cubes in Switch"
        case MaxCubesInOpponentSwitch = "Max Cubes in Opp. Switch"
        case MaxCubesInVault = "Max Cubes in Vault"
        case AverageCubesInScale = "Average Cubes in Scale"
        case AverageCubesInSwitch = "Average Cubes in Switch"
        case AverageCubesInOpponentSwitch = "Average Cubes in Opp. Switch"
        case AverageCubesInVault = "Average Cubes in Vault"
        case AverageCubesDropped = "Average Cubes Dropped"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.OPR, .DPR, .CCWM, .Rank, .ScoutedMatches, .NumberOfMatches, .TotalMatchPoints, .TotalRankingPoints, .RankingScore, .TotalWins, .TotalLosses, .TotalTies, .MajorityClimbStatus, .SuccessfulClimbCount, .ClimbSuccessRate, .MajorityClimbAssistStatus, .ClimbAssistAttempts,
            
            .AutoLineCrossCount, .TotalGrabbedCubes, .AverageGrabbedCubes, .PercentCubesFromPile, .PercentCubesFromLine, .PercentCubesFromPortal,
            .TotalPlacedCubes, .AveragePlacedCubes, .StandardDeviationPlacedCubes, .PercentCubesInScale, .MaxCubesInScale, .AverageCubesInScale, .PercentCubesInSwitch, .MaxCubesInSwitch, .AverageCubesInSwitch, .PercentCubesInOpponentSwitch, .MaxCubesInOpponentSwitch, .AverageCubesInOpponentSwitch, .PercentCubesInVault, .MaxCubesInVault, .AverageCubesInVault, .PercentCubesDropped, .AverageCubesDropped
        ]
        
        var visualizableAssociatedStats: [TeamMatchPerformance.StatName] {
            get {
                switch self {
                case .TotalGrabbedCubes:
                    return [.TotalGrabbedCubes]
                case .PercentCubesFromPile:
                    return [TeamMatchPerformance.StatName.PercentCubesFromPile]
                case .PercentCubesFromLine:
                    return [.PercentCubesFromLine]
                case .PercentCubesFromPortal:
                    return [.PercentCubesFromPortal]
                case .TotalPlacedCubes:
                    return [.TotalPlacedCubes]
                case .PercentCubesInScale:
                    return [TeamMatchPerformance.StatName.PercentCubesPlacedInScale]
                case .PercentCubesInSwitch:
                    return [.PercentCubesPlacedInSwitch]
                case .PercentCubesInOpponentSwitch:
                    return [.PercentCubesPlacedInOpponentSwitch]
                case .PercentCubesInVault:
                    return [TeamMatchPerformance.StatName.PercentCubesPlacedInVault]
                case .PercentCubesDropped:
                    return [.PercentCubesDropped]
                default:
                    return []
                }
            }
        }
    }
}

// MARK: Generated accessors for matchPerformances
extension TeamEventPerformance {

    @objc(addMatchPerformancesObject:)
    @NSManaged public func addToMatchPerformances(_ value: TeamMatchPerformance)

    @objc(removeMatchPerformancesObject:)
    @NSManaged public func removeFromMatchPerformances(_ value: TeamMatchPerformance)

    @objc(addMatchPerformances:)
    @NSManaged public func addToMatchPerformances(_ values: NSSet)

    @objc(removeMatchPerformances:)
    @NSManaged public func removeFromMatchPerformances(_ values: NSSet)

}

///Retrieves OPR as stored in the Computed Stats object (from TBA as of now)
private func evaluateOPR(forTeamPerformance teamPerformance: TeamEventPerformance) -> Double? {
    //Check if it has been computed before
    if let computedStatValue = teamPerformance.team?.scouted?.computedStats(forEvent: teamPerformance.event!)?.opr.value {
        return computedStatValue
    } else {
        return nil
    }
}

private func evaluateCCWM(forTeamPerformance teamPerformance: TeamEventPerformance) -> Double? {
    if let computedStatValue = teamPerformance.team?.scouted?.computedStats(forEvent: teamPerformance.event!)?.ccwm.value {
        return computedStatValue
    } else {
        return nil
    }
}
