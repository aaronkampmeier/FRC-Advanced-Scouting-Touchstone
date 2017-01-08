//
//  TeamEventPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData
import Surge

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
                    //OPR stands for offensive power rating. The main idea: robot1+robot2+robot3 = redScore & robot4+robot5+robot6 = blueScore. It is calculated as follows. First, a N*N matrix (A), where N is the number of teams, is created. Each value in A is the number of matches that the two teams comprising the index play together. Then an array (B) is created where the number of elements is equal to the number of teams, N, and in the same order as A. Each element in B is the sum of all match scores for the team at that index. A third array (x) is also size N and each value in it represents the OPR for the team at that index. A * x = B. Given A and B, one can solve for x. (Alliance color doesn't really matter for this calculation)
                    let eventPerformances = self.event.teamEventPerformances?.allObjects as! [TeamEventPerformance]
                    let numOfTeams = eventPerformances.count
                    
                    if numOfTeams <= 1 {
                        //Has to be multiple teams to perform calculation
                        return 0
                    }
                    
                    //First create matrix A
                    var rowsA = [[Double]]()
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
                        rowsA.append(row)
                    }
                    
                    let matrixA = Matrix(rowsA)
                    print("Event: \(DataManager().events().first?.name) Year: \(DataManager().events().first?.year?.intValue)")
                    print("Matrix A: \n" + matrixA.description)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MatrixA"), object: self, userInfo: ["matrixA":matrixA])
                    
                    //Now create Array B
                    var rowsB = [[Double]]() //Should only be one element per row
                    for eventPerformance in eventPerformances {
                        let matchPerformances = eventPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance]
                        let sumOfAllScores = matchPerformances.reduce(0) {scoreSum, matchPerformance in
                            return scoreSum + matchPerformance.finalScore
                        }
                        rowsB.append([sumOfAllScores])
                    }
                    let matrixB = Matrix(rowsB)
                    print("Matrix B: \n" + matrixB.description)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MatrixB"), object: self, userInfo: ["matrixB":matrixB])
                    
                    let matrixX = Matrix([[0]]) //inv(matrixA) * matrixB
                    return matrixX[0,0] //matrixX[eventPerformances.index(of: self)!,0]
                }
            ]
        }
    }
    
    //Stat Name Defition
    enum StatName: String, CustomStringConvertible {
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
