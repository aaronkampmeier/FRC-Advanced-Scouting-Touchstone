//
//  PitScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

typealias PitScoutingUpdateHandler = ((Any?)->Void)
typealias PitScoutingCurrentValue = ()->Any?

//A class that all the pit scouting cells subclass and override the default methods
class PitScoutingCell: UICollectionViewCell {
    func setUp(parameter: PitScoutingViewController.PitScoutingParameter) {
        
    }
}

class PitScoutingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var teamLabel: UILabel?
    @IBOutlet weak var teamNicknameLabel: UILabel?
    
    var scoutedTeam: Team? {
        didSet {
            //Reload the data and change the labels for the new team
            collectionView?.reloadData()
            teamLabel?.text = scoutedTeam?.teamNumber
            teamNicknameLabel?.text = scoutedTeam?.nickname
        }
    }
    
    //PitScoutingParameter represents a value that should appear in pit scouting and can be saved
    var pitScoutingParameters: [PitScoutingParameter] = []
    
    enum PitScoutingParameterType: String {
        case TextField = "pitTextFieldCell"
        case SegmentedSelector = "pitSegmentSelectorCell"
        case TableViewSelector = "pitTableViewCell"
        case ImageSelector = "pitImageSelectorCell"
        case Button = "pitButtonCell"
        
        var cellID: String {
            return self.rawValue
        }
    }
    
    struct PitScoutingParameter {
        let type: PitScoutingParameterType
        let label: String
        //Options should be left nil for all types except Segmented Selector
        let options: [String]?
        let currentValue: PitScoutingCurrentValue
        let updateHandler: PitScoutingUpdateHandler
        
        init(type: PitScoutingParameterType, label: String, options: [String]?, currentValue: @escaping PitScoutingCurrentValue, updateHandler: @escaping PitScoutingUpdateHandler) {
            self.type = type
            self.label = label
            self.options = options
            self.currentValue = currentValue
            self.updateHandler = updateHandler
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pitScoutingParameters = [
            
            PitScoutingParameter(type: .TextField, label: "Weight", options: nil, currentValue: {self.scoutedTeam?.local.robotWeight?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    let number = NSNumber(value: doubleValue)
                    self.scoutedTeam?.local.robotWeight = number
                } else {
                    self.scoutedTeam?.local.robotWeight = nil
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Height", options: nil, currentValue: {self.scoutedTeam?.local.robotHeight?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.robotHeight = NSNumber(value: doubleValue)
                } else {
                    self.scoutedTeam?.local.robotHeight = nil
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Driver XP", options: nil, currentValue: {self.scoutedTeam?.local.driverXP?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.driverXP = NSNumber(value: doubleValue)
                } else {
                    self.scoutedTeam?.local.driverXP = nil
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "High Goal Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.highGoalCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.highGoalCapability = stringValue
                } else {
                    self.scoutedTeam?.local.highGoalCapability = nil
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Low Goal Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.lowGoalCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.lowGoalCapability = stringValue
                } else {
                    self.scoutedTeam?.local.lowGoalCapability = nil
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Vision Tracking Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.visionTrackingCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.visionTrackingCapability = stringValue
                } else {
                    self.scoutedTeam?.local.visionTrackingCapability = nil
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Climber Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.climberCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.climberCapability = stringValue
                } else {
                    self.scoutedTeam?.local.climberCapability = nil
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Tank Size", options: nil, currentValue: {self.scoutedTeam?.local.tankSize?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.tankSize = NSNumber(value: doubleValue)
                } else {
                    self.scoutedTeam?.local.tankSize = nil
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Programming Language", options: ProgrammingLanguage.allStringValues, currentValue: {self.scoutedTeam?.local.programmingLanguage}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.programmingLanguage = stringValue
                } else {
                    self.scoutedTeam?.local.programmingLanguage = nil
                }
            }),
            
            PitScoutingParameter(type: .Button, label: "", options: nil, currentValue: {self.scoutedTeam?.local.canBanana?.boolValue}, updateHandler: {newValue in
                if let boolValue = newValue as? Bool {
                    self.scoutedTeam?.local.canBanana = NSNumber(value: boolValue)
                } else {
                    self.scoutedTeam?.local.canBanana = nil
                }
                
            }),
            
            PitScoutingParameter(type: .ImageSelector, label: "Front Image", options: nil, currentValue: {
                if let imageData = self.scoutedTeam?.local.frontImage {
                    let image = UIImage(data: imageData as Data)
                    return image
                } else {
                    return nil
                }
            }, updateHandler: {newValue in
                if let image = newValue as? UIImage {
                    let imageData = UIImageJPEGRepresentation(image, 1)
                    self.scoutedTeam?.local.frontImage = imageData as NSData?
                } else {
                    self.scoutedTeam?.local.frontImage = nil
                }
            })
        ]
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        //Initially set the labels' values
        teamLabel?.text = scoutedTeam?.teamNumber
        teamNicknameLabel?.text = scoutedTeam?.nickname
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager().commitChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pitScoutingParameters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let parameter = pitScoutingParameters[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: parameter.type.cellID, for: indexPath) as! PitScoutingCell
        
        cell.setUp(parameter: parameter)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch pitScoutingParameters[indexPath.item].type {
        case .TextField:
            return CGSize(width: 230, height: 50)
        case .SegmentedSelector:
            return CGSize(width: 290, height: 80)
        case .TableViewSelector:
            return CGSize(width: 250, height: 130)
        case .ImageSelector:
            return CGSize(width: 120, height: 120)
        case .Button:
            return CGSize(width: 180, height: 50)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PitScoutingViewController: UICollectionViewDelegateFlowLayout {
    
}
