//
//  PitScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AVFoundation
import AWSS3
import AWSMobileClient

typealias PitScoutingUpdateHandler = ((Any?)->Void)
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
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var teamKey: String?
    var eventKey: String?
    
    static weak var currentPitScouter: PitScoutingViewController?
    
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
        let scoutedTeam: ScoutedTeam
        let key: String
        
        init(key: String, type: PitScoutingParameterType, label: String, options: [String]?, scoutedTeam: ScoutedTeam) {
            self.type = type
            self.key = key
            self.label = label
            self.options = options
            self.scoutedTeam = scoutedTeam
        }
        
        func currentValue() -> Any? {
            if let newerValue = PitScoutingViewController.currentPitScouter?.updatedValues[key] {
                return newerValue
            } else {
                return scoutedTeam.attributeDictionary?[key]
            }
        }
    }
    
    //For updates we will keep them in a stack and then batch write them to save resources
    private var updateTimer: Timer?
    private var newImage: UIImage?
    private var updatedValues: [String:Any?] = [:]
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
                    let mutation: UpdateScoutedTeamMutation
                    mutation = UpdateScoutedTeamMutation(eventKey: eventKey, teamKey: teamKey, attributes: updateString!)
                    
                    //Perform the mutation
                    Globals.appDelegate.appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
                        
                    }, conflictResolutionBlock: { (snapshot, taskCompletion, result) in
                        
                    }) {result, error in
                        if Globals.handleAppSyncErrors(forQuery: "UpdateScoutedTeam", result: result, error: error) {
                            
                        } else {
                            //Show error
                            let alert = UIAlertController(title: "Error Saving Pit Scouting", message: "There was an error saving the pit scouting data. Please check your internet connection and try again. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
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

        PitScoutingViewController.currentPitScouter = self
        // Do any additional setup after loading the view.
        dataSource = PitScoutingData()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.keyboardDismissMode = .interactive
        
        
        self.teamLabel?.text = teamKey?.trimmingCharacters(in: CharacterSet.letters)
        
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
                    
                    //Set Image Button's Image
                    if let teamImageInformation = scoutedTeam.image {
                        //Grab it from S3
                        TeamImageLoader.default.loadImage(withAttributes: teamImageInformation, progressBlock: { (progress) in
                            
                        }, completionHandler: { (image, error) in
                            DispatchQueue.main.async {
                                if let image = image {
                                    self.imageButton.setImage(image, for: .normal)
                                } else if let _ = error {
                                    self.imageButton.setImage(UIImage(named: "Error"), for: .normal)
                                }
                            }
                        })
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error Loading Team", message: "There was an error loading the team. Make sure you are connected to the internet and try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    //MARK: - Photo
    let imageController = UIImagePickerController()
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //Ask for permission
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if  authStatus != .authorized && authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {_ in })
            } else if authStatus == .denied {
                let alert = UIAlertController(title: "You Have Denied Acces to the Camera", message: "Go to Settings> Privacy> Camera> FAST and turn it on.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
            } else if authStatus == .authorized {
                //Set up the camera view and present it
                imageController.delegate = self
                imageController.allowsEditing = true
                
                //Figure out which source to use
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    presentImageController(imageController, withSource: .photoLibrary)
                } else {
                    let sourceSelector = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    sourceSelector.addAction(UIAlertAction(title: "Camera", style: .default) {_ in
                        self.presentImageController(self.imageController, withSource: .camera)
                        Globals.recordAnalyticsEvent(eventType: "added_team_photo", attributes: ["source":"camera"])
                    })
                    sourceSelector.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
                        self.presentImageController(self.imageController, withSource: .photoLibrary)
                        Globals.recordAnalyticsEvent(eventType: "added_team_photo", attributes: ["source":"photo_library"])
                    })
                    sourceSelector.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    sourceSelector.popoverPresentationController?.sourceView = sender
                    Globals.appDelegate.presentViewControllerOnTop(sourceSelector, animated: true)
                }
            } else {
                
            }
        } else {
            let alert = UIAlertController(title: "No Camera", message: "The device you are using does not have image taking abilities.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
        }
    }
    
    func presentImageController(_ controller: UIImagePickerController, withSource source: UIImagePickerControllerSourceType) {
        controller.sourceType = source
        controller.allowsEditing = false
        
        if source == .camera {
            imageController.modalPresentationStyle = .fullScreen
        } else if source == .photoLibrary {
            imageController.modalPresentationStyle = .popover
            imageController.popoverPresentationController?.sourceView = imageButton
        }
        Globals.appDelegate.presentViewControllerOnTop(controller, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func uploadImage(image: UIImage) {
        guard let data = UIImageJPEGRepresentation(image, 0.3) else {
            let alert = UIAlertController(title: "Error Saving Image", message: "There was an error saving the image, please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            CLSNSLogv("Error creating data from pit scouting image", getVaList([]))
            Crashlytics.sharedInstance().recordCustomExceptionName("UIImage Failure to Create Data", reason: nil, frameArray: [])
            return
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.setValue(AWSMobileClient.sharedInstance().username, forRequestHeader: "x-amz-meta-user-id")
        uploadExpression.setValue(eventKey, forRequestHeader: "x-amz-meta-event-key")
        uploadExpression.setValue(teamKey, forRequestHeader: "x-amz-meta-team-key")
        uploadExpression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                self.progressView.isHidden = false
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        }
        
        let identityId = AWSMobileClient.sharedInstance().identityId
        let key = "private/\(identityId ?? "")/\(eventKey ?? "")/\(teamKey ?? "").jpeg"
        transferUtility.uploadData(data, key: key, contentType: "image/jpeg", expression: uploadExpression) { (uploadTask, error) in
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                if let error = error {
                    CLSNSLogv("Error uploading image to S3: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    
                    let alert = UIAlertController(title: "Error Uploading Team Image", message: "There was an error uploading the team image. Make sure you are connected to the internet and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
                } else {
                    //Success
                    CLSNSLogv("Success uploading team image", getVaList([]))
                    //Save it in the scouted team as well now
                    let imageInput = ImageInput(bucket: "fast-userfiles-mobilehub-708509237" /*transferUtility.transferUtilityConfiguration.bucket*/, key: key, region: "us-east-1")
                    let mutation = UpdateScoutedTeamMutation(eventKey: self.eventKey ?? "", teamKey: self.teamKey ?? "", image: imageInput, attributes: "{}")
                    Globals.appDelegate.appSyncClient?.perform(mutation: mutation, resultHandler: { (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "UpdateScoutedTeam-SetImage", result: result, error: error) {
                            
                        } else {
                            
                        }
                    })
                }
            }
        }
            .continueWith { (uploadTask) -> Any? in
                if let error = uploadTask.error {
                    CLSNSLogv("Error Uploading image: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                }
                
                if let uploadTask = uploadTask.result {
                    
                }
                
                return nil
        }
    }
}

extension PitScoutingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageButton.setImage(image, for: .normal)
            
            //Save the image
            self.newImage = image
            
            //Upload it
            self.uploadImage(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PitScoutingViewController: UINavigationControllerDelegate {
    
}

extension PitScoutingViewController: UICollectionViewDelegateFlowLayout {
    
}
