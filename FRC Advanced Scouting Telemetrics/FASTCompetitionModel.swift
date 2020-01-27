//
//  FASTCompetitionModel.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/10/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics

internal enum FASTCompetitionModelState {
    case Loaded(FASTCompetitionModel)
    case NotSupported
    case NoModel
    case Loading
    case Error(Error)
    
    internal static func load(withJson jsonData: Data) -> FASTCompetitionModelState {
        do {
            let model = try JSONDecoder().decode(FASTCompetitionModel.self, from: jsonData)
            return .Loaded(model)
        } catch {
            //Check if there is an error in the json
            if let jsonError = try? JSONDecoder().decode([String:String].self, from: jsonData)["error"] {
                switch jsonError {
                case "FASTErrorUnsupportedCompetitionYear":
                    return .NotSupported
                case "FASTErrorModelNotPublished":
                    return .NoModel
                default:
                    return .Error(error)
                }
            } else {
                CLSNSLogv("Error loading stands scouting model from JSON: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                return .Error(error)
            }
        }
    }
    
    /// Returns a tuple of a title and a description message detailing the state of the competition model
    func stateDescription() -> (String, String?) {
        let titleMessage: String
        let descriptionMessage: String?
        
        switch self {
        case .Loaded(_):
            titleMessage = "Good to Go"
            descriptionMessage = nil
        case .Error(let error):
            titleMessage = "Error Loading Competition Model"
            descriptionMessage = "There was an error loading the stands scouting model: \(error)"
        case .Loading:
            titleMessage = "Loading..."
            if #available(iOS 12.0, *) {
                if FASTNetworkManager.main.isOnline() {
                    descriptionMessage = "The stands scouting model is loading. Please check the speed of your internet connection."
                } else {
                    descriptionMessage = "The stands scouting model is attempting to load. Please connect to the internet."
                }
            } else {
                descriptionMessage = "The stands scouting model is loading. Make sure you are connected to the internet."
            }
        case .NoModel:
            titleMessage = "No Model"
            descriptionMessage = "We're hard at work getting the model ready for this year. Please check back soon."
        case .NotSupported:
            titleMessage = "Not Supported"
            descriptionMessage = "Unfortunately, the specified competition year is not supported for scouting in FAST. If you believe this is in error, please contact us."
        }
        
        return (titleMessage, descriptionMessage)
    }
}

internal struct FASTCompetitionModel: Codable {
    let pitScouting: PitScoutingModel
    let standsScouting: StandsScoutingModel
}

internal struct PitScoutingModel: Codable {
    let note: String?
    let inputs: [PitScoutingInput]
}
internal struct PitScoutingInput: Codable {
    let key: String
    let type: PitScoutingParameterType
    let label: String
    let options: [String]?
}

enum PitScoutingParameterType: String, Codable {
    case double = "Double"
    case string = "String"
    case selectString = "SelectString"
    case binary = "Binary"
    case button = "Button"
    
    var cellID: String {
        switch self {
        case .string:
            fallthrough
        case .double:
            return "pitTextFieldCell"
        case .selectString:
            return "pitSegmentSelectorCell"
        case .binary:
            return "pitSwitchCell"
        case .button:
            return "pitButtonCell"
        }
    }
}

// Game is broken down into 3 parts, Start State, End State, and TimeMarkers for normal play
internal struct GameState: Codable {
    let name: String
    var shortName: String?
    let key: String
    let options: [SSOption]
}

internal struct SSOption: Codable {
    internal init(name: String, key: String, color: String?, shortName: String) {
        self.name = name
        self.key = key
        self.color = color
        self.shortName = shortName
    }
    let name: String
    let key: String
    var color: String?
    var shortName: String?
}

internal struct GameAction: Codable {
    let name: String
    var shortName: String?
    let key: String
    let subOptions: [SSOption]?
}

internal struct StandsScoutingModel: Codable {
    let startState: [GameState]
    let gameActions: [GameAction]
    let endState: [GameState]
}
