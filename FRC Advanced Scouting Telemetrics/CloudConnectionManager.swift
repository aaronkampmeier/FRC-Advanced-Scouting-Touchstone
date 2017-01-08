//
//  CloudConnectionManager.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/19/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import Alamofire
import Gloss

private let baseApi = "https://fast.kampmeier.com/api/v2/"
private let baseApiUrl = try! baseApi.asURL()
private let apiKey = "c67378f6984026e97ca5abdc343f7f7ff77b5135576aed64c3fcce034d3e55e8"
private let yearToDrawDataFrom = "2015"

private class TBAResponseCache<T> {
    let json: T
    let lastModified: String
    
    init(json: T, lastModified: String) {
        self.json = json
        self.lastModified = lastModified
    }
}

class CloudData {
    private let headers = [
        "X-Dreamfactory-API-Key":apiKey,
        "Accept": "application/json"
    ]
    
    func header(withLastModified lastModified: String?) -> [String:String] {
        if let lastModified = lastModified {
            var newHeaders = headers
            newHeaders["If-Modified-Since"] = lastModified
            return newHeaders
        } else {
            return headers
        }
    }
    
    private let dataCache = NSCache<NSString, TBAResponseCache<Any>>()
    
	
    func events(withCompletionHandler completionHandler: @escaping ([FRCEvent]?) -> Void) {
        Alamofire.request(baseApi + "tbadb/events/\(yearToDrawDataFrom)", method: .get, headers: headers)
            .validate(statusCode: 200...200)
            .responseJSON() {response in
                switch response.result {
                case .success(let responseJSON):
                    //Take response data and convert it into FRCEvent Gloss models
                    if let json = responseJSON as? [[String:Any]] {
                        //Convert serialized JSON data into the models
                        let events = [FRCEvent].from(jsonArray: json)
                        completionHandler(events)
                    }
                    NSLog("Successfully retrieved events from cloud")
                case .failure(let error):
                    NSLog("Failed to retrieve events from cloud with error: \(error)")
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func matches(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping ([FRCMatch]?) -> Void) {
        //Check if there is something in the cache
        let cachedData = dataCache.object(forKey: "MatchesInEvent\(eventKey)" as NSString)
        
        Alamofire.request(baseApi + "tbadb/event/\(eventKey)/matches", method: .get, headers: header(withLastModified: cachedData?.lastModified))
        .validate(statusCode: [200,304])
            .responseJSON() {response in
                switch response.result{
                case .success(let responseData):
                    if response.response?.statusCode == 304 {
                        //Not modified, use cache
                        completionHandler(self.handleMatchesResponse(withData: cachedData!.json))
                    } else {
                        //Cache the data
//                        let cache = TBAResponseCache(json: responseData, lastModified: response.response?.allHeaderFields["Last-Modified"] as! String)
//                        self.dataCache.setObject(cache, forKey: "MatchesInEvent\(eventKey)" as NSString)
                        completionHandler(self.handleMatchesResponse(withData: responseData))
                    }
                case .failure(let error):
                    NSLog("Failed to retrieve matches from cloud with error: \(error)")
                    completionHandler(nil)
                }
        }
    }
    
    private func handleMatchesResponse(withData responseData: Any) -> [FRCMatch]? {
        if let json = responseData as? [[String:Any]] {
            let matches = [FRCMatch].from(jsonArray: json)!
            return matches
        } else {
            return nil
        }
    }
    
    func teams(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping ([FRCTeam]?) -> Void) {
        Alamofire.request(baseApi + "tbadb/event/\(eventKey)/teams", method: .get, headers: headers)
        .validate(statusCode: 200...200)
            .responseJSON {response in
                switch response.result {
                case .success(let responseData):
                    if let json = responseData as? [[String:Any]] {
                        let teams = [FRCTeam].from(jsonArray: json)
                        completionHandler(teams)
                    }
                case .failure(let error):
                    NSLog("Failed to get teams for event with error: \(error)")
                    completionHandler(nil)
                }
        }
    }
    
    func team(withTeamKey teamKey: String, withCompletionHandler completionHandler: @escaping (FRCTeam?) -> Void) {
        Alamofire.request(baseApi + "tbadb/team/\(teamKey)", method: .get, headers: headers)
        .validate(statusCode: 200...200)
            .responseJSON{response in
                switch response.result {
                case .success(let responseData):
                    if let json = responseData as? [String:Any] {
                        let team = FRCTeam(json: json)
                        completionHandler(team)
                    }
                case .failure(let error):
                    NSLog("Failed to grab team \(teamKey) with error: \(error)")
                    completionHandler(nil)
                }
        }
    }
	
    func preloadEventMatches() {
        
    }
}
