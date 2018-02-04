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
                        if (matchPerformance.scouted.hasBeenScouted) && matchPerformance.scouted.climbStatus == ClimbStatus.Attempted.rawValue {
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
                        return StatValue.Double(Double(numOfSuccesses)/Double(numOfScoutedMatches))
                    }
                }
            ]
        }
    }
    
    func average(ofStat stat: TeamMatchPerformance.StatName, forMatchPerformances matchPerformances: [TeamMatchPerformance]) -> StatValue {
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
            return StatValue.Double(sum/Double(numOfAverages))
        }
    }
    
    //Stat Name Definition
    enum StatName: String, CustomStringConvertible, StatNameable {
        case TotalMatchPoints = "Total Match Points"
        case TotalRankingPoints = "Total Ranking Points"
        case OPR = "OPR"
        case DPR = "DPR"
        case CCWM = "CCWM"
        case AverageTotalPointsFromFuel = "Average Total Fuel Points"
        case AverageGearsScored = "Average Gears Scored"
        case AverageFuelCycleTime = "Average Fuel Cycle Time"
        case AverageGearCycleTime = "Average Gear Cycle Time"
        case AverageHighGoalAccuracy = "Average High Goal Accuracy"
        case MostRopeClimb = "Climb Status (Majority)"
        case Peg1Percentage = "Peg 1 Percentage"
        case Peg2Percentage = "Peg 2 Percentage"
        case Peg3Percentage = "Peg 3 Percentage"
        case TotalWins = "Total Wins"
        case TotalLosses = "Total Losses"
        case TotalTies = "Total Ties"
        case NumberOfMatches = "Number Of Matches"
        case RankingScore = "Ranking Score"
        case AverageFloorGearCount = "Average Floor Gear Count"
        case SuccessfulClimbCount = "Successful Climb Count"
        case ClimbSuccessRate = "Climb Success Rate"
        case AverageAutoFuelScored = "Average Auto Fuel Scored"
        case AverageAutoGearsScored = "Average Auto Gears Scored"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.OPR, .DPR, .CCWM, .NumberOfMatches, .TotalMatchPoints, .TotalRankingPoints, .RankingScore, .TotalWins, .TotalLosses, .TotalTies, .AverageTotalPointsFromFuel, .AverageAutoFuelScored, .AverageFuelCycleTime, .AverageHighGoalAccuracy, .AverageGearsScored, .AverageAutoGearsScored, .AverageFloorGearCount, .AverageGearCycleTime, .Peg1Percentage, .Peg2Percentage, .Peg3Percentage, .MostRopeClimb, .SuccessfulClimbCount, .ClimbSuccessRate]
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
        
        let matrixA = createMatrixA(forEventPerformances: eventPerformances)
        
        
        var rowsB = [Int]() //Should only be one element per row
        for eventPerformance in eventPerformances {
            let matchPerformances = eventPerformance.matchPerformances
            let sumOfAllScores = matchPerformances.reduce(0) {scoreSum, matchPerformance in
                return scoreSum + (matchPerformance.finalScore ?? 0)
            }
            rowsB.append(sumOfAllScores)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        //TODO: Decide best way to solve opr
        let oprMatrix = matrixA.solve(matrixB!)
//        let oprMatrix = solveForX(matrixA, matrixB: matrixB)
        
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
        let matrixA = createMatrixA(forEventPerformances: eventPerformances)
        
        //Matrix B for CCWM is the same as DPR's Matrix B except for the values are your alliance's scores minus the opposing alliance's scores (the winning margin)
        var rowsB = [Int]() //Should only be one element for year
        for eventPerformance in eventPerformances {
            let matchPerformances = eventPerformance.matchPerformances
            let sumOfWinningMargins = matchPerformances.reduce(0) {(partialResult, matchPerformance) in
                return partialResult + matchPerformance.winningMargin
            }
            rowsB.append(sumOfWinningMargins)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        let ccwmMatrix = matrixA.solve(matrixB)
//        let ccwmMatrix = solveForX(matrixA, matrixB: matrixB)
        
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
func solveForX(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixP = matrixA?.transposingAndMultiplying(withRight: matrixA)
    let matrixS = matrixA?.transposingAndMultiplying(withRight: matrixB)
    
    let matrixL = matrixP?.byCholesky()
    
    assert((matrixL?.transposingAndMultiplying(withLeft: matrixL).isEqual(to: matrixP, tolerance: 1))!)
    
    let matrixY = forwardSubstitute(matrixL, matrixB: matrixS)
    
    let matrixX = backwardSubstitute(matrixL?.transposing(), matrixB: matrixY)
    
    return matrixX
}

///Creates the first matrix A for an OPR calculation. Where n is the number of teams, it is an n*n matrix where each value is the number of matches that the two teams which make up the matrix have played together.
func createMatrixA(forEventPerformances eventPerformances: [TeamEventPerformance]) -> Matrix {
    let numOfTeams = eventPerformances.count
    
    var rowsA = [Double]()
    for (firstIndex, firstEventPerformance) in eventPerformances.enumerated() {
        var row = [Double]()
        let firstTeamMatchPerformances = firstEventPerformance.matchPerformances
        
        for (secondIndex, secondEventPerformance) in eventPerformances.enumerated() {
            if firstIndex == secondIndex {
                assert(firstEventPerformance == secondEventPerformance)
            }
            let secondTeamMatchPerformances = secondEventPerformance.matchPerformances
            
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
    
    return Matrix(from: rowsA, rows: Int32(numOfTeams), columns: Int32(numOfTeams))
}

///Forward and Backwards matrix substitution formulas drawn from http://mathfaculty.fullerton.edu/mathews/n2003/BackSubstitutionMod.html
func forwardSubstitute(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    for i in 0..<matrixA.rows {
        let sigmaValue = sigma(0, topIncrementValue: Int(i)-1, function: {matrixA.i(i, j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let bValue = matrixB.i(i, j: 0)
        let xValueAtI = (bValue - sigmaValue) / matrixA.i(i, j: i)
        
        matrixX?.setValue(xValueAtI, row: i, column: 0)
    }
    
    return matrixX
}

func backwardSubstitute(_ matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
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
func ..=(lhs: Int, rhs: Int) -> [Int] {
    if lhs == rhs {
        return [rhs]
    } else {
        return [lhs] + ((lhs-1)..=rhs)
    }
}

func sigma(_ initialIncrementerValue: Int, topIncrementValue: Int, function: (Int) -> Double) -> Double {
    if initialIncrementerValue == topIncrementValue {
        return function(initialIncrementerValue)
    } else if initialIncrementerValue > topIncrementValue {
        return 0
    } else {
        return function(initialIncrementerValue) + sigma(initialIncrementerValue + 1, topIncrementValue: topIncrementValue, function: function)
    }
}
