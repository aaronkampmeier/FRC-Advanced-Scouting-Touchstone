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
let PitScoutingUpdatedTeamDetail = Notification.Name("PitScoutingUpdatedTeamDetail")

//A class that all the pit scouting cells subclass and override the default methods
class PitScoutingCell: UICollectionViewCell {
    var pitScoutingVC: PitScoutingViewController?
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
            teamLabel?.text = String(scoutedTeam?.teamNumber ?? -1)
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
        case StringField = "pitStringCell"
        
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
    
    //For updates we will keep them in a stack and then batch write them to save resources
    private var updateTimer: Timer?
    var updates = [(updateHandler: PitScoutingUpdateHandler?, value: Any?)]()
    func register(update: PitScoutingUpdateHandler?, withValue val: Any?) {
        updates.append((update, val))
    }
    private func writeUpdates() {
        RealmController.realmController.genericWrite(onRealm: .Synced) {
            let updatesToResolve = self.updates
            self.updates.removeAll()
            for update in updatesToResolve {
                update.updateHandler?(update.value)
            }
        }
    }
    func periodicalUpdate(time: Timer) {
        writeUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            //TODO: Move these into data file
        pitScoutingParameters = [
            
            PitScoutingParameter(type: .ImageSelector, label: "Front Image", options: nil, currentValue: {
                if let imageData = self.scoutedTeam?.scouted.frontImage {
                    let image = UIImage(data: imageData as Data)
                    return image
                } else {
                    return nil
                }
            }, updateHandler: {newValue in
                if let image = newValue as? UIImage {
                    //TODO: Lower the image quality to save space
                    let imageData = UIImageJPEGRepresentation(image, 0.6)
                    self.scoutedTeam?.scouted.frontImage = imageData
                }
                
                NotificationCenter.default.post(name: PitScoutingNewImageNotification, object: self, userInfo: ["ForTeam":self.scoutedTeam as Any])
            }),
            
            PitScoutingParameter(type: .TextField, label: "Weight", options: nil, currentValue: {self.scoutedTeam?.scouted.robotWeight.value}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.robotWeight.value = newValue as? Double
            }),
            
            PitScoutingParameter(type: .TextField, label: "Length", options: nil, currentValue: {self.scoutedTeam?.scouted.robotLength.value}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.robotLength.value = newValue as? Double
            }),
            PitScoutingParameter(type: .TextField, label: "Width", options: nil, currentValue: {self.scoutedTeam?.scouted.robotWidth.value}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.robotWidth.value = newValue as? Double
            }),
            PitScoutingParameter(type: .TextField, label: "Height", options: nil, currentValue: {self.scoutedTeam?.scouted.robotHeight.value}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.robotHeight.value = newValue as? Double
            }),
            
            PitScoutingParameter(type: .TextField, label: "Driver XP", options: nil, currentValue: {self.scoutedTeam?.scouted.driverXP.value}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.driverXP.value = newValue as? Double
            }),
            
            PitScoutingParameter(type: .StringField, label: "Drive Train", options: nil, currentValue: {self.scoutedTeam?.scouted.driveTrain}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.driveTrain = newValue as? String
            }),
            
            PitScoutingParameter(type: .StringField, label: "Program. Lang.", options: nil, currentValue: {self.scoutedTeam?.scouted.programmingLanguage}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.programmingLanguage = newValue as? String
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Computer Vision Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted.computerVisionCapability}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.computerVisionCapability = newValue as? String
            }),
            
            PitScoutingParameter(type: .SegmentedSelector, label: "Game Strategy", options: GamePlayStrategy.allStringValues, currentValue: {self.scoutedTeam?.scouted.strategy}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.strategy = newValue as? String
            }),
            
            //2018 Game Values
            PitScoutingParameter(type: .SegmentedSelector, label: "Scale Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted.scaleCapability}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.scaleCapability = newValue as? String
            }),
            PitScoutingParameter(type: .SegmentedSelector, label: "Switch Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted.switchCapability}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.switchCapability = newValue as? String
            }),
            PitScoutingParameter(type: .SegmentedSelector, label: "Vault Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted.vaultCapability}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.vaultCapability = newValue as? String
            }),
            PitScoutingParameter(type: .SegmentedSelector, label: "Climb Capability", options: Capability.allStringValues, currentValue: {self.scoutedTeam?.scouted.climbCapability}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.climbCapability = newValue as? String
            }),
            
            ///Banana
            PitScoutingParameter(type: .Button, label: "", options: nil, currentValue: {self.scoutedTeam?.scouted.canBanana}, updateHandler: {newValue in
                self.scoutedTeam?.scouted.canBanana = newValue as? Bool ?? false
            })
        ]
        }
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.keyboardDismissMode = .interactive
        
        //Initially set the labels' values
        teamLabel?.text = String(scoutedTeam?.teamNumber ?? -1)
        teamNicknameLabel?.text = scoutedTeam?.nickname
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set up an autosave timer
        if #available(iOS 10.0, *) {
            updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: periodicalUpdate)
        } else {
            // Fallback on earlier versions
            //Eh they don't get autosave
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        writeUpdates()
        updateTimer?.invalidate()
        
        NotificationCenter.default.post(name: PitScoutingUpdatedTeamDetail, object: self)
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
        
        cell.pitScoutingVC = self
        cell.setUp(parameter)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parameter = pitScoutingParameters[indexPath.item]
        switch parameter.type {
        case .TextField, .StringField:
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
