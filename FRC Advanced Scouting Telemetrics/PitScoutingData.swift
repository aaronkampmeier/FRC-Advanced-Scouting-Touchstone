//
//  PitScoutingData.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/17/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics

struct PitScoutingJSONDefinition: Codable {
    let key: String
    let type: String
    let label: String
    let options: [String]?
}

class PitScoutingData: PitScoutingDataSource {
    private func getModel() -> [String:[PitScoutingJSONDefinition]] {
        //Fetch from the cloud, and if not return the stored one
        
        if let modelUrl = Bundle.main.url(forResource: "PitScoutingInputs2019", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: modelUrl, options: [])
                
                let model = try JSONDecoder().decode([String:[PitScoutingJSONDefinition]].self, from: jsonData)
                
                return model
            } catch {
                //Error reading json data
                CLSNSLogv("Error reading SS model JSON data: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                return [:]
            }
        } else {
            return [:]
        }
    }
    
    func requestedDataInputs(forScoutedTeam scoutedTeam: ScoutedTeam) -> [PitScoutingViewController.PitScoutingParameter] {
        let model = self.getModel()
        var returnParams = [PitScoutingViewController.PitScoutingParameter]()
        
        let year = scoutedTeam.eventKey.trimmingCharacters(in: CharacterSet.letters)
        if let yearlyData = model[year] ?? model["2019"] {
            for input in yearlyData {
                returnParams.append(PitScoutingViewController.PitScoutingParameter(key: input.key, type: PitScoutingViewController.PitScoutingParameterType(rawValue: input.type) ?? .TextField, label: input.label, options: input.options, scoutedTeam: scoutedTeam))
            }
        }
        
        return returnParams
    }
}
