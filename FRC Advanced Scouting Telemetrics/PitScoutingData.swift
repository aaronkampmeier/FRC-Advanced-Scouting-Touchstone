//
//  PitScoutingData.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/17/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation

class PitScoutingData: PitScoutingDataSource {
    func requestedDataInputs(forScoutedTeam scoutedTeam: ScoutedTeam) -> [PitScoutingViewController.PitScoutingParameter] {
        return [
            PitScoutingViewController.PitScoutingParameter(key: "robotWeight", type: .TextField, label: "Weight", options: nil, scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "robotHeight", type: .TextField, label: "Height", options: nil, scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "robotLength", type: .TextField, label: "Length", options: nil, scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "driveTrain", type: .StringField, label: "Drive Train", options: nil, scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "programmingLanguage", type: .StringField, label: "Programming Language", options: nil, scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "computerVisionCapability", type: .SegmentedSelector, label: "Computer Vision Capability", options: ["Yes", "Somewhat","No"], scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "sandstormCapability", type: .SegmentedSelector, label: "Sandstorm Capability", options: ["Auto", "Cameras","None"], scoutedTeam: scoutedTeam),
            
            PitScoutingViewController.PitScoutingParameter(key: "hatchSourceCapability", type: .SegmentedSelector, label: "Hatches Source", options: ["Floor","Feeder","Both", "None"], scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "rocketHatchCapability", type: .SegmentedSelector, label: "Rocket Max Hatch Level", options: ["3","2","1","None"], scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "cargoShipHatchCapability", type: .SegmentedSelector, label: "Cargo Ship Hatch Capability", options: ["Yes","Somewhat","No"], scoutedTeam: scoutedTeam),
            
            PitScoutingViewController.PitScoutingParameter(key: "rocketCargoCapability", type: .SegmentedSelector, label: "Rocket Max Cargo Level", options: ["3","2","1","None"], scoutedTeam: scoutedTeam),
            PitScoutingViewController.PitScoutingParameter(key: "hasShooter", type: .SegmentedSelector, label: "Shooter", options: ["Yes","No"], scoutedTeam: scoutedTeam),
            
            PitScoutingViewController.PitScoutingParameter(key: "climbCapability", type: .SegmentedSelector, label: "Climb Capability", options: ["3","2","1","None"], scoutedTeam: scoutedTeam)
        ]
    }
}
