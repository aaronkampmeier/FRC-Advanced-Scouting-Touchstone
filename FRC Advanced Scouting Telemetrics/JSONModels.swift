//
//  JSONModels.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 6/29/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import Foundation

//These models are simply modeled after the ones described on The Blue Alliance's API Docs
//To distinguish these JSON models from the core data subclass objects, all of these models begin with "FRC" deliniating officially FIRST FRC data

struct FRCEvent: Codable {
    
    let key: String
    let name: String
    let shortName: String?
    let eventCode: String
    let eventTypeString: String
    let eventType: Int
    let year: Int
    let week: Int?
    let address: String?
    let locationName: String?
    let timezone: String?
    let firstEventID: String?
    let website: String?
    let district: FRCDistrict?
    
    struct FRCDistrict: Codable {
        let abbreviation: String
        let displayName: String
        let key: String
        let year: Int
        
        private enum CodingKeys: String, CodingKey {
            case abbreviation
            case displayName = "display_name"
            case key
            case year
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case key
        case name
        case shortName = "short_name"
        case eventCode = "event_code"
        case eventTypeString = "event_type_string"
        case eventType = "event_type"
        case year
        case week
        case address
        case locationName = "location_name"
        case timezone
        case firstEventID = "first_event_id"
        case website
        case district
    }
    
}

struct FRCTeam: Codable {
    
    let website: String?
    let name: String
    let stateProv: String?
    let teamNumber: Int
    let key: String
    let nickname: String?
    let rookieYear: Int
    let motto: String?
    
    private enum CodingKeys: String, CodingKey {
        case website
        case name
        case stateProv = "state_prov"
        case teamNumber = "team_number"
        case key
        case nickname
        case rookieYear = "rookie_year"
        case motto
    }
}

struct FRCMatch: Codable {
    
    let key: String
    let compLevel: String
    let setNumber: Int
    let matchNumber: Int
    let alliances: [String:FRCAlliance]?
    let eventKey: String
    let scheduledTime: Date?
    let actualTime: Date?
    let predictedTime: Date?
    let winningAlliance: String?
    
    struct FRCAlliance: Codable {
        let score: Int
        let teams: [String]
        
        private enum CodingKeys: String, CodingKey {
            case score
            case teams = "team_keys"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case key
        case compLevel = "comp_level"
        case setNumber = "set_number"
        case matchNumber = "match_number"
        case alliances
        case eventKey = "event_key"
        case scheduledTime = "time"
        case actualTime = "actual_time"
        case predictedTime = "predicted_time"
        case winningAlliance = "winning_alliance"
    }
}