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
}

typealias ScoutedTeamStat = Statistic<ScoutedTeam>
extension ScoutedTeam {
    
    //TODO: - Cache this object
    var decodedAttributes: ScoutedTeamAttributes? {
        get {
            do {
                if let data = self.attributes.data(using: .utf8) {
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
    
    ///Called in Statistics.swift when getting all of the stats for SocutedTeams
    static var stats: [Statistic<ScoutedTeam>] {
        get {
            return [
                Statistic<ScoutedTeam>(name: "Robot Length", id: "length", function: { (scoutedTeam, callback) in
                    callback(StatValue.initWithOptional(value: scoutedTeam.decodedAttributes?.robotLength))
                })
            ]
        }
    }
    
    var frontImage: UIImage? {
        get {
            return nil
        }
    }
}
