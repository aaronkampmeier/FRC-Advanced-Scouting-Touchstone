//
//  ScoutSession.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/20/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics

typealias ScoutSessionStat = Statistic<ScoutSession>
extension ScoutSession {
    
    var startStateDict: [String:Any]? {
        get {
            do {
                if let data = self.startState?.data(using: .utf8) {
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
    var endStateDict: [String:Any]? {
        get {
            do {
                if let data = self.endState?.data(using: .utf8) {
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
    
    
    
    static var stats: [Statistic<ScoutSession>] {
        get {
            var statistics = [ScoutSessionStat]()
            
            let group = DispatchGroup()
            group.enter()
            var model: StandsScoutingModel?
            StandsScoutingModelLoader().getModel { (m) in
                model = m
                group.leave()
            }
            group.wait()
            
            if let model = model {
                //Add all the statistics for start state and end state
                for startState in model.startState {
                    statistics.append(ScoutSessionStat(name: startState.name, id: startState.key, function: { (scoutSession, callback) in
                        let val = scoutSession.startStateDict?[startState.key] as? String
                        //Find that option and get its name
                        let option = startState.options.first(where: {$0.key == val})
                        callback(StatValue.initAny(value: option?.name ?? val))
                    }))
                }
                for endState in model.endState {
                    statistics.append(ScoutSessionStat(name: endState.name, id: endState.key, function: { (scoutSession, callback) in
                        let val = scoutSession.endStateDict?[endState.key] as? String
                        //Find that option and get its name
                        let option = endState.options.first(where: {$0.key == val})
                        callback(StatValue.initAny(value: option?.name ?? val))
                    }))
                }
                
                //For the game actions, add percentages for each one with sub options
                for gameAction in model.gameActions {
                    //Show total number of times action has happened
                    statistics.append(ScoutSessionStat(name: "\(gameAction.name) Occurences", id: gameAction.key, function: { (scoutSession, callback) in
                        let actions = scoutSession.timeMarkers?.filter({$0?.event == gameAction.key})
                        callback(StatValue.initWithOptional(value: actions?.count ?? 0))
                    }))
                    
                    if let subOptions = gameAction.subOptions {
                        for option in subOptions {
                            statistics.append(ScoutSessionStat(name: "\(gameAction.name)-\(option.name)", id: "\(gameAction.name)-\(option.name)-percentage", function: { (scoutSession, callback) in
                                //Find the percentage of game action with suboption
                                let totalActionOccurences = scoutSession.timeMarkers?.filter({$0?.event == gameAction.key})
                                let optionOccurences = totalActionOccurences?.filter({$0?.subOption == option.key})
                                
                                callback(StatValue.initWithOptionalPercent(value: Double(optionOccurences?.count ?? 0) / Double(totalActionOccurences?.count ?? 0)))
                            }))
                        }
                    }
                }
                
            }
            
            return statistics
        }
    }
}
