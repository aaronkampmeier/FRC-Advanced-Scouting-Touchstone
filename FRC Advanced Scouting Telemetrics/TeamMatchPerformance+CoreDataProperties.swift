//
//  TeamMatchPerformance+CoreDataProperties.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/18/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import CoreData


extension TeamMatchPerformance: HasLocalEquivalent {
    var localEntityName: String {
        get {
            return "LocalMatchPerformance"
        }
    }
    typealias SelfObject = TeamMatchPerformance
    typealias LocalType = LocalMatchPerformance
    
    static func specificFR() -> NSFetchRequest<TeamMatchPerformance> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance")
    }

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<TeamMatchPerformance>(entityName: "TeamMatchPerformance") as! NSFetchRequest<NSFetchRequestResult>;
    }
    
    static func genericFetchRequest() -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: "TeamMatchPerformance")
    }

    @NSManaged public var allianceColor: String
    @NSManaged public var allianceTeam: NSNumber?
    @NSManaged public var key: String?
    @NSManaged public var match: Match?
    @NSManaged public var eventPerformance: TeamEventPerformance?
    @NSManaged public var transientLocal: LocalMatchPerformance?

}

extension TeamMatchPerformance: HasStats {
    var stats: [StatName:()->StatValue] {
        get {
            return [
                StatName.TotalPoints:{
                    if let val = self.finalScore {
                        return StatValue.Double(val)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TotalRankingPoints:{
                    if let val = self.rankingPoints {
                        return StatValue.Integer(val)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TotalPointsFromFuel: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        var matchPoints = 0.0
                        for fuelScoring in self.local.fuelScorings?.allObjects as! [FuelScoring] {
                            let amountOfFuelScored = (self.eventPerformance!.team.local.tankSize?.doubleValue ?? 0) * (fuelScoring.amountShot!.doubleValue * fuelScoring.accuracy!.doubleValue)
                            
                            switch fuelScoring.goalType() {
                            case .HighGoal:
                                if fuelScoring.isAutonomous!.boolValue {
                                    matchPoints += amountOfFuelScored
                                } else {
                                    matchPoints += amountOfFuelScored / 3
                                }
                            case .LowGoal:
                                if fuelScoring.isAutonomous!.boolValue {
                                    matchPoints += amountOfFuelScored / 3
                                } else {
                                    matchPoints += amountOfFuelScored / 9
                                }
                            }
                        }
                        return StatValue.Double(matchPoints)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TotalGearsScored: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearScorings = self.local.gearMountings
                        return StatValue.initWithOptional(value: gearScorings?.count)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.AverageFuelCycleTime: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let fuelLoadings = (self.local.fuelLoadings?.allObjects as! [FuelLoading]).sorted() {$0.0.time!.doubleValue < $0.1.time!.doubleValue}
                        let fuelScorings = (self.local.fuelScorings?.allObjects as! [FuelScoring]).sorted() {$0.0.time!.doubleValue < $0.1.time!.doubleValue}
                        
                        //Reamining fuel loadings is where all the fuel loadings will be stored initially and then each loading will be removed as it is used as part of a cycle
                        var remainingFuelLoadings = fuelLoadings
                        var cycleTimeSum = 0.0
                        var numOfCycles = 0
                        for scoring in fuelScorings {
                            //Retrieve only the loadings that happened before the scoring
                            var leadingLoadings = remainingFuelLoadings.filter() {loading in
                                return loading.time!.doubleValue < scoring.time!.doubleValue
                            }
                            leadingLoadings.sort() {(first, second) in
                                return first.time!.doubleValue < second.time!.doubleValue
                            }
                            
                            //If there are no loadings, then don't count this as a cycle
                            if leadingLoadings.first == nil {
                                continue
                            }
                            
                            //Remove the loadings that are being used in this cycle
                            for leadingLoading in leadingLoadings {
                                remainingFuelLoadings.remove(at: remainingFuelLoadings.index(of: leadingLoading)!)
                            }
                            
                            //The cycle time is just the time between a fuel scoring and the first fuel loading after the last scoring
                            let cycleTime = scoring.time!.doubleValue - leadingLoadings.first!.time!.doubleValue
                            cycleTimeSum += cycleTime
                            numOfCycles += 1
                        }
                        
                        if fuelScorings.count == 0 || fuelLoadings.count == 0 {
                            return StatValue.NoValue
                        } else {
                            return StatValue.Double(cycleTimeSum/Double(numOfCycles))
                        }
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.AverageGearCycleTime: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearLoadings = self.local.gearLoadings?.allObjects as! [GearLoading]
                        let gearMountings = self.local.gearMountings?.allObjects as! [GearMounting]
                        
                        var cycleTimeSum = 0.0
                        var numOfCycles = 0
                        for mounting in gearMountings {
                            //Find the last gear loading
                            var closestGearLoading: (GearLoading, TimeInterval)?
                            for loading in gearLoadings {
                                
                                let timeDifference = mounting.time!.doubleValue - loading.time!.doubleValue
                                //If the time between a loading and a mounting is less than another found time difference (and still comes before the mounting), set this loading as the closest
                                if timeDifference < (closestGearLoading?.1 ?? 0) && timeDifference > 0 {
                                    closestGearLoading = (loading, timeDifference)
                                } else if closestGearLoading == nil && timeDifference > 0 {
                                    //If this is the first loading just set it as the closest
                                    closestGearLoading = (loading, timeDifference)
                                }
                            }
                            
                            if closestGearLoading == nil {
                                continue
                            }
                            
                            cycleTimeSum += mounting.time!.doubleValue - closestGearLoading!.0.time!.doubleValue
                            numOfCycles += 1
                        }
                        
                        if gearMountings.count == 0 || gearLoadings.count == 0{
                            return StatValue.NoValue
                        } else {
                            return StatValue.Double(cycleTimeSum/Double(numOfCycles))
                        }
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.AverageAccuracy: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let allHighGoalScorings = (self.local.fuelScorings?.allObjects as! [FuelScoring]).filter({$0.goalType() == .HighGoal})
                        
                        var sum = 0.0
                        for scoring in allHighGoalScorings {
                            sum += scoring.accuracy!.doubleValue
                        }
                        
                        return StatValue.Double(sum/Double(allHighGoalScorings.count))
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.ClimbingStatus: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        return StatValue.initWithOptional(value: self.local.ropeClimbStatus)
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.Peg1Percentage: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearMountings = self.local.gearMountings?.allObjects as! [GearMounting]
                        
                        let peg1Mountings = gearMountings.filter() {$0.pegNumber?.intValue == 1}
                        
                        if gearMountings.count == 0 {
                            return StatValue.NoValue
                        } else {
                            return StatValue.Double(Double(peg1Mountings.count)/Double(gearMountings.count))
                        }
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.Peg2Percentage: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearMountings = self.local.gearMountings?.allObjects as! [GearMounting]
                        
                        let peg2Mountings = gearMountings.filter() {$0.pegNumber?.intValue == 2}
                        
                        if gearMountings.count == 0 {
                            return StatValue.NoValue
                        } else {
                            return StatValue.Double(Double(peg2Mountings.count)/Double(gearMountings.count))
                        }
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.Peg3Percentage: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearMountings = self.local.gearMountings?.allObjects as! [GearMounting]
                        
                        let peg3Mountings = gearMountings.filter() {$0.pegNumber?.intValue == 3}
                        
                        if gearMountings.count == 0 {
                            return StatValue.NoValue
                        } else {
                            return StatValue.Double(Double(peg3Mountings.count)/Double(gearMountings.count))
                        }
                    } else {
                        return StatValue.NoValue
                    }
                },
                StatName.TotalFloorGears: {
                    if self.local.hasBeenScouted?.boolValue ?? false {
                        let gearLoadings = self.local.gearLoadings?.allObjects as! [GearLoading]
                        
                        let totalFloorGears = gearLoadings.filter {$0.location == GearLoadingLocation.Floor.rawValue}
                        
                        return StatValue.Integer(totalFloorGears.count)
                    } else {
                        return StatValue.NoValue
                    }
                }
            ]
        }
    }
    
    enum StatName: String, CustomStringConvertible, StatNameable {
        case TotalPoints = "Total Points"
        case TotalRankingPoints = "Total Ranking Points"
        case TotalPointsFromFuel = "Total Fuel Points"
        case TotalGearsScored = "Total Gears Scored"
        case AverageFuelCycleTime = "Average Fuel Cycle Time"
        case AverageGearCycleTime = "Average Gear Cycle Time"
        case AverageAccuracy = "Average High Goal Accuracy"
        case ClimbingStatus = "Climbing Status"
        case Peg1Percentage = "Peg 1 Percentage"
        case Peg2Percentage = "Peg 2 Percentage"
        case Peg3Percentage = "Peg 3 Percentage"
        case TotalFloorGears = "Total Floor Gears"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
        
        static let allValues: [StatName] = [.TotalPoints, .TotalRankingPoints, .TotalPointsFromFuel, .TotalGearsScored, .TotalFloorGears, .AverageAccuracy, .AverageFuelCycleTime, .AverageGearCycleTime, .Peg1Percentage, .Peg2Percentage, .Peg3Percentage, .ClimbingStatus]
    }
}
