//
//  PitScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSMobileClient

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

protocol PitScoutingDataSource {
    func requestedDataInputs(forScoutedTeam scoutedTeam: ScoutedTeam) -> [PitScoutingViewController.PitScoutingParameter]
}

class PitScoutingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var teamLabel: UILabel?
    @IBOutlet weak var teamNicknameLabel: UILabel?
    
    var teamKey: String?
    var eventKey: String?
    
    //PitScoutingParameter represents a value that should appear in pit scouting and can be saved
    var pitScoutingParameters: [PitScoutingParameter] = []
    var dataSource: PitScoutingDataSource?
    
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
        let key: String
        
        init(key: String, type: PitScoutingParameterType, label: String, options: [String]?, currentValue: @escaping PitScoutingCurrentValue) {
            self.type = type
            self.key = key
            self.label = label
            self.options = options
            self.currentValue = currentValue
        }
    }
    
    //For updates we will keep them in a stack and then batch write them to save resources
    private var updateTimer: Timer?
    
    private var updatedValues: [String:Any] = [:]
    func registerUpdate(forKey key: String, value: Any?) {
        updatedValues[key] = value
    }
    private func writeUpdates() {
        if let teamKey = self.teamKey, let eventKey = self.eventKey {
            //Try to create the json
            do {
                if updatedValues.count > 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: updatedValues, options: [])
                    
                    let updateString = String(data: jsonData, encoding: .utf8)
                    let mutation = UpdateScoutedTeamMutation(eventKey: eventKey, teamKey: teamKey, attributes: updateString!)
                    
                    //Perform the mutation
                    Globals.appDelegate.appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
                        
                    }, conflictResolutionBlock: { (snapshot, taskCompletion, result) in
                        
                    }) {result, error in
                        if Globals.handleAppSyncErrors(forQuery: "UpdateScoutedTeam", result: result, error: error) {
                            
                        } else {
                            //Show error
                        }
                    }
                }
            } catch {
                //TODO: Throw and Show Error
            }
        }
    }
    func periodicalUpdate(time: Timer) {
        writeUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = PitScoutingData()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.keyboardDismissMode = .interactive
        
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
        
        Answers.logCustomEvent(withName: "Closed Pit Scouting", customAttributes: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp(forTeamKey teamKey: String, inEvent eventKey: String) {
        pitScoutingParameters = []
        self.collectionView?.reloadData()
        
        self.teamKey = teamKey
        self.eventKey = eventKey
        self.teamLabel?.text = teamKey.trimmingCharacters(in: CharacterSet.letters)
        self.teamNicknameLabel?.text = ""
        
        //Get the scouted team
        Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-PitScouting", result: result, error: error) {
                if let scoutedTeam = result?.data?.listScoutedTeams?.first(where: {$0?.teamKey == teamKey})??.fragments.scoutedTeam {
                    self.pitScoutingParameters = self.dataSource?.requestedDataInputs(forScoutedTeam: scoutedTeam) ?? []
                    self.collectionView?.reloadData()
                }
            } else {
                //TODO: Show error
            }
        })
        
        Globals.appDelegate.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataDontFetch, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTeams-PitScouting", result: result, error: error) {
                //If we get the cached team, put in its nickname
                self.teamNicknameLabel?.text = result?.data?.listTeams?.first(where: {$0?.key == teamKey})??.fragments.team.nickname
            }
        })
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
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
        
        let navVC = UINavigationController(rootViewController: notesVC)
        
        notesVC.load(forEventKey: eventKey ?? "", andTeamKey: teamKey ?? "")
        
        navVC.modalPresentationStyle = .popover
        
        let popoverPresController = navVC.popoverPresentationController
        popoverPresController?.permittedArrowDirections = .up
        popoverPresController?.barButtonItem = sender
        
        present(navVC, animated: true, completion: nil)
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
