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

private let baseApi = "https://fast.kampmeier.com/api/v2/"
private let baseApiUrl = try! baseApi.asURL()
private let apiKey = "c67378f6984026e97ca5abdc343f7f7ff77b5135576aed64c3fcce034d3e55e8"

class CloudData {
    private let headers = [
        "X-Dreamfactory-API-Key":apiKey,
        "Accept": "application/json"
    ]
	
    func events(withCompletionHandler completionHandler: @escaping ([FRCEvent]?) -> Void) {
        Alamofire.request(baseApi + "tbadb/events/2016", method: .get, headers: headers)
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
        Alamofire.request(baseApi + "tbadb/event/\(eventKey)/matches", method: .get, headers: headers)
        .validate(statusCode: 200...200)
            .responseJSON() {response in
                switch response.result{
                case .success(let responseData):
                    if let json = responseData as? [[String:Any]] {
                        let matches = [FRCMatch].from(jsonArray: json)
                        completionHandler(matches)
                    }
                case .failure(let error):
                    NSLog("Failed to retrieve matches from cloud with error: \(error)")
                    completionHandler(nil)
                }
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
	
    func preloadEventMatches() {
        
    }
}
