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
                        if matchPerformance.scouted.hasBeenScouted {
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
                StatName.TotalWins: {
                    var winCount = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.winningMargin > 0 {
                            winCount += 1
                        }
                    }
                    
                    return StatValue.Integer(winCount)
                },
                StatName.TotalLosses: {
                    var lossCount = 0
                    
                    let matchPerformances = self.matchPerformances
                    for matchPerformance in matchPerformances {
                        if matchPerformance.winningMargin < 0 {
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
                        if matchPerformance.scouted.hasBeenScouted {
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
                        if (matchPerformance.scouted.hasBeenScouted) && matchPerformance.scouted.climbStatus == ClimbStatus.Successful.rawValue {
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
                        if matchPerformance.scouted.hasBeenScouted {
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
                        if (matchPerformance.scouted.hasBeenScouted) && matchPerformance.scouted.climbAssistStatus == ClimbAssistStatus.AttemptedAssist.rawValue || matchPerformance.scouted.climbAssistStatus == ClimbAssistStatus.SuccessfullyAssisted.rawValue {
                            return partialResult + 1
                        } else {
                            return partialResult
                        }
                    }
                    
                    return StatValue.Integer(climbAttemptCount)
                },
                
                
                StatName.AutoLineCrossCount: {
                    let crossCount = self.matchPerformances.reduce(0) {partialResult, matchPerformance in
                        if matchPerformance.scouted.didCrossAutoLine {
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
                    self.findPercentOfCubes(withLocation: CubeSource.Pile.rawValue)
                },
                StatName.PercentCubesFromLine: {
                    self.findPercentOfCubes(withLocation: CubeSource.Line.rawValue)
                },
                StatName.PercentCubesFromPortal: {
                    self.findPercentOfCubes(withLocation: CubeSource.Portal.rawValue)
                },
                StatName.AveragePlacedCubes: {
                    self.average(ofStat: .TotalPlacedCubes)
                },
                StatName.PercentCubesInScale:{
                    self.findPercentOfCubes(withLocation: CubeDestination.Scale.rawValue)
                },
                StatName.PercentCubesInSwitch: {
                    self.findPercentOfCubes(withLocation: CubeDestination.Switch.rawValue)
                },
                StatName.PercentCubesInOpponentSwitch: {
                    self.findPercentOfCubes(withLocation: CubeDestination.OpponentSwitch.rawValue)
                },
                StatName.PercentCubesInVault: {
                    self.findPercentOfCubes(withLocation: CubeDestination.Vault.rawValue)
                },
                StatName.PercentCubesDropped: {
                    self.findPercentOfCubes(withLocation: CubeDestination.Dropped.rawValue)
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
    
    func findPercentOfCubes(withLocation location: String) -> StatValue {
        return StatValue.Integer(self.timeMarkers(withAssociatedLocations: location).count) / self.sum(ofStat: .TotalGrabbedCubes)
    }
    
    //Stat Name Definition
    enum StatName: String, CustomStringConvertible, StatNameable {
        case ScoutedMatches = "Scouted Matches"
        case TotalMatchPoints = "Total Match Points"
        case TotalRankingPoints = "Total Ranking Points"
        case OPR = "OPR"
        case DPR = "DPR"
        case CCWM = "CCWM"
        
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
        
        case AveragePlacedCubes = "Average Placed Cubes"
        case PercentCubesInScale = "Percent Cubes in Scale"
        case PercentCubesInSwitch = "Percent Cubes in Switch"
        case PercentCubesInOpponentSwitch = "Cubes in Opp. Switch"
        case PercentCubesInVault = "Percent Cubes in Vault"
        case PercentCubesDropped = "Percent Cubes Dropped"
        
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.OPR, .DPR, .CCWM, .ScoutedMatches, .NumberOfMatches, .TotalMatchPoints, .TotalRankingPoints, .RankingScore, .TotalWins, .TotalLosses, .TotalTies, .MajorityClimbStatus, .SuccessfulClimbCount, .ClimbSuccessRate, .MajorityClimbAssistStatus, .ClimbAssistAttempts,
            
            .AutoLineCrossCount, .TotalGrabbedCubes, .AverageGrabbedCubes, .PercentCubesFromPile, .PercentCubesFromLine, .PercentCubesFromPortal,
            .AveragePlacedCubes, .PercentCubesInScale, .PercentCubesInSwitch, .PercentCubesInOpponentSwitch, .PercentCubesInVault, .PercentCubesDropped
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

///Evaluates OPR using YCMatrix and the algorithm published by Ether located here: https://www.chiefdelphi.com/forums/showpost.php?p=1119150&postcount=36
private let matrixAReuseKey = NSString(string: "CCWMAndOPRMatrixA")
private let oprCache = NSCache<Event, Matrix>()
private func evaluateOPR(forTeamPerformance teamPerformance: TeamEventPerformance) -> Double? {
    let eventPerformances = suitableEventPerformances(forEvent: teamPerformance.event!)
    let numOfTeams = eventPerformances.count
    
    if numOfTeams < 3 {
        return nil
    }
    
    //Now also check that all the matches have scores
    for match in teamPerformance.event!.matches {
        if match.scouted.redScore.value == nil || match.scouted.redScore.value == nil {
            return nil
        }
    }
    
    if let cachedOPR = oprCache.object(forKey: teamPerformance.event!) {
        if let index = eventPerformances.index(of: teamPerformance) {
            return (cachedOPR.i(Int32(index), j: 0))
        } else {
            return nil
        }
    } else {
        
        let matrixA = createMatrixA(forEventPerformances: eventPerformances, withReuseKey: matrixAReuseKey)
        
        var rowsB = [Int]() //Should only be one element per row
        for eventPerformance in eventPerformances {
            let _matchPerformances = matchPerformances(fromEventPerformance: eventPerformance)
            let sumOfAllScores = _matchPerformances.reduce(0) {scoreSum, matchPerformance in
                return scoreSum + (matchPerformance.finalScore ?? 0)
            }
            rowsB.append(sumOfAllScores)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        //TODO: Decide best way to solve opr
        let oprMatrix = matrixA.solve(matrixB!)
        
        //Cache it because these calculations are expensive
        oprCache.setObject(oprMatrix!, forKey: teamPerformance.event!)
        
        if let index = eventPerformances.index(of: teamPerformance) {
            return (oprMatrix?.i(Int32(index), j: 0))!
        } else {
            return nil
        }
    }
}

private let ccwmCache = NSCache<Event, Matrix>()
private func evaluateCCWM(forTeamPerformance teamPerformance: TeamEventPerformance) -> Double? {
    let eventPerformances = suitableEventPerformances(forEvent: teamPerformance.event!)
    let numOfTeams = eventPerformances.count
    
    if numOfTeams < 3 {
        return nil
    }
    
    //Now also check that all the matches have scores
    for match in teamPerformance.event!.matches {
        if match.scouted.redScore.value == nil || match.scouted.blueScore.value == nil {
            return nil
        }
    }
    
    if let cachedCCWM = ccwmCache.object(forKey: teamPerformance.event!) {
        if let index = eventPerformances.index(of: teamPerformance) {
            return (cachedCCWM.i(Int32(index), j: 0))
        } else {
            return nil
        }
    } else {
        let matrixA = createMatrixA(forEventPerformances: eventPerformances, withReuseKey: matrixAReuseKey)
        
        //Matrix B for CCWM is the same as DPR's Matrix B except for the values are your alliance's scores minus the opposing alliance's scores (the winning margin)
        var rowsB = [Int]() //Should only be one element for year
        for eventPerformance in eventPerformances {
            let _matchPerformances = matchPerformances(fromEventPerformance: eventPerformance)
            let sumOfWinningMargins = _matchPerformances.reduce(0) {(partialResult, matchPerformance) in
                return partialResult + matchPerformance.winningMargin
            }
            rowsB.append(sumOfWinningMargins)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        let ccwmMatrix = matrixA.solve(matrixB)
        
        ccwmCache.setObject(ccwmMatrix!, forKey: teamPerformance.event!)
        
        if let index = eventPerformances.index(of: teamPerformance) {
            return (ccwmMatrix?.i(Int32(index), j: 0))!
        } else {
            return nil
        }
    }
}

///Returns all the team event performances in an event that actually participate in an event.
private func suitableEventPerformances(forEvent event: Event) -> [TeamEventPerformance] {
    let allEventPerformances = event.teamEventPerformances
    
    let eventPerformances = allEventPerformances.filter() {teamEventPerformance in
        //Check to see the number of match performances that have been scouted
        
        if (teamEventPerformance.matchPerformances.count) == 0 {
            return false
        } else {
            return true
        }
    }
    
    return Array(eventPerformances)
}

//Solves Ax=B
private func solveForX(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixP = matrixA?.transposingAndMultiplying(withRight: matrixA)
    let matrixS = matrixA?.transposingAndMultiplying(withRight: matrixB)
    
    let matrixL = matrixP?.byCholesky()
    
    assert((matrixL?.transposingAndMultiplying(withLeft: matrixL).isEqual(to: matrixP, tolerance: 1))!)
    
    let matrixY = forwardSubstitute(matrixL, matrixB: matrixS)
    
    let matrixX = backwardSubstitute(matrixL?.transposing(), matrixB: matrixY)
    
    return matrixX
}

///Creates the first matrix A for an OPR calculation. Where n is the number of teams, it is an n*n matrix where each value is the number of matches that the two teams which make up the matrix have played together.
private let matrixACache = NSCache<NSString, Matrix>()
private func createMatrixA(forEventPerformances eventPerformances: [TeamEventPerformance], withReuseKey reuseKey: NSString? = nil) -> Matrix {
    if let cachedMatrix = matrixACache.object(forKey: reuseKey ?? NSString()) {
        return cachedMatrix
    } else {
        
        let numOfTeams = eventPerformances.count
        
        var rowsA = [Double]()
        for (firstIndex, firstEventPerformance) in eventPerformances.enumerated() {
            var row = [Double]()
            let firstTeamMatchPerformances = matchPerformances(fromEventPerformance: firstEventPerformance)
            
            for (secondIndex, secondEventPerformance) in eventPerformances.enumerated() {
                if firstIndex == secondIndex {
                    assert(firstEventPerformance == secondEventPerformance)
                }
                let secondTeamMatchPerformances = matchPerformances(fromEventPerformance: secondEventPerformance)
                
                var numOfCommonMatches = 0.0
                for firstTeamMatchPerformance in firstTeamMatchPerformances {
                    for secondTeamMatchPerformance in secondTeamMatchPerformances {
                        
                        if firstTeamMatchPerformance.match == secondTeamMatchPerformance.match && firstTeamMatchPerformance.allianceColor == secondTeamMatchPerformance.allianceColor {
                            
                            //Now also check that this match has been scouted
                            if firstTeamMatchPerformance.finalScore != nil || secondTeamMatchPerformance.finalScore != nil {
                                numOfCommonMatches += 1
                            }
                        }
                    }
                }
                
                row.append(numOfCommonMatches)
            }
            rowsA += row
        }
        
        let matrixA = Matrix(from: rowsA, rows: Int32(numOfTeams), columns: Int32(numOfTeams))!
        
        if let reuseKey = reuseKey {
            matrixACache.setObject(matrixA, forKey: reuseKey)
        }
        
        return matrixA
    }
}

private let matchPerformancesCache = NSCache<TeamEventPerformance, NSArray>()
private func matchPerformances(fromEventPerformance eventPerformance: TeamEventPerformance) -> [TeamMatchPerformance] {
    if let cachedMatchPerformances = matchPerformancesCache.object(forKey: eventPerformance) {
        return cachedMatchPerformances as! [TeamMatchPerformance]
    } else {
        let matchPerformances = eventPerformance.matchPerformances
        
        //Store it in the cache
        let array = Array(matchPerformances)
        matchPerformancesCache.setObject(NSArray(array: array), forKey: eventPerformance)
        return array
    }
}

///Forward and Backwards matrix substitution formulas drawn from http://mathfaculty.fullerton.edu/mathews/n2003/BackSubstitutionMod.html
private func forwardSubstitute(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    for i in 0..<matrixA.rows {
        let sigmaValue = sigma(0, topIncrementValue: Int(i)-1, function: {matrixA.i(i, j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let bValue = matrixB.i(i, j: 0)
        let xValueAtI = (bValue - sigmaValue) / matrixA.i(i, j: i)
        
        matrixX?.setValue(xValueAtI, row: i, column: 0)
    }
    
    return matrixX
}

private func backwardSubstitute(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    let backwardsArray = (Int(matrixA.rows)-1) ..= 0
    
    for i in backwardsArray {
        let sigmaValue = sigma(Int(i) + 1, topIncrementValue: Int(matrixA.rows) - 1, function: {matrixA.i(Int32(i), j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let xValueAtI = (matrixB.i(Int32(i), j: 0) - sigmaValue) / matrixA.i(Int32(i), j: Int32(i))
        matrixX?.setValue(xValueAtI, row: Int32(i), column: 0)
    }
    
    return matrixX
}

//An operator that takes an upper bound and a lower bound and returns an array with all the values from the upper bound to the lower bound. It's the inverse of the ... operator
infix operator ..=
private func ..=(lhs: Int, rhs: Int) -> [Int] {
    if lhs == rhs {
        return [rhs]
    } else {
        return [lhs] + ((lhs-1)..=rhs)
    }
}

private func sigma(_ initialIncrementerValue: Int, topIncrementValue: Int, function: (Int) -> Double) -> Double {
    if initialIncrementerValue == topIncrementValue {
        return function(initialIncrementerValue)
    } else if initialIncrementerValue > topIncrementValue {
        return 0
    } else {
        return function(initialIncrementerValue) + sigma(initialIncrementerValue + 1, topIncrementValue: topIncrementValue, function: function)
    }
}
