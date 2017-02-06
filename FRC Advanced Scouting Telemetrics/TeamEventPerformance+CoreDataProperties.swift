//
//  TeamEventPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
import YCMatrix

extension TeamEventPerformance {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<TeamEventPerformance>(entityName: "TeamEventPerformance") as! NSFetchRequest<NSFetchRequestResult>;
    }

    @NSManaged public var event: Event
    @NSManaged public var matchPerformances: NSSet?
    @NSManaged public var team: Team

}

extension TeamEventPerformance: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.TotalMatchPoints:{return StatValue.initWithOptional(value: (self.matchPerformances?.allObjects as! [TeamMatchPerformance]).reduce(0.0) {(result, matchPerformance) in
                    return result + (matchPerformance.finalScore ?? 0)
                    })
                },
                StatName.TotalRankingPoints:{return StatValue.initWithOptional(value: (self.matchPerformances?.allObjects as! [TeamMatchPerformance]).reduce(0) {(result, matchPerformance) in
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
                }
            ]
        }
    }
    
    //Stat Name Defition
    enum StatName: String, CustomStringConvertible, StatNameable {
        case TotalMatchPoints = "Total Match Points"
        case TotalRankingPoints = "Total Ranking Points"
        case OPR = "OPR"
        case DPR = "DPR"
        case CCWM = "CCWM"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.TotalMatchPoints, .TotalRankingPoints, .OPR, .DPR, .CCWM]
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
    let eventPerformances = suitableEventPerformances(forEvent: teamPerformance.event)
    let numOfTeams = eventPerformances.count
    
    if let cachedOPR = oprCache.object(forKey: teamPerformance.event) {
        if let index = eventPerformances.index(of: teamPerformance) {
            return (cachedOPR.i(Int32(index), j: 0))
        } else {
            return nil
        }
    } else {
        
        let matrixA = createMatrixA(forEvent: teamPerformance.event)
        
        
        var rowsB = [Double]() //Should only be one element per row
        for eventPerformance in eventPerformances {
            let matchPerformances = eventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
            let sumOfAllScores = matchPerformances.reduce(0) {scoreSum, matchPerformance in
                return scoreSum + (matchPerformance.finalScore ?? 0)
            }
            rowsB.append(sumOfAllScores)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        
        let oprMatrix = solveForX(matrixA, matrixB: matrixB)
        
        //Cache it because these calculations are expensive
        oprCache.setObject(oprMatrix!, forKey: teamPerformance.event)
        
        if let index = eventPerformances.index(of: teamPerformance) {
            return (oprMatrix?.i(Int32(index), j: 0))!
        } else {
            return nil
        }
    }
}

private let ccwmCache = NSCache<Event, Matrix>()
private func evaluateCCWM(forTeamPerformance teamPerformance: TeamEventPerformance) -> Double? {
    let eventPerformances = suitableEventPerformances(forEvent: teamPerformance.event)
    let numOfTeams = eventPerformances.count
    
    if let cachedCCWM = ccwmCache.object(forKey: teamPerformance.event) {
        if let index = eventPerformances.index(of: teamPerformance) {
            return (cachedCCWM.i(Int32(index), j: 0))
        } else {
            return nil
        }
    } else {
        let matrixA = createMatrixA(forEvent: teamPerformance.event)
        
        //Matrix B for CCWM is the same as DPR's Matrix B except for the values are your alliances' scores the opposing alliances' scores (the winning margin)
        var rowsB = [Double]() //Should only be one element for year
        for eventPerformance in eventPerformances {
            let matchPerformances = eventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
            let sumOfWinningMargins = matchPerformances.reduce(0.0) {(partialResult, matchPerformance) in
                return partialResult + matchPerformance.winningMargin
            }
            rowsB.append(sumOfWinningMargins)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        let ccwmMatrix = solveForX(matrixA, matrixB: matrixB)
        
        ccwmCache.setObject(ccwmMatrix!, forKey: teamPerformance.event)
        
        if let index = eventPerformances.index(of: teamPerformance) {
            return (ccwmMatrix?.i(Int32(index), j: 0))!
        } else {
            return nil
        }
    }
}

///Returns all the team event performances in an event that actually participate in an event.
private func suitableEventPerformances(forEvent event: Event) -> [TeamEventPerformance] {
    let allEventPerformances = event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
    
    let eventPerformances = allEventPerformances.filter() {teamEventPerformance in
        if (teamEventPerformance.matchPerformances?.count ?? 0) == 0 {
            return false
        } else {
            return true
        }
    }
    
    return eventPerformances
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

func createMatrixA(forEvent event: Event) -> Matrix {
    let eventPerformances = suitableEventPerformances(forEvent: event)
    let numOfTeams = eventPerformances.count
    
    var rowsA = [Double]()
    for (firstIndex, firstEventPerformance) in eventPerformances.enumerated() {
        var row = [Double]()
        let firstTeamMatchPerformances = firstEventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
        
        for (secondIndex, secondEventPerformance) in eventPerformances.enumerated() {
            if firstIndex == secondIndex {
                assert(firstEventPerformance == secondEventPerformance)
            }
            let secondTeamMatchPerformances = secondEventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
            
            var numOfCommonMatches = 0.0
            for firstTeamMatchPerformance in firstTeamMatchPerformances {
                for secondTeamMatchPerformance in secondTeamMatchPerformances {
                    if firstTeamMatchPerformance.match == secondTeamMatchPerformance.match && firstTeamMatchPerformance.allianceColor == secondTeamMatchPerformance.allianceColor {
                        numOfCommonMatches += 1
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
