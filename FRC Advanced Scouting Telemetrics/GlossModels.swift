//
//  GlossModels.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/19/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import Gloss

//These models are simply modeled after the ones described on The Blue Alliance's API Docs
//To distinguish these JSON models from the core data subclass objects, all of these models begin with "FRC" deliniating officially FIRST FRC data

struct FRCEvent: Decodable {
	
	let key: String
	let name: String
	let shortName: String?
	let eventCode: String
	let eventTypeString: String
	let eventType: Int
	let eventDistrictString: String?
	let eventDistrict: Int
	let year: Int
	let week: Int?
	let location: String
	let venueAddress: String?
	let timezone: String
	let website: String?
	let official: Bool
	
//	let teams: [FRCTeam]?
//	let matches: [FRCMatch]?
//	let awards: String?
	
//	let webcast: String? //Not implemented correctly, yet
//	let alliances: String? //""
//	let districtPoints: String? //""
	
	init?(json: JSON) {
		self.shortName = "short_name" <~~ json
		self.eventDistrictString = "event_district_string" <~~ json
		self.week = "week" <~~ json
		self.venueAddress = "venue_address" <~~ json
		self.website = "website" <~~ json
        if let official: Bool = "official" <~~ json {
            self.official = official
        } else {
            self.official = false
        }
//		self.webcast = "webcast" <~~ json
//		self.alliances = "alliances" <~~ json
//		self.districtPoints = "district_points" <~~ json
		
		guard let key: String = "key" <~~ json else {
			return nil
		}
		self.key = key
		
		guard let name: String = "name" <~~ json else {
			return nil
		}
		self.name = name
		
		guard let eventCode: String = "event_code" <~~ json else {
			return nil
		}
		self.eventCode = eventCode
		
		guard let eventTypeString: String = "event_type_string" <~~ json else {
			return nil
		}
		self.eventTypeString = eventTypeString
		
		guard let eventType: Int = "event_type" <~~ json else {
			return nil
		}
		self.eventType = eventType
		
		guard let eventDistrict: Int = "event_district" <~~ json else {
			return nil
		}
		self.eventDistrict = eventDistrict
		
		guard let year: Int = "year" <~~ json else {
			return nil
		}
		self.year = year
		
		guard let location: String = "location" <~~ json else {
			return nil
		}
		self.location = location
		
		guard let timezone: String = "timezone" <~~ json else {
			return nil
		}
		self.timezone = timezone
	}
}

struct FRCTeam: Decodable {
	
	let website: String?
	let name: String
	let locality: String?
	let region: String?
	let countryName: String?
	let location: String
	let teamNumber: Int
	let key: String
	let nickname: String
	let rookieYear: Int
	let motto: String?
	
	init?(json: JSON) {
		//All the optional values
		self.website = "website" <~~ json
		self.locality = "locality" <~~ json
		self.region = "region" <~~ json
		self.countryName = "country_name" <~~ json
		self.motto = "motto" <~~ json
		
		//Now use guard statements to retrieve the non-optional values
		guard let name: String = "name" <~~ json else {
			return nil
		}
		self.name = name
		
		guard let location: String = "location" <~~ json else {
			return nil
		}
		self.location = location
		
		guard let teamNumber: Int = "team_number" <~~ json else {
			return nil
		}
		self.teamNumber = teamNumber
		
		guard let key: String = "key" <~~ json else {
			return nil
		}
		self.key = key
		
		guard let nickname: String = "nickname" <~~ json else {
			return nil
		}
		self.nickname = nickname
		
		guard let rookieYear: Int = "rookie_year" <~~ json else {
			return nil
		}
		self.rookieYear = rookieYear
	}
}

struct FRCMatch: Decodable {
	
	let key: String
	let competitionLevel: String?
	let setNumber: Int?
	let matchNumber: Int
	let alliances: [String:FRCAlliance]?
	let scoreBreakdown: String?
	let eventKey: String
	let videos: String? //Not implemented
	let timeString: String?
	let time: NSDate?
	
	init?(json: JSON) {
		self.competitionLevel = "competitionLevel" <~~ json
		self.setNumber = "set_number" <~~ json
		self.alliances = "alliances" <~~ json
		self.scoreBreakdown = "score_breakdown" <~~ json
		self.videos = "videos" <~~ json
		self.timeString = "time_string" <~~ json
		
		if let time: TimeInterval = "time" <~~ json {
			self.time = NSDate(timeIntervalSince1970: time)
		} else {
			self.time = nil
		}
		
		guard let key: String = "key" <~~ json else {
			return nil
		}
		self.key = key
		
		guard let matchNumber: Int = "match_number" <~~ json else {
			return nil
		}
		self.matchNumber = matchNumber
		
		guard let eventKey: String = "event_key" <~~ json else {
			return nil
		}
		self.eventKey = eventKey
	}
}

struct FRCAlliance: Decodable {
	
	let score: Int?
	let teams: [String]? //Array of team keys
	
	init?(json: JSON) {
		self.score = "score" <~~ json
		self.teams = "teams" <~~ json
	}
}


