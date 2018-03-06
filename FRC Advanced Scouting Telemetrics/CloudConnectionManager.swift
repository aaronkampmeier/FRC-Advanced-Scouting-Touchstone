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

private let baseApi = "https://www.thebluealliance.com/api/v3/"
private let baseApiUrl = try! baseApi.asURL()
private let yearToDrawDataFrom = "2018"

private class TBAResponseCache<T> {
    let json: T
    let lastModified: String
    
    init(json: T, lastModified: String) {
        self.json = json
        self.lastModified = lastModified
    }
}

class CloudData {
    fileprivate let headers = [
        "X-TBA-Auth-Key":"ZeCp1BpPQgxdhBrC1F3A8wue9mexDAnGw9akcjZiP95u4YMY6WrBjKxg7VLXWIww",
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
    
    fileprivate let dataCache = NSCache<NSString, TBAResponseCache<Any>>()
    
    let jsonDecoder = JSONDecoder()
    
    init() {
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
    }
	
    func events(fromYear year: String? = nil, withCompletionHandler completionHandler: @escaping ([FRCEvent]?) -> Void) {
        Alamofire.request(baseApi + "events/\(year ?? yearToDrawDataFrom)", method: .get, headers: headers)
            .validate(statusCode: [200])
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    //Take data and decode it using JSON decoder
                    do {
                        let events = try self.jsonDecoder.decode([FRCEvent].self, from: responseData)
                        completionHandler(events)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve events from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func event(forKey key: String, withCompletionHandler completionHandler: @escaping (FRCEvent?) -> Void) {
        Alamofire.request(baseApi + "event/\(key)", method: .get, headers: headers)
            .validate(statusCode: [200])
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    //Take data and decode it using JSON decoder
                    do {
                        let event = try self.jsonDecoder.decode(FRCEvent.self, from: responseData)
                        completionHandler(event)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve event from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func matches(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping ([FRCMatch]?) -> Void) {
        //Check if there is something in the cache
        let cachedData = dataCache.object(forKey: "MatchesInEvent\(eventKey)" as NSString)
        
        Alamofire.request(baseApi + "event/\(eventKey)/matches", method: .get, headers: header(withLastModified: cachedData?.lastModified))
            .validate(statusCode: [200,304])
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    //Take data and decode it using JSON decoder
                    do {
                        let matches = try self.jsonDecoder.decode([FRCMatch].self, from: responseData)
                        completionHandler(matches)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve matches from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func teams(forEventKey eventKey: String, withCompletionHandler completionHandler: @escaping ([FRCTeam]?) -> Void) {
        Alamofire.request(baseApi + "event/\(eventKey)/teams", method: .get, headers: headers)
            .validate(statusCode: 200...200)
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    //Take data and decode it using JSON decoder
                    do {
                        let teams = try self.jsonDecoder.decode([FRCTeam].self, from: responseData)
                        completionHandler(teams)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve teams from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func team(withTeamKey teamKey: String, withCompletionHandler completionHandler: @escaping (FRCTeam?) -> Void) {
        Alamofire.request(baseApi + "team/\(teamKey)", method: .get, headers: headers)
            .validate(statusCode: 200...200)
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    //Take data and decode it using JSON decoder
                    do {
                        let team = try self.jsonDecoder.decode(FRCTeam.self, from: responseData)
                        completionHandler(team)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve team from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func oprs(withEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (FRCOPRs?) -> Void) {
        Alamofire.request(baseApi + "event/\(eventKey)/oprs", method: .get, headers: headers)
            .validate(statusCode: 200...200)
            .responseData {response in
                switch response.result {
                case .success(let responseData):
                    do {
                        let oprs = try self.jsonDecoder.decode(FRCOPRs.self, from: responseData)
                        completionHandler(oprs)
                    } catch {
                        CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                        completionHandler(nil)
                        Crashlytics.sharedInstance().recordError(error)
                    }
                case .failure(let error):
                    CLSNSLogv("Failed to retrieve oprs from cloud with error: \(error)", getVaList([]))
                    completionHandler(nil)
                    Crashlytics.sharedInstance().recordError(error)
                }
        }
    }
    
    func preloadEventMatches() {
        
    }
}
