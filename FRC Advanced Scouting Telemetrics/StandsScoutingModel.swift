//
//  StandsScoutingModel.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/10/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics

//Game is broken down into 3 parts, Start State, End State, and TimeMarkers for normal play

struct GameState: Codable {
    let name: String
    var shortName: String?
    let key: String
    let options: [SSOption]
}

struct SSOption: Codable {
    init(name: String, key: String, color: String?) {
        self.name = name
        self.key = key
        self.color = color
    }
    let name: String
    let key: String
    var color: String?
}

struct GameAction: Codable {
    let name: String
    var shortName: String?
    let key: String
    let subOptions: [SSOption]?
}

struct StandsScoutingModel: Codable {
    let startState: [GameState]
    let gameActions: [GameAction]
    let endState: [GameState]
}

class StandsScoutingModelLoader {
    
    
    init() {
        
    }
    
    func getModel(completionHandler: @escaping ((_ model: StandsScoutingModel?) -> Void)) {
        //Get the JSON data
        if let modelUrl = Bundle.main.url(forResource: "SSData2019", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: modelUrl, options: [])
                
                let model = try JSONDecoder().decode(StandsScoutingModel.self, from: jsonData)
                completionHandler(model)
            } catch {
                //Error reading json data
                CLSNSLogv("Error reading SS model JSON data: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
        
    }
}

