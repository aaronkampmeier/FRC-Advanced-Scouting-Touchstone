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
let PitScoutingNewImageNotification = Notification.Name("PitScoutingNewImageNotification")

//A class that all the pit scouting cells subclass and override the default methods
class PitScoutingCell: UICollectionViewCell {
    func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        
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
        case Switch = "pitSwitchCell"
        
        var cellID: String {
            return self.rawValue
        }
    }
    
    struct PitScoutingParameter {
        let type: PitScoutingParameterType
        let label: String
        //Options should be left nil for all types except Segmented Selector and Table View Multi Selector
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
        
        do {
        pitScoutingParameters = [
            
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
                    self.scoutedTeam?.local.frontImage = imageData as Data?
                }
                
                NotificationCenter.default.post(name: PitScoutingNewImageNotification, object: self, userInfo: ["ForTeam":self.scoutedTeam])
            }),
            
            PitScoutingParameter(type: .ImageSelector, label: "Side Image", options: nil, currentValue: {
                if let imageData = self.scoutedTeam?.local.sideImage {
                    let image = UIImage(data: imageData as Data)
                    return image
                } else {
                    return nil
                }
            }, updateHandler: {newValue in
                if let image = newValue as? UIImage {
                    let imageData = UIImageJPEGRepresentation(image, 1)
                    self.scoutedTeam?.local.sideImage = imageData
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Weight", options: nil, currentValue: {self.scoutedTeam?.local.robotWeight?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    let number = NSNumber(value: doubleValue)
                    self.scoutedTeam?.local.robotWeight = number
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Height", options: nil, currentValue: {self.scoutedTeam?.local.robotHeight?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.robotHeight = NSNumber(value: doubleValue)
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Gears Capability", options: SimpleCapability.allStringValues, currentValue: {self.scoutedTeam?.local.gearsCapability}, updateHandler: {newValue in
                if let capability = newValue as? String {
                    self.scoutedTeam?.local.gearsCapability = capability
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Driver XP", options: nil, currentValue: {self.scoutedTeam?.local.driverXP?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.driverXP = NSNumber(value: doubleValue)
                }
            }),
            
            PitScoutingParameter(type: .TextField, label: "Tank Size", options: nil, currentValue: {self.scoutedTeam?.local.tankSize?.doubleValue}, updateHandler: {newValue in
                if let doubleValue = newValue as? Double {
                    self.scoutedTeam?.local.tankSize = NSNumber(value: doubleValue)
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "High Goal Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.highGoalCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.highGoalCapability = stringValue
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Low Goal Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.lowGoalCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.lowGoalCapability = stringValue
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Vision Tracking Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.visionTrackingCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.visionTrackingCapability = stringValue
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Climber Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.local.climberCapability}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.climberCapability = stringValue
                }
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Programming Language", options: ProgrammingLanguage.allStringValues, currentValue: {self.scoutedTeam?.local.programmingLanguage}, updateHandler: {newValue in
                if let stringValue = newValue as? String {
                    self.scoutedTeam?.local.programmingLanguage = stringValue
                }
            }),
            
            ///Autonomous
            PitScoutingParameter(type: .TableViewSelector, label: "Auto Peg Capability", options: Peg.allStringValues, currentValue: {self.scoutedTeam?.local.autoPegs?.map({Peg.peg(forNumber: $0)!.description})}, updateHandler: {newValue in
                if let newValues = (newValue as? [String]) {
                    let newPegs = newValues.map({Peg(rawValue: $0)!})
                    self.scoutedTeam?.local.autoPegs = newPegs.map({$0.pegNumber})
                }
            }),
            
            PitScoutingParameter(type: .Switch, label: "Auto Does Load Fuel", options: nil, currentValue: {self.scoutedTeam?.local.autoDoesLoadFuel?.boolValue}, updateHandler: {newValue in
                if let newBool = newValue as? Bool {
                    self.scoutedTeam?.local.autoDoesLoadFuel = NSNumber(value: newBool)
                }
            }),
            
            PitScoutingParameter(type: .Switch, label: "Auto Shoots Preloaded Fuel", options: nil, currentValue: {self.scoutedTeam?.local.autoDoesShootPreloaded?.boolValue}, updateHandler: {newValue in
                if let newBool = newValue as? Bool {
                    self.scoutedTeam?.local.autoDoesShootPreloaded = NSNumber(value: newBool)
                }
            }),
            
            PitScoutingParameter(type: .Switch, label: "Auto Shoots More Loaded Fuel", options: nil, currentValue: {self.scoutedTeam?.local.autoDoesShootMoreFuel?.boolValue}, updateHandler: {newValue in
                if let newBool = newValue as? Bool {
                    self.scoutedTeam?.local.autoDoesShootMoreFuel = NSNumber(value: newBool)
                }
                
            }),
            
            ///Banana
            PitScoutingParameter(type: .Button, label: "", options: nil, currentValue: {self.scoutedTeam?.local.canBanana?.boolValue}, updateHandler: {newValue in
                if let boolValue = newValue as? Bool {
                    self.scoutedTeam?.local.canBanana = NSNumber(value: boolValue)
                }
            })
        ]
        }
        
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
        
        cell.setUp(parameter)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parameter = pitScoutingParameters[indexPath.item]
        switch parameter.type {
        case .TextField:
            return CGSize(width: 230, height: 50)
        case .SegmentedSelector:
            return CGSize(width: 290, height: 80)
        case .TableViewSelector:
            return CGSize(width: 250, height: 180)
        case .ImageSelector:
            return CGSize(width: 110, height: 100)
        case .Button:
            return CGSize(width: 180, height: 50)
        case .Switch:
            if parameter.label.characters.count > 20 {
                return CGSize(width: 240, height: 80)
            } else {
                return CGSize(width: 180, height: 80)
            }
        }
    }

    @IBAction func notes(_ sender: UIBarButtonItem) {
        let notesNavVC = storyboard?.instantiateViewController(withIdentifier: "notesNavVC") as! UINavigationController
        let notesVC = notesNavVC.topViewController as! NotesViewController
        notesVC.dataSource = self
        
        notesNavVC.modalPresentationStyle = .popover
        
        let popoverPresController = notesNavVC.popoverPresentationController
        popoverPresController?.permittedArrowDirections = .up
        popoverPresController?.barButtonItem = sender
        
        present(notesNavVC, animated: true, completion: nil)
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

extension PitScoutingViewController: NotesDataSource {
    func currentTeamContext() -> Team {
        return scoutedTeam!
    }
    
    func notesShouldSave() -> Bool {
        return true
    }
}

extension PitScoutingViewController: UICollectionViewDelegateFlowLayout {
    
}
