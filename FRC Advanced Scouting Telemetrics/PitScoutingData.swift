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

//TODO: Move these into data file
//        pitScoutingParameters = [

//            PitScoutingParameter(type: .ImageSelector, label: "Front Image", options: nil, currentValue: {
//                if let imageData = self.scoutedTeam?.scouted?.frontImage {
//                    let image = UIImage(data: imageData as Data)
//                    return image
//                } else {
//                    return nil
//                }
//            }, updateHandler: {newValue in
//                if let image = newValue as? UIImage {
//                    //TODO: Lower the image quality to save space
//                    let imageData = UIImageJPEGRepresentation(image, 0.01)
//                    self.scoutedTeam?.scouted?.frontImage = imageData
//                }
//
//                NotificationCenter.default.post(name: PitScoutingNewImageNotification, object: self, userInfo: ["ForTeam":self.scoutedTeam as Any])
//            }),
//
//            PitScoutingParameter(type: .TextField, label: "Weight", options: nil, currentValue: {self.scoutedTeam?.scouted?.robotWeight.value}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.robotWeight.value = newValue as? Double
//            }),
//
//            PitScoutingParameter(type: .TextField, label: "Length", options: nil, currentValue: {self.scoutedTeam?.scouted?.robotLength.value}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.robotLength.value = newValue as? Double
//            }),
//            PitScoutingParameter(type: .TextField, label: "Width", options: nil, currentValue: {self.scoutedTeam?.scouted?.robotWidth.value}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.robotWidth.value = newValue as? Double
//            }),
//            PitScoutingParameter(type: .TextField, label: "Height", options: nil, currentValue: {self.scoutedTeam?.scouted?.robotHeight.value}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.robotHeight.value = newValue as? Double
//            }),
//
//            PitScoutingParameter(type: .TextField, label: "Driver XP", options: nil, currentValue: {self.scoutedTeam?.scouted?.driverXP.value}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.driverXP.value = newValue as? Double
//            }),
//
//            PitScoutingParameter(type: .StringField, label: "Drive Train", options: nil, currentValue: {self.scoutedTeam?.scouted?.driveTrain}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.driveTrain = newValue as? String
//            }),
//
//            PitScoutingParameter(type: .StringField, label: "Program. Lang.", options: nil, currentValue: {self.scoutedTeam?.scouted?.programmingLanguage}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.programmingLanguage = newValue as? String
//            }),
//
//            PitScoutingParameter(type: .SegmentedSelector, label: "Computer Vision Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted?.computerVisionCapability}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.computerVisionCapability = newValue as? String
//            }),
//
//            PitScoutingParameter(type: .SegmentedSelector, label: "Game Strategy", options: GamePlayStrategy.allStringValues, currentValue: {self.scoutedTeam?.scouted?.strategy}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.strategy = newValue as? String
//            }),
//
//            //2018 Game Values
//            PitScoutingParameter(type: .SegmentedSelector, label: "Scale Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted?.scaleCapability}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.scaleCapability = newValue as? String
//            }),
//            PitScoutingParameter(type: .SegmentedSelector, label: "Switch Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted?.switchCapability}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.switchCapability = newValue as? String
//            }),
//            PitScoutingParameter(type: .SegmentedSelector, label: "Vault Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted?.vaultCapability}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.vaultCapability = newValue as? String
//            }),
//            PitScoutingParameter(type: .SegmentedSelector, label: "Climb Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted?.climbCapability}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.climbCapability = newValue as? String
//            }),
//            PitScoutingParameter(type: .TableViewSelector, label: "Climber Type", options: ClimberType.allValues.map({$0.rawValue}), currentValue: {self.scoutedTeam?.scouted?.climberType}, updateHandler: {newValue in self.scoutedTeam?.scouted?.climberType = newValue as? String}),
//
//            ///Banana
//            PitScoutingParameter(type: .Button, label: "", options: nil, currentValue: {self.scoutedTeam?.scouted?.canBanana}, updateHandler: {newValue in
//                self.scoutedTeam?.scouted?.canBanana = newValue as? Bool ?? false
//            })
//        ]
