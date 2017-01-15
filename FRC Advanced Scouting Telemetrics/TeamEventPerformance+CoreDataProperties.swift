//
//  TeamEventPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
//import Surge
import YCMatrix

extension TeamEventPerformance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamEventPerformance> {
        return NSFetchRequest<TeamEventPerformance>(entityName: "TeamEventPerformance");
    }

    @NSManaged public var event: Event
    @NSManaged public var matchPerformances: NSSet?
    @NSManaged public var team: Team

}

extension TeamEventPerformance: HasStats {
    var stats: [StatName:()->StatValue?] {
        get {
            return [
                StatName.TotalMatchPoints:{return (self.matchPerformances?.allObjects as! [TeamMatchPerformance]).reduce(0) {(result, matchPerformance) in
                    return result + matchPerformance.finalScore
                    }
                },
                StatName.TotalRankingPoints:{return (self.matchPerformances?.allObjects as! [TeamMatchPerformance]).reduce(0) {(result, matchPerformance) in
                    return result + matchPerformance.rankingPoints
                    }
                },
                StatName.OPR: {
                    if false {
                        return evaluateOPRUsingMatrices(teamPerformance: self)
                    } else if false {
                        return evaluateOPRUsingRecursiveVector(teamPerformance: self)
                    } else {
                        return evaluateOPRUsingYCMatrix(teamPerformance: self)
                    }
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
let oprCache = NSCache<Event, Matrix>()
func evaluateOPRUsingYCMatrix(teamPerformance: TeamEventPerformance) -> Double {
    let eventPerformances = teamPerformance.event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
    let numOfTeams = eventPerformances.count
    
    if let cachedOPR = oprCache.object(forKey: teamPerformance.event) {
        return cachedOPR.i(Int32(eventPerformances.index(of: teamPerformance)!), j: 0)
    } else {
        
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
        
        let matrixA = Matrix(from: rowsA, rows: Int32(numOfTeams), columns: Int32(numOfTeams))
        
        
        var rowsB = [Double]() //Should only be one element per row
        for eventPerformance in eventPerformances {
            let matchPerformances = eventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
            let sumOfAllScores = matchPerformances.reduce(0) {scoreSum, matchPerformance in
                return scoreSum + matchPerformance.finalScore
            }
            rowsB.append(sumOfAllScores)
        }
        let matrixB = Matrix(from: rowsB, rows: Int32(numOfTeams), columns: 1)
        
        
        
        let matrixP = matrixA?.transposingAndMultiplying(withRight: matrixA)
        let matrixS = matrixA?.transposingAndMultiplying(withRight: matrixB)
        
        let matrixL = matrixP?.byCholesky()
        
        assert((matrixL?.transposingAndMultiplying(withLeft: matrixL).isEqual(to: matrixP, tolerance: 1))!)
        
        let matrixY = forwardSubstitue(matrixA: matrixL, matrixB: matrixS)
        
        let oprMatrix = backwardSubstitute(matrixA: matrixL?.transposing(), matrixB: matrixY)
        
        //Cache it because these calculations are expensive
        oprCache.setObject(oprMatrix!, forKey: teamPerformance.event)
        
        return (oprMatrix?.i(Int32(eventPerformances.index(of: teamPerformance)!), j: 0))!
    }
}

///Forward and Backwards matrix substitution formulas drawn from http://mathfaculty.fullerton.edu/mathews/n2003/BackSubstitutionMod.html
func forwardSubstitue(matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    //For initial x value at (0,0)
    matrixX?.setValue(matrixB.i(0, j: 0) / matrixA.i(0, j: 0), row: 0, column: 0)
    
    for i in 1..<matrixA.rows {
        let sigmaValue = sigma(initialIncrementerValue: 0, topIncrementValue: Int(i)-1, function: {matrixA.i(i, j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let bValue = matrixB.i(i, j: 0)
        let xValueAtI = (bValue - sigmaValue) / matrixA.i(i, j: i)
        
        matrixX?.setValue(xValueAtI, row: i, column: 0)
    }
    
    return matrixX
}

func backwardSubstitute(matrixA: Matrix!, matrixB: Matrix!) -> Matrix? {
    let matrixX = Matrix(ofRows: matrixA.rows, columns: 1, value: 0)
    
    //For initial x value at (0,0)
    matrixX?.setValue(matrixB.i(0, j: 0) / matrixA.i(0, j: 0), row: 0, column: 0)
    
    let backwardsArray = (Int(matrixA.rows)-1) ..= 0
    
    for i in backwardsArray {
        let sigmaValue = sigma(initialIncrementerValue: Int(i), topIncrementValue: Int(matrixA.rows) - 1, function: {matrixA.i(Int32(i), j: Int32($0)) * (matrixX?.i(Int32($0), j: 0))!})
        let xValueAtI = (matrixB.i(Int32(i), j: 0) - sigmaValue) / matrixA.i(Int32(i), j: Int32(i))
        matrixX?.setValue(xValueAtI, row: Int32(i), column: 0)
    }
    
    return matrixX
}

//An operator that takes an upper bound and a lower bound and returns an array with all the values from the upper bound to the lower bound. It's the inverse of ... operator
infix operator ..=
func ..=(lhs: Int, rhs: Int) -> [Int] {
    if lhs == rhs {
        return [rhs]
    } else {
        return [lhs] + ((lhs-1)..=rhs)
    }
}

func sigma(initialIncrementerValue: Int, topIncrementValue: Int, function: (Int) -> Double) -> Double {
    if initialIncrementerValue == topIncrementValue {
        return function(initialIncrementerValue)
    } else if initialIncrementerValue > topIncrementValue {
        return 0
    } else {
        return function(initialIncrementerValue) + sigma(initialIncrementerValue: initialIncrementerValue + 1, topIncrementValue: topIncrementValue, function: function)
    }
}



func evaluateOPRUsingRecursiveVector(teamPerformance: TeamEventPerformance) -> Double {
    let matchPerformances = teamPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
    let averageMatchScore = matchPerformances.map {$0.finalScore}.reduce(0.0) {(partialResult, nextElement) in
        return partialResult + nextElement
    } / Double(matchPerformances.count)
    
    
    
    return estimatedTeamContribution(averageMatchScore: averageMatchScore, timesToRecurse: 0)
}

func estimatedTeamContribution(averageMatchScore: Double, timesToRecurse: Int) -> Double {
    if timesToRecurse == 0 {
        return averageMatchScore / 3
    } else {
        return averageMatchScore - 2*estimatedTeamContribution(averageMatchScore: averageMatchScore, timesToRecurse: timesToRecurse - 1)
    }
}

func evaluateOPRUsingMatrices(teamPerformance: TeamEventPerformance) -> Double {
    //OPR stands for offensive power rating. The main idea: robot1+robot2+robot3 = redScore & robot4+robot5+robot6 = blueScore. It is calculated as follows. First, a N*N matrix (A), where N is the number of teams, is created. Each value in A is the number of matches that the two teams comprising the index play together. Then an array (B) is created where the number of elements is equal to the number of teams, N, and in the same order as A. Each element in B is the sum of all match scores for the team at that index. A third array (x) is also size N and each value in it represents the OPR for the team at that index. A * x = B. Given A and B, one can solve for x. (Alliance color doesn't really matter for this calculation)
//    let eventPerformances = teamPerformance.event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
//    let numOfTeams = eventPerformances.count
//    
//    if numOfTeams <= 1 {
//        //Has to be multiple teams to perform calculation
//        return 0
//    }
//    
//    //First create matrix A
//    var rowsA = [[Double]]()
//    for (firstIndex, firstEventPerformance) in eventPerformances.enumerated() {
//        var row = [Double]()
//        let firstTeamMatchPerformances = firstEventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
//        
//        for (secondIndex, secondEventPerformance) in eventPerformances.enumerated() {
//            if firstIndex == secondIndex {
//                assert(firstEventPerformance == secondEventPerformance)
//            }
//            let secondTeamMatchPerformances = secondEventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
//            
//            var numOfCommonMatches = 0.0
//            for firstTeamMatchPerformance in firstTeamMatchPerformances {
//                for secondTeamMatchPerformance in secondTeamMatchPerformances {
//                    if firstTeamMatchPerformance.match == secondTeamMatchPerformance.match && firstTeamMatchPerformance.allianceColor == secondTeamMatchPerformance.allianceColor {
//                        numOfCommonMatches += 1
//                    }
//                }
//            }
//            
//            row.append(numOfCommonMatches)
//        }
//        rowsA.append(row)
//    }
//    
//    let matrixA = Matrix(rowsA)
//    print("Event: \(DataManager().events().first?.name) Year: \(DataManager().events().first?.year?.intValue)")
//    print("Matrix A: \n" + matrixA.description)
//    
//    //Now create Array B
//    var rowsB = [[Double]]() //Should only be one element per row
//    for eventPerformance in eventPerformances {
//        let matchPerformances = eventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
//        let sumOfAllScores = matchPerformances.reduce(0) {scoreSum, matchPerformance in
//            return scoreSum + matchPerformance.finalScore
//        }
//        rowsB.append([sumOfAllScores])
//    }
//    let matrixB = Matrix(rowsB)
//    print("Matrix B: \n" + matrixB.description)
//    
//    let matrixX = Matrix([[0]]) //inv(matrixA) * matrixB
//    return matrixX[0,0] //matrixX[eventPerformances.index(of: self)!,0]
    return 0
}
