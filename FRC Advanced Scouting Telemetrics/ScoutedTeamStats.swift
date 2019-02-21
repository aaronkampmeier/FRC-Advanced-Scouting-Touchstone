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
            //Auto generate all of the pit socuting stats
            let pitScoutingInputs = PitScoutingData().requestedDataInputs(forScoutedTeam: ScoutedTeam(teamKey: "", userId: "", eventKey: ""))
            for input in pitScoutingInputs {
                statistics.append(Statistic<ScoutedTeam>(name: input.label, id: input.key, function: { (scoutedTeam, callback) in
                    callback(StatValue.initAny(value: scoutedTeam.attributeDictionary?[input.key]))
                }))
            }
            
            //OPRs
            statistics.append(ScoutedTeamStat(name: "OPR", id: "opr", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
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
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
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
                Globals.appDelegate.appSyncClient?.fetch(query: ListEventOprsQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
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
                Globals.appDelegate.appSyncClient?.fetch(query: ListTeamEventStatusesQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "EventRankQuery", result: result, error: error) {
                        let status = result?.data?.listTeamEventStatuses?.first(where: {$0?.teamKey == scoutedTeam.teamKey})??.fragments.teamEventStatus
                        callback(StatValue.initWithOptional(value: status?.qual?.ranking?.rank))
                    } else {
                        callback(StatValue.Error)
                    }
                })
            }))
            statistics.append(ScoutedTeamStat(name: "Scouted Matches", id: "scoutedMatches", function: { (scoutedTeam, callback) in
                //Fetch the opr
                Globals.appDelegate.appSyncClient?.fetch(query: ListSimpleScoutSessionsQuery(eventKey: scoutedTeam.eventKey, teamKey: scoutedTeam.teamKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, error) in
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
                Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: scoutedTeam.eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
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
            
            
            return statistics
        }
    }
    
    var frontImage: UIImage? {
        get {
            return nil
        }
    }
}

public func ==(lhs: ScoutedTeam, rhs: ScoutedTeam) -> Bool {
    return lhs.eventKey == rhs.eventKey && lhs.teamKey == rhs.teamKey
}
