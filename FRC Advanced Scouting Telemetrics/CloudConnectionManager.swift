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
    
    func matches(forEventKey eventKey: String, shouldUseModificationValues: Bool, withCompletionHandler completionHandler: @escaping ([FRCMatch]?, Error?) -> Void) {
        
        DispatchQueue.main.async {
            var eventRanker: EventRanker?
            var lastModified: String? = nil
            if shouldUseModificationValues {
                if let event = RealmController.realmController.generalRealm.object(ofType: Event.self, forPrimaryKey: eventKey) {
                    if let ranker = RealmController.realmController.getTeamRanker(forEvent: event) {
                        eventRanker = ranker
                        if let lastModifiedString = ranker.matchesLastModified {
                            lastModified = lastModifiedString
                        }
                    }
                }
            }
            
            Alamofire.request(baseApi + "event/\(eventKey)/matches", method: .get, headers: self.header(withLastModified: lastModified))
                .validate(statusCode: 200...200)
                .responseData {response in
                    switch response.result {
                    case .success(let responseData):
                        //Take data and decode it using JSON decoder
                        do {
                            let matches = try self.jsonDecoder.decode([FRCMatch].self, from: responseData)
                            
                            var didStarWrite = false
                            if !RealmController.realmController.syncedRealm.isInWriteTransaction {
                                RealmController.realmController.syncedRealm.beginWrite()
                                didStarWrite = true
                            }
                            if let lastModifiedHeader = response.response?.allHeaderFields["Last-Modified"] as? String {
                                eventRanker?.matchesLastModified = lastModifiedHeader
                            }
                            if didStarWrite {
                                do {
                                    try RealmController.realmController.syncedRealm.commitWrite()
                                } catch {
                                    CLSNSLogv("Error saving match last modified header: \(error)", getVaList([]))
                                    Crashlytics.sharedInstance().recordError(error)
                                }
                            }
                            
                            completionHandler(matches, nil)
                        } catch {
                            CLSNSLogv("Failed to decode json data with error: \(error)", getVaList([]))
                            completionHandler(nil, error)
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    case .failure(let error):
                        if response.response?.statusCode == 304 {
                            completionHandler(nil,nil)
                        } else {
                            CLSNSLogv("Failed to retrieve matches from cloud with error: \(error)", getVaList([]))
                            completionHandler(nil, error)
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
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
    
    func oprs(withEventKey eventKey: String, withCompletionHandler completionHandler: @escaping (FRCOPRs?, _ withError: Error?) -> Void) {
        DispatchQueue.main.async {
            var lastModified: String? = nil
            //Add the last modified header
            var eventRanker: EventRanker?
            if let event = RealmController.realmController.generalRealm.object(ofType: Event.self, forPrimaryKey: eventKey) {
                if let ranker = RealmController.realmController.getTeamRanker(forEvent: event) {
                    eventRanker = ranker
                    
                    if let lastModifiedDate = ranker.oprLastModified {
                        lastModified = lastModifiedDate
                    }
                }
            }
            
            Alamofire.request(baseApi + "event/\(eventKey)/oprs", method: .get, headers: self.header(withLastModified: lastModified))
                .validate(statusCode: 200...200)
                .responseData {response in
                    switch response.result {
                    case .success(let responseData):
                        do {
                            let oprs = try self.jsonDecoder.decode(FRCOPRs?.self, from: responseData)
                            
                            //Store the last modified value for future calls
                            var didStartWrite = false
                            if !RealmController.realmController.syncedRealm.isInWriteTransaction {
                                RealmController.realmController.syncedRealm.beginWrite()
                                didStartWrite = true
                            }
                            if let lastModifiedString = response.response?.allHeaderFields["Last-Modified"] as? String {
                                eventRanker?.oprLastModified = lastModifiedString
                            }
                            
                            if didStartWrite {
                                do {
                                    try RealmController.realmController.syncedRealm.commitWrite()
                                } catch {
                                    CLSNSLogv("Error writing last modified and cache control values for OPR: \(error)", getVaList([]))
                                    Crashlytics.sharedInstance().recordError(error)
                                }
                            }
                            
                            completionHandler(oprs, nil)
                        } catch {
                            //Check if it was just because TBA returned "null"
                            if String.init(data: responseData, encoding: String.Encoding.ascii) == "null" {
                                completionHandler(nil, error)
                            } else {
                                CLSNSLogv("Error serializing opr json: \(error)", getVaList([]))
                                completionHandler(nil, error)
                                Crashlytics.sharedInstance().recordError(error)
                            }
                        }
                    case .failure(let error):
                        if response.response?.statusCode == 304 {
                            completionHandler(nil, nil)
                        } else {
                            CLSNSLogv("Failed to retrieve oprs from cloud with error: \(error)", getVaList([]))
                            completionHandler(nil, error)
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
            }
        }
    }
    
    func teamStatuses(forEvent eventKey: String, withCompletionHandler completionHandler: @escaping ([String:FRCTeamEventStatus?]?,Error?) -> Void) {
        DispatchQueue.main.async {
            var lastModified: String?
            var eventRanker: EventRanker?
            if let ranker = RealmController.realmController.syncedRealm.object(ofType: EventRanker.self, forPrimaryKey: eventKey) {
                eventRanker = ranker
                lastModified = ranker.statusesLastModified
            }
            
            Alamofire.request(baseApi + "event/\(eventKey)/teams/statuses", method: .get, headers: self.header(withLastModified: lastModified))
            .validate(statusCode: 200...200)
                .responseData {response in
                    switch response.result {
                    case .success(let responseData):
                        do {
                            let statuses = try self.jsonDecoder.decode([String:FRCTeamEventStatus?].self, from: responseData)
                            
                            let didStartWrite = !RealmController.realmController.syncedRealm.isInWriteTransaction
                            if didStartWrite {
                                RealmController.realmController.syncedRealm.beginWrite()
                            }
                            
                            if let newLastModified = response.response?.allHeaderFields["Last-Modified"] as? String {
                                eventRanker?.statusesLastModified = newLastModified
                            }
                            
                            if didStartWrite {
                                do {
                                    try RealmController.realmController.syncedRealm.commitWrite()
                                } catch {
                                    CLSNSLogv("Error writing last modified and cache control values for statuses: \(error)", getVaList([]))
                                    Crashlytics.sharedInstance().recordError(error)
                                }
                            }
                            
                            completionHandler(statuses, nil)
                        } catch {
                            CLSNSLogv("Error serializing status json: \(error)", getVaList([]))
                            completionHandler(nil, error)
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    case .failure(let error):
                        if response.response?.statusCode == 304 {
                            completionHandler(nil, nil)
                        } else {
                            CLSNSLogv("Failed to retrieve oprs from cloud with error: \(error)", getVaList([]))
                            completionHandler(nil, error)
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
            }
        }
    }
}
