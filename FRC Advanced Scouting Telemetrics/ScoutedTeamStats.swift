//
//  ScoutedTeamStats.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/11/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

struct ScoutedTeamAttributes: Codable {
    let robotWeight: Double?
    let robotLength: Double?
    let canBanana: Bool?
}

typealias ScoutedTeamStat = Statistic<ScoutedTeam>
extension ScoutedTeam: Equatable {
    
    
    //TODO: - Cache this object
    var decodedAttributes: ScoutedTeamAttributes? {
        get {
            do {
                if let data = self.attributes?.data(using: .utf8) {
                    return try JSONDecoder().decode(ScoutedTeamAttributes.self, from: data)
                } else {
                    return nil
                }
            } catch {
                //Record error
                CLSNSLogv("Error decoding scouted team attribute json data: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                return nil
            }
        }
    }
    
    var attributeDictionary: [String: Any]? {
        get {
            do {
                if let data = self.attributes?.data(using: .utf8) {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                } else {
                    return nil
                }
            } catch {
                //Record error
                CLSNSLogv("Error decoding scouted team attribute json data into dictionary: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                return nil
            }
        }
    }
    
    ///Called in Statistics.swift when getting all of the stats for SocutedTeams
    static var stats: [Statistic<ScoutedTeam>] {
        get {
            var statistics = [Statistic<ScoutedTeam>]()
            
            
            let statCalculationQueue = DispatchQueue(label: "ScoutedTeamStatCalculation", qos: .userInitiated, target: nil)
            
            //OPRs
            statistics.append(ScoutedTeamStat(name: "OPR", id: "opr", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "OPR-Query", result: result, error: error) {
                        let opr = result?.data?.listEventOprs?.first(where: {$0?.teamKey == scoutedTeam.teamKey})??.fragments.teamEventOpr
                        callback(StatValue.initWithOptional(value: opr?.opr))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            statistics.append(ScoutedTeamStat(name: "DPR", id: "dpr", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "DPR-Query", result: result, error: error) {
                        let opr = result?.data?.listEventOprs?.first(where: {$0?.teamKey == scoutedTeam.teamKey})??.fragments.teamEventOpr
                        callback(StatValue.initWithOptional(value: opr?.dpr))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            statistics.append(ScoutedTeamStat(name: "CCWM", id: "ccwm", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "CCWM-Query", result: result, error: error) {
                        let opr = result?.data?.listEventOprs?.first(where: {$0?.teamKey == scoutedTeam.teamKey})??.fragments.teamEventOpr
                        callback(StatValue.initWithOptional(value: opr?.ccwm))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            
            statistics.append(ScoutedTeamStat(name: "Event Rank", id: "eventRank", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListTeamEventStatusesQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "EventRankQuery", result: result, error: error) {
                        let status = result?.data?.listTeamEventStatuses?.first(where: {$0?.teamKey == scoutedTeam.teamKey})??.fragments.teamEventStatus
                        callback(StatValue.initWithOptional(value: status?.qual?.ranking?.rank))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            
            //Auto generate all of the pit socuting stats
            let pitScoutingInputs = PitScoutingData().requestedDataInputs(forScoutedTeam: ScoutedTeam(teamKey: "", userId: "", eventKey: ""))
            for input in pitScoutingInputs {
                if input.key != "canBanana" {
                    statistics.append(Statistic<ScoutedTeam>(name: input.label, id: input.key, function: { (scoutedTeam, callback) in
                        callback(StatValue.initAny(value: scoutedTeam.attributeDictionary?[input.key]))
                    }))
                }
            }
            
            statistics.append(ScoutedTeamStat(name: "Scouted Matches", id: "scoutedMatches", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListSimpleScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataAndFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "SimpleScoutSessions", result: result, error: error) {
                        if let scoutSessions = result?.data?.listScoutSessions {
                            
                            //Find the number of scout sessions with unique match keys
                            var matchScoutSessions = [String:ListSimpleScoutSessionsQuery.Data.ListScoutSession]()
                            for session in scoutSessions {
                                matchScoutSessions[session!.matchKey] = session
                            }
                            
                            callback(StatValue.initWithOptional(value: matchScoutSessions.count))
                        } else {
                            callback(.NoValue)
                        }
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            statistics.append(ScoutedTeamStat(name: "Number of Matches", id: "numOfMatches", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "ListMatches-NumOfMatchesStat", result: result, error: error) {
                        let matches = result?.data?.listMatches?.map({$0!.fragments.match}) ?? []
                        let count = matches.reduce(0, { (result, match) -> Int in
                            if match.alliances?.blue?.teamKeys?.contains(scoutedTeam.teamKey) ?? false || match.alliances?.red?.teamKeys?.contains(scoutedTeam.teamKey) ?? false {
                                return result + 1
                            } else {
                                return result
                            }
                        })
                        
                        callback(StatValue.initWithOptional(value: count))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            
            //Do averages of all of the scout session stats
            //Get the model
            var model: StandsScoutingModel?
            let group = DispatchGroup()
            group.enter()
            StandsScoutingModelLoader().getModel { (m) in
                model = m
                group.leave()
            }
            group.wait()
            
            //Show majority start states
            for startState in model?.startState ?? [] {
                //Show the breakdown of the options
                for option in startState.options {
                    statistics.append(ScoutedTeamStat(name: "\(startState.shortName ?? startState.name)-\(option.name)", id: "\(startState.shortName ?? startState.name)-\(option.name)", function: { (scoutedTeam, callback) in
                        //Get the scout sessions
                        Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataAndFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                            if Globals.handleAppSyncErrors(forQuery: "ScoutSessions-StartStateStat", result: result, error: error) {
                                let startStates = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession.startStateDict}) ?? []
                                
                                //Get the ones with this option
                                let cleanedStarts = startStates.filter({$0?[startState.key] != nil})
                                let optionChoices = cleanedStarts.filter({($0?[startState.key] as? String) ?? "" == option.key})
                                
                                callback(StatValue.initWithOptionalPercent(value: Double(optionChoices.count) / Double(cleanedStarts.count)))
                            } else {
                                callback(StatValue.Error)
                            }
                        })
                    }))
                }
            }
            for endState in model?.endState ?? [] {
                //Show the breakdown of the options
                for option in endState.options {
                    statistics.append(ScoutedTeamStat(name: "\(endState.shortName ?? endState.name)-\(option.name)", id: "\(endState.shortName ?? endState.name)-\(option.name)", function: { (scoutedTeam, callback) in
                        //Get the scout sessions
                        Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                            if Globals.handleAppSyncErrors(forQuery: "ScoutSessions-EndStateStat", result: result, error: error) {
                                let endStates = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession.endStateDict}) ?? []
                                
                                //Get the ones with this option
                                let cleanedStates = endStates.filter({$0?[endState.key] != nil})
                                let optionChoices = cleanedStates.filter({($0?[endState.key] as? String) ?? "" == option.key})
                                
                                callback(StatValue.initWithOptionalPercent(value: Double(optionChoices.count) / Double(cleanedStates.count)))
                            } else {
                                callback(StatValue.Error)
                            }
                        })
                    }))
                }
            }
            
            for gameAction in model?.gameActions ?? [] {
                //First show number of times action happened
                let totalOccurenceStat = ScoutedTeamStat(name: "\(gameAction.name) Occurrences", id: gameAction.name + " occurrences", compositeTrendFunction: { (scoutedTeam, callback) in
                    Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                        var compositePoints = [(matchNumber: Int, value: StatValue)]()
                        for session in result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession}) ?? [] {
                            let timeMarkers = session.timeMarkers?.map({$0!.fragments.timeMarkerFragment})
                            let filtered = timeMarkers?.filter({$0.event == gameAction.key})
                            let matchNumber = Int(session.matchKey.components(separatedBy: "_").last?.trimmingCharacters(in: CharacterSet.letters) ?? "0") ?? 0
                            compositePoints.append((matchNumber, StatValue.initWithOptional(value: filtered?.count)))
                        }
                        
                        callback(compositePoints)
                    })
                }, function: { (scoutedTeam, callback) in
                    Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "ScoutSessions-GameActionStat", result: result, error: error) {
                            let timeMarkers = result?.data?.listScoutSessions?.reduce([TimeMarkerFragment](), { (currentTMs, scoutSession) -> [TimeMarkerFragment] in
                                return currentTMs + (scoutSession?.timeMarkers?.map({$0!.fragments.timeMarkerFragment}) ?? [])
                            })
                            
                            let filtered = timeMarkers?.filter({$0.event == gameAction.key})
                            
                            callback(StatValue.initWithOptional(value: filtered?.count))
                        } else {
                            callback(StatValue.Error)
                        }
                    })
                })
                statistics.append(totalOccurenceStat)
                
                //Show average of number of times this option is selected
                statistics.append(ScoutedTeamStat(name: "\(gameAction.name) Avg.", id: gameAction.name + " avg", function: { (scoutedTeam, callback) in
                    totalOccurenceStat.compositePoints(forObject: scoutedTeam, callback: { (compositePoints) in
                        var total = 0
                        var count = 0
                        for point in compositePoints {
                            switch point.value {
                            case .Integer(let val):
                                count += 1
                                total += val
                            case .NoValue:
                                break
                            default:
                                break
                            }
                        }
                        
                        callback(StatValue.initWithOptional(value: Double(total) / Double(count)))
                    })
                }))
                
                if let subOptions = gameAction.subOptions {
                    for subOption in subOptions {
                        //Show the average of each option
//                        statistics.append(ScoutedTeamStat(name: "\(gameAction.name)-\(subOption.name) Avg.", id: UUID().uuidString, function: { (scoutedTeam, callback) in
//                            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
//                                if Globals.handleAppSyncErrors(forQuery: "ScoutSessions-GameActionSubOptionAverageStat", result: result, error: error) {
//                                    let sessionsTMs = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession.timeMarkers?.map({$0!.fragments.timeMarkerFragment})})
//
//                                    var totalSessions = 0
//                                    var totalValue = 0
//
//                                    for sessionTMs in (sessionsTMs ?? []) {
//                                        let optionTMs = sessionTMs?.filter({$0.subOption == subOption.key})
//
//                                        if let count = optionTMs?.count {
//                                            totalSessions += 1
//                                            totalValue += count
//                                        }
//                                    }
//
//                                    callback(StatValue.initWithOptional(value: Double(totalValue) / Double(totalSessions)))
//                                } else {
//                                    callback(StatValue.Error)
//                                }
//                            })
//                        }))
                        
                        //For each sub option, show the percentage that it is selected within the action as a whole
                        let id = "\(gameAction.name)-\(subOption.name)-percentage"
                        statistics.append(ScoutedTeamStat(name: "\(gameAction.name)-\(subOption.name)", id: id, compositeTrendFunction: { (scoutedTeam, callback) in
                            var compositeDataPoints = [(Int,StatValue)]()
                            let ssStats = StatisticsDataSource().getStats(forType: ScoutSession.self)
                            let subOptionPercentageStat = ssStats.first(where: {$0.id == id})
                            
                            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                                let scoutSessions = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession}) ?? []
                                
                                for session in scoutSessions {
                                    let group = DispatchGroup()
                                    group.enter()
                                    subOptionPercentageStat?.calculate(forObject: session, callback: { (value) in
                                        let matchNumber = Int(session.matchKey.components(separatedBy: "_").last?.trimmingCharacters(in: CharacterSet.letters) ?? "0") ?? 0
                                        
                                        compositeDataPoints.append((matchNumber, value))
                                        group.leave()
                                    })
                                    group.wait()
                                }
                                
                                DispatchQueue.main.async {
                                    callback(compositeDataPoints)
                                }
                            })
                            
                        }, function: { (scoutedTeam, callback) in
                            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataElseFetch, queue: statCalculationQueue, resultHandler: { (result, error) in
                                if Globals.handleAppSyncErrors(forQuery: "ScoutSessions-GameActionSubOptionPercentageStat", result: result, error: error) {
                                    let totalTMs = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession.timeMarkers?.map({$0!.fragments.timeMarkerFragment})}).reduce([TimeMarkerFragment](), { (tms, newTMs) -> [TimeMarkerFragment] in
                                        return tms + (newTMs ?? [])
                                    })
                                    let totalActionTMs = totalTMs?.filter({$0.event == gameAction.key})
                                    let totalOptionTMs = totalActionTMs?.filter({$0.subOption == subOption.key})
                                    
                                    callback(StatValue.initWithOptionalPercent(value: Double(totalOptionTMs?.count ?? 0) / Double(totalActionTMs?.count ?? 0)))
                                } else {
                                    callback(.Error)
                                }
                            })
                        }))
                    }
                }
            }
            
            
            return statistics
        }
    }
}

public func ==(lhs: ScoutedTeam, rhs: ScoutedTeam) -> Bool {
    return lhs.eventKey == rhs.eventKey && lhs.teamKey == rhs.teamKey
}
