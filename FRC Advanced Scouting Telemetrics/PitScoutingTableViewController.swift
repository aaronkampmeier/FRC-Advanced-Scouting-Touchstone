//
//  PitScoutingTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/12/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSAppSync
import AVFoundation
import Crashlytics

class PitScoutingTableViewController: UITableViewController {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    private var competitionModelState: FASTCompetitionModelState?
    private var pitScoutingModel: PitScoutingModel? {
        switch competitionModelState {
        case .Loaded(let m):
            return m.pitScouting
        default:
            return nil
        }
    }
    private var teamKey: String?
    private var eventKey: String?
    private var currentScoutedTeam: ScoutedTeam?
    private var scoutedTeamFetcher: Cancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    private var updateTimer: Timer?
    private var updatedValues: [String:Any] = [:]
    private func registerUpdate(forKey key: String, value: Any?) {
        updatedValues[key] = value
    }
    private func writeUpdates() {
        if let teamKey = self.teamKey, let eventKey = self.eventKey, let scoutTeam = Globals.dataManager.enrolledScoutingTeamID {
            //Try to create the json
            do {
                if updatedValues.count > 0 {
                    let jsonData = try JSONSerialization.data(withJSONObject: updatedValues, options: [])
                    
                    let updateString = String(data: jsonData, encoding: .utf8)
                    let mutation: UpdateScoutedTeamMutation
                    mutation = UpdateScoutedTeamMutation(scoutTeam: scoutTeam, eventKey: eventKey, teamKey: teamKey, attributes: updateString!)
                    
                    //Perform the mutation
                    Globals.appSyncClient?.perform(mutation: mutation, optimisticUpdate: { (transaction) in
                        
                    }) {result, error in
                        if Globals.handleAppSyncErrors(forQuery: "UpdateScoutedTeam", result: result, error: error) {
                            //Shouldn't need to update the cache, because the AsyncManager should have a deltaSync enabled on the ListScoutedTeams query
//                            Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
//                                try? transaction.update(query: ListScoutedTeamsQuery(scoutTeam: scoutTeam, eventKey: eventKey)) { (selectionSet) in
//                                    let oldAttributeDictionary = selectionSet.listScoutedTeams?.first(where: {$0?.teamKey == teamKey})??.fragments.scoutedTeam.attributeDictionary
//
//                                }
//                                return true
//                            })
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
    
    private let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 44
        
        if #available(iOS 13.0, *) {
            cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        } else {
            cameraButton.setImage(UIImage(named: "Camera"), for: .normal)
        }
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = doneButton
        
        NotificationCenter.default.addObserver(forName: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            self?.clear()
        }
        
        viewIsLoadedSemaphore.signal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: periodicalUpdate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        writeUpdates()
        updateTimer?.invalidate()
    }
    
    @objc private func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func clear() {
        scoutedTeamFetcher?.cancel()
        currentScoutedTeam = nil
        dismiss(animated: true, completion: nil)
    }
    
    internal func load(forTeamKey teamKey: String, inEvent eventKey: String) {
        if let scoutTeam = Globals.dataManager.enrolledScoutingTeamID {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                self?.viewIsLoadedSemaphore.wait()
                self?.viewIsLoadedSemaphore.signal()
                DispatchQueue.main.async {
                    self?.teamKey = teamKey
                    self?.eventKey = eventKey
                    self?.mainLabel.text = "Team \(teamKey.trimmingCharacters(in: CharacterSet.letters))"
                    self?.subLabel.text = eventKey
                    self?.competitionModelState = Globals.dataManager.asyncLoadingManager.eventModelStates[eventKey]
                    self?.tableView.reloadData()
                    
                    self?.scoutedTeamFetcher = Globals.appSyncClient?.fetch(query: ListScoutedTeamsQuery(scoutTeam: scoutTeam, eventKey: eventKey), cachePolicy: .returnCacheDataDontFetch, resultHandler: {[weak self] (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-PitScouting", result: result, error: error) {
                            if let sTeam = result?.data?.listScoutedTeams?.first(where: {$0?.teamKey == teamKey}) {
                                self?.currentScoutedTeam = sTeam?.fragments.scoutedTeam
                                self?.tableView.reloadData()
                            }
                        }
                    })
                    
                }
            }
        }
    }
    
    @IBAction func commentsPressed(_ sender: Any) {
        if let scoutTeam = Globals.dataManager.enrolledScoutingTeamID, let eventKey = eventKey, let teamKey = teamKey {
            let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
            
            let navVC = UINavigationController(rootViewController: notesVC)
            
            notesVC.load(inScoutTeam: scoutTeam, forEventKey: eventKey, andTeamKey: teamKey)
            
            navVC.modalPresentationStyle = .popover
            
            let popoverPresController = navVC.popoverPresentationController
//            popoverPresController?.permittedArrowDirections = .up
            popoverPresController?.barButtonItem = sender as? UIBarButtonItem
            
            present(navVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return pitScoutingModel != nil ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pitScoutingModel?.inputs.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let input = pitScoutingModel?.inputs[indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: input.type.cellID, for: indexPath) as? PitScoutingTableViewCell {
            
            cell.setUp(forInput: input, currentValue: updatedValues[input.key] ?? currentScoutedTeam?.attributeDictionary?[input.key]) {[weak self] (newValue) in
                self?.updatedValues[input.key] = newValue
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return pitScoutingModel?.note
    }
    
    private let imageController = UIImagePickerController()
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        //TODO: REMOVE BELOW ONCE SCOUTING PHOTOS FIXED
        let alert = UIAlertController(title: "Coming Soon", message: "The ability to add photos for teams is coming soon! Sorry for the inconvenience as we gear up for the 2020 season. Check back soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No Problem! You're amazing Aaron :)", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) || UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                //Ask for permission
                let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                if  authStatus != .authorized && authStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {_ in })
                } else if authStatus == .denied {
                    let alert = UIAlertController(title: "You Have Denied Acces to the Camera", message: "Go to Settings > Privacy > Camera > FAST and turn it on.", preferredStyle: .alert)
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
                        sourceSelector.popoverPresentationController?.sourceView = sender as? UIView
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
    
    private func presentImageController(_ controller: UIImagePickerController, withSource source: UIImagePickerController.SourceType) {
        controller.sourceType = source
        controller.allowsEditing = false
        
        if source == .camera {
            imageController.modalPresentationStyle = .fullScreen
        } else if source == .photoLibrary {
            imageController.modalPresentationStyle = .popover
            imageController.popoverPresentationController?.sourceView = cameraButton
        }
        Globals.appDelegate.presentViewControllerOnTop(controller, animated: true)
    }
    
    //TODO: Figure out how to fix this
    func uploadImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.3) else {
            let alert = UIAlertController(title: "Error Saving Image", message: "There was an error saving the image, please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            CLSNSLogv("Error creating data from pit scouting image", getVaList([]))
            Crashlytics.sharedInstance().recordCustomExceptionName("UIImage Failure to Create Data", reason: nil, frameArray: [])
            return
        }
        
        //        let transferUtility = AWSS3TransferUtility.default()
        //
        //        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        //        uploadExpression.setValue(AWSMobileClient.default().username, forRequestHeader: "x-amz-meta-user-id")
        //        uploadExpression.setValue(eventKey, forRequestHeader: "x-amz-meta-event-key")
        //        uploadExpression.setValue(teamKey, forRequestHeader: "x-amz-meta-team-key")
        //        uploadExpression.progressBlock = {(task, progress) in
        //            DispatchQueue.main.async {
        //                self.progressView.isHidden = false
        //                self.progressView.progress = Float(progress.fractionCompleted)
        //            }
        //        }
        //
        //        let identityId = AWSMobileClient.default().identityId
        //        let key = "private/\(identityId ?? "")/\(eventKey ?? "")/\(teamKey ?? "").jpeg"
        //        transferUtility.uploadData(data, key: key, contentType: "image/jpeg", expression: uploadExpression) { (uploadTask, error) in
        //            DispatchQueue.main.async {
        //                self.progressView.isHidden = true
        //                if let error = error {
        //                    CLSNSLogv("Error uploading image to S3: \(error)", getVaList([]))
        //                    Crashlytics.sharedInstance().recordError(error)
        //
        //                    let alert = UIAlertController(title: "Error Uploading Team Image", message: "There was an error uploading the team image. Make sure you are connected to the internet and try again.", preferredStyle: .alert)
        //                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //                    Globals.appDelegate.presentViewControllerOnTop(alert, animated: true)
        //                } else {
        //                    //Success
        //                    CLSNSLogv("Success uploading team image", getVaList([]))
        //                    //Save it in the scouted team as well now
        //                    let imageInput = ImageInput(bucket: "fast-userfiles-mobilehub-708509237" /*transferUtility.transferUtilityConfiguration.bucket*/, key: key, region: "us-east-1")
        //                    let mutation = UpdateScoutedTeamMutation(eventKey: self.eventKey ?? "", teamKey: self.teamKey ?? "", image: imageInput, attributes: "{}")
        //                    Globals.appSyncClient?.perform(mutation: mutation, resultHandler: { (result, error) in
        //                        if Globals.handleAppSyncErrors(forQuery: "UpdateScoutedTeam-SetImage", result: result, error: error) {
        //
        //                        } else {
        //
        //                        }
        //                    })
        //                }
        //            }
        //        }
        //            .continueWith { (uploadTask) -> Any? in
        //                if let error = uploadTask.error {
        //                    CLSNSLogv("Error Uploading image: \(error)", getVaList([]))
        //                    Crashlytics.sharedInstance().recordError(error)
        //                }
        //
        //                if let uploadTask = uploadTask.result {
        //
        //                }
        //
        //                return nil
        //        }
    }
}

extension PitScoutingTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraButton.setImage(image, for: .normal)
            
            //Upload it
            self.uploadImage(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

/// Required for the imageController delegate
extension PitScoutingTableViewController: UINavigationControllerDelegate {
    
}



