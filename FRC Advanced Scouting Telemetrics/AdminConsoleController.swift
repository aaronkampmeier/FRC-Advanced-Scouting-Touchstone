//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import VTAcknowledgementsViewController
import AWSMobileClient
import AWSAppSync
import Firebase
import FirebasePerformance

class AdminConsoleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var trackedEvents: [ListTrackedEventsQuery.Data.ListTrackedEvent] = []
    
    var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get the tracked events
        trackedEventsWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery-AdminConsole", result: result, error: error) {
                self?.trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
                self?.tableView.reloadData()
            } else {
				
            }
        })
    }
    
    deinit {
        trackedEventsWatcher?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        //Reload the table view
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    enum adminConsoleSections: Int {
        case events
        case about
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            //Events
            return trackedEvents.count + 1
        case tableView.numberOfSections - 1:
            //About Section
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            //Events
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                //Return the add event cell
                return tableView.dequeueReusableCell(withIdentifier: "addEvent")!
            } else {
                //Return the event cell with event name and type
                let cell = tableView.dequeueReusableCell(withIdentifier: "event")!
                cell.textLabel?.text = "\(trackedEvents[indexPath.row].eventName) (\(trackedEvents[indexPath.row].eventKey.trimmingCharacters(in: CharacterSet.letters)))"
                cell.detailTextLabel?.text = trackedEvents[indexPath.row].eventKey
//                cell.detailTextLabel?.text = events[indexPath.row].location
                return cell
            }
        case tableView.numberOfSections - 1:
            //About Section
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "about")!
            case 1:
                return tableView.dequeueReusableCell(withIdentifier: "acknowledgments")!
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "logout")!
                
                if Globals.isInSpectatorMode {
                    (cell.viewWithTag(1) as! UILabel).text = "Exit Spectator Mode"
                } else {
                    let teamNumber: String = AWSMobileClient.sharedInstance().username ?? "?"
                    (cell.viewWithTag(1) as! UILabel).text = "Log Out of Team \(teamNumber)"
                }
                
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "about")!
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Events (swipe left to export/remove)"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            //Events
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                //Did select add event
                if Globals.isInSpectatorMode {
                    self.performSegue(withIdentifier: "addEvent", sender: tableView)
                } else {
                    self.performSegue(withIdentifier: "addEvent", sender: tableView)
                    
                    //First present warning
//                    let warning = UIAlertController(title: "Do Not Repeat", message: "Events need only be added to a team's FAST account once. This should be done by your scouting lead. Please make sure someone else has not already added the same event as this may cause data inconsistencies in rare cases.", preferredStyle: .alert)
//                    warning.addAction(UIAlertAction(title: "I Understand", style: .default, handler: {_ in self.performSegue(withIdentifier: "addEvent", sender: tableView); Answers.logCustomEvent(withName: "Add Event Pressed", customAttributes: ["Route":"I Understand"])}))
//                    warning.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in self.viewWillAppear(false) /*This is just to clear the table view selection*/ ; Answers.logCustomEvent(withName: "Add Event Pressed", customAttributes: ["Route":"Cancel"])}))
//                    self.present(warning, animated: true, completion: nil)
                }
            } else {
                //Did select event info
                // TODO: Display event info
            }
        case tableView.numberOfSections - 1:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "about", sender: self)
            } else if indexPath.row == 1 {
                if let path = Bundle.main.path(forResource: "Pods-acknowledgments", ofType: "plist") {
                    
                    let ackVC = VTAcknowledgementsViewController(path: path)!
                    ackVC.headerText = "Portions of this app run on the following libraries"
                    
                    if let path = Bundle.main.path(forResource: "Additional Licenses", ofType: "plist") {
                        let additionalLicensesDict = NSDictionary(contentsOfFile: path)! as! Dictionary<String, Dictionary<String, String>>
                        
                        let keys = additionalLicensesDict.keys
                        for key in keys {
                            let ack = VTAcknowledgement(title: additionalLicensesDict[key]!["Title"]!, text: additionalLicensesDict[key]!["Text"]!, license: additionalLicensesDict[key]?["License"])
                            
                            ackVC.acknowledgements?.append(ack)
                        }
                    }
                    
                    self.navigationController?.pushViewController(ackVC, animated: true)
                    Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"admin_console_screen","item_id":"acknowledgements"])
                } else {
                    assertionFailure()
                }
            } else if indexPath.row == 2 {
                //Logout
                if Globals.isInSpectatorMode {
                    Globals.recordAnalyticsEvent(eventType: "exit_spectator_mode")
                } else {
                    
                }
                
                //Logout and show onboarding
                AWSDataManager.default.signOut()
                
                UserDefaults.standard.setValue(false, forKey: Globals.isSpectatorModeKey)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            //Events
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
        case 0:
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return nil
            } else {
                let reloadAction = UITableViewRowAction.init(style: .normal, title: "Reload") {[weak self](rowAction, indexPath) in
                    self?.reloadAt(indexPath: indexPath, inTableView: tableView)
                }
                reloadAction.backgroundColor = UIColor.blue
                
                let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") {[weak self](rowAction, indexPath) in
					let confirmationAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete \(self?.trackedEvents[indexPath.row].eventName ?? "") (\(self?.trackedEvents[indexPath.row].eventKey ?? ""))", preferredStyle: .alert)
					confirmationAlert.addAction(UIAlertAction(title: "Yes, Delete It", style: .destructive, handler: { (action) in
						self?.deleteAt(indexPath: indexPath, inTableView: tableView)
					}))
					confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
					
					self?.present(confirmationAlert, animated: true, completion: nil)
                }
                
                let exportToCSV = UITableViewRowAction(style: .default, title: "CSV Export") {[weak self](rowAction, indexPath) in
                    self?.exportToCSV(eventKey: self?.trackedEvents[indexPath.row].eventKey ?? "", withSourceView: nil) {_ in
                    }
                }
                exportToCSV.backgroundColor = .purple
                
                return [reloadAction, exportToCSV, delete]
            }
        default:
            return nil
        }
    }
    
    func reloadAt(indexPath: IndexPath, inTableView tableView: UITableView, withCompletionHandler onCompletion: (() -> Void)? = nil) {
        let event = self.trackedEvents[indexPath.row]
        showLoadingIndicator()
        
        //Call to reload the event
        Globals.appDelegate.appSyncClient?.perform(mutation: AddTrackedEventMutation(eventKey: event.eventKey), conflictResolutionBlock: { (snapshot, taskCompletionSource, result) in
            
        }, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ReloadTrackedEvent-AdminConsole", result: result, error: error) {
                self.removeLoadingIndicator()
                onCompletion?()
            } else {
				
            }
        })
    }
    
    var grayView: UIView?
    func showLoadingIndicator() {
        //Create a loading view
        let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        grayView = UIView(frame: CGRect(x: self.tableView.frame.width / 2 - 50, y: self.tableView.frame.height / 2 - 50, width: 120, height: 120))
        grayView?.backgroundColor = UIColor.lightGray
        grayView?.backgroundColor?.withAlphaComponent(0.7)
        grayView?.layer.cornerRadius = 10
        spinnerView.frame = CGRect(x: grayView!.frame.width / 2 - 25, y: grayView!.frame.height / 2 - 25, width: 50, height: 50)
        grayView?.addSubview(spinnerView)
        spinnerView.startAnimating()
        self.tableView.addSubview(grayView!)
        
        //Prevent user interaction
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func removeLoadingIndicator() {
        //Return user interaction
        self.view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        grayView?.removeFromSuperview()
        
        grayView = nil
    }
    
    func deleteAt(indexPath: IndexPath, inTableView tableView: UITableView) {
        //Call to remove the event
        let trackedEvent = trackedEvents[indexPath.row]
        Globals.appDelegate.appSyncClient?.perform(mutation: RemoveTrackedEventMutation(eventKey: trackedEvent.eventKey), optimisticUpdate: { (transaction) in
            do {
                try transaction?.update(query: ListTrackedEventsQuery(), { (data) in
                    if let index = data.listTrackedEvents?.firstIndex(where: {$0?.eventKey == trackedEvent.eventKey}) {
                        data.listTrackedEvents?.remove(at: index)
                    }
                })
            } catch {
                CLSNSLogv("Error performing opitimistic update on RemoveTrackedEvent", getVaList([]))
            }
        }, conflictResolutionBlock: { (snapshot, taskCompletionSource, result) in
            
        }, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "RemoveTrackedEvent", result: result, error: error) {
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: .left)
//                tableView.endUpdates()
            } else {
                let alert = UIAlertController(title: "Problem Removing Event", message: "An error occured when removing the event.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return nil
            } else {
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {action, view, completionHandler in
                    self.deleteAt(indexPath: indexPath, inTableView: tableView)
                    completionHandler(true)
                }
                
                let reloadAction = UIContextualAction(style: .normal, title: "Reload") {action, view, completionHandler in
                    self.reloadAt(indexPath: indexPath, inTableView: tableView)
                    completionHandler(true)
                }
                reloadAction.backgroundColor = .blue
                
                let exportToCSVAction = UIContextualAction(style: .normal, title: "CSV Export") {action, view, completionHandler in
                    self.exportToCSV(eventKey: self.trackedEvents[indexPath.row].eventKey, withSourceView: view) {successful in
                        completionHandler(true)
                    }
                }
                exportToCSVAction.backgroundColor = .purple
                
                return UISwipeActionsConfiguration(actions: [reloadAction, exportToCSVAction, deleteAction])
            }
        default:
            return nil
        }
    }
    
    func exportToCSV(eventKey: String, withSourceView view: UIView?, onCompletion: @escaping (Bool) -> Void) {
        showLoadingIndicator()
		let perfTrace = Performance.startTrace(name: "CSV Export")
		perfTrace?.setValue(eventKey, forAttribute: "event_key")
//		perfTrace?.start()
		
        let finishingActions: (URL?, Error?) -> Void = {path, error in
            DispatchQueue.main.async {
				perfTrace?.stop()
                self.removeLoadingIndicator()
                if let error = error {
                    let alert = UIAlertController(title: "Export Failed", message: "There was an error exporting to CSV: \(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    onCompletion(false)
                    
                    CLSNSLogv("Failed to write csv text to file: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    
                    Globals.recordAnalyticsEvent(eventType: "export_event_to_csv", attributes: ["event":eventKey, "successful":"false"])
                } else if let path = path {
                    let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: [])
                    
                    activityVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.openInIBooks, UIActivityType.postToFacebook, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.postToFlickr, UIActivityType.postToTwitter, UIActivityType.postToTencentWeibo, UIActivityType.saveToCameraRoll]
                    
                    activityVC.popoverPresentationController?.sourceView = self.tableView
                    if let index = self.trackedEvents.firstIndex(where: {$0.eventKey == eventKey}) {
                        if let tableViewCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                            activityVC.popoverPresentationController?.sourceView = tableViewCell
                        }
                    }
                    
                    activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                        if let activityType = activityType {
                            Globals.recordAnalyticsEvent(eventType: AnalyticsEventShare, attributes: ["activity_type":activityType.rawValue, "content_type":"csv_event","item_id":eventKey])
                        }
                        
                        if let error = error {
                            CLSNSLogv("Activity share of csv export failed with error: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                    
                    onCompletion(true)
                    self.present(activityVC, animated: true, completion: nil)
                    Globals.recordAnalyticsEvent(eventType: "export_event_to_csv", attributes: ["event":eventKey, "successful":"true"])
                }
            }
        }
        
        DispatchQueue.main.async {
            let filename = "\(eventKey).csv"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            
            let stats = StatisticsDataSource().getStats(forType: ScoutedTeam.self)
            
            var csvText = ""
            //First add in the header for the team number
            csvText += "Team Number,"
            
            //First add in the header row of all stat names
            for (index, stat) in stats.enumerated() {
                csvText += stat.name
                
                if index == stats.count - 1 {
                    //End index
                    csvText += "\n"
                } else {
                    csvText += ","
                }
            }
            
            //Now for all the stat values
            //Get the scouted teams
            let queue = DispatchQueue.global(qos: .utility)
            Globals.appDelegate.appSyncClient?.fetch(query: GetEventRankingQuery(key: eventKey), cachePolicy: .returnCacheDataElseFetch, queue: queue, resultHandler: { (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "GetEventRanking-CSVExport", result: result, error: error) {
                    let eventRanking = result?.data?.getEventRanking?.fragments.eventRanking
                    
                    //Get the scouted teams
                    Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataElseFetch, queue: queue, resultHandler: { (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-CSVExport", result: result, error: error) {
                            let scoutedTeams = result?.data?.listScoutedTeams?.map({$0!.fragments.scoutedTeam}) ?? []
                            
                            //Order the teams
                            let orderedScoutedTeams = scoutedTeams.sorted(by: { (sTeam1, sTeam2) -> Bool in
                                let index1 = eventRanking?.rankedTeams?.firstIndex(where: {$0?.teamKey == sTeam1.teamKey}) ?? 0
                                let index2 = eventRanking?.rankedTeams?.firstIndex(where: {$0?.teamKey == sTeam2.teamKey}) ?? 0
                                
                                return index1 < index2
                            })
                            
                            //Teams are ordered, now calculate the stats
                            for scoutedTeam in orderedScoutedTeams {
                                //First put the team number
                                csvText += scoutedTeam.teamKey.trimmingCharacters(in: CharacterSet.letters) + ","
                                
                                for (index, stat) in stats.enumerated() {
                                    let group = DispatchGroup()
                                    var groupHasBeenLeft = false
                                    group.enter()
                                    stat.calculate(forObject: scoutedTeam, callback: { (value) in
                                        if !groupHasBeenLeft {
                                            csvText += "\(value)"
                                            
                                            if index == stats.count - 1 {
                                                //End index
                                                csvText += "\n"
                                            } else {
                                                csvText += ","
                                            }
                                            
                                            group.leave()
                                            groupHasBeenLeft = true
                                        }
                                    })
                                    
                                    group.wait()
                                }
                            }
                            
                            do {
                                try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
                                
                                finishingActions(path, nil)
                            } catch {
                                finishingActions(nil, error)
                            }
                        } else {
                            finishingActions(nil, CSVExportError.ScoutedTeamsLoadFailed)
                        }
                    })
                } else {
                    //Throw error
                    finishingActions(nil, CSVExportError.RankedTeamLoadFailed)
                }
            })
        }
    }
    
    enum CSVExportError: Error {
        case RankedTeamLoadFailed
        case ScoutedTeamsLoadFailed
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case 0:
            //Matches
            if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                return indexPath
            } else {
                return nil
            }
        default:
            return indexPath
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func advancedPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear Local Cache?", message: "Would you like to clear the local cache of data? This will not delete any of your scouted data, simply clear out the local cache of it. This will cause longer loading times initially as data is re-downloaded and cached again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear Cache", style: .destructive, handler: { (action) in
            Globals.appDelegate.appSyncClient?.clearCache()
            CLSNSLogv("Cleared AppSync Cache", getVaList([]))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
    }
}
