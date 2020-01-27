//
//  AdminConsoleConfigSections.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/3/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit
import VTAcknowledgementsViewController
import Firebase
import AWSAppSync
import AWSMobileClient
import Combine

//MARK: - Info Section
struct AdminConsoleInfoSection: AdminConsoleConfigSection {
    var reloadConfigSection: Self.AdminConsoleUpdateConfigSectionHandler?
    
    func sectionTitle(_ adminConsole: AdminConsoleController) -> String? {
        return nil
    }
    
    func numOfRows(_ adminConsole: AdminConsoleController) -> Int {
        return 4
    }
    
    func tableView(_ adminConsole: AdminConsoleController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "about")!
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "acknowledgments")!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo")!
            
            cell.textLabel?.text = "Current User: \(Globals.dataManager.userClaims?.name ?? Globals.dataManager.userClaims?.email ?? Globals.dataManager.userSub ?? "Unknown")"
            cell.detailTextLabel?.text = Globals.dataManager.userClaims?.primaryIdentity?.providerType
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logout")!
            
            if Globals.isInSpectatorMode {
                (cell.viewWithTag(1) as! UILabel).text = "Exit Spectator Mode"
            } else {
                (cell.viewWithTag(1) as! UILabel).text = "Log Out"
            }
            
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "about")!
        }
    }
    
    func onSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            adminConsole.performSegue(withIdentifier: "about", sender: self)
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
                
                adminConsole.navigationController?.pushViewController(ackVC, animated: true)
                Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"admin_console_screen","item_id":"acknowledgements"])
            } else {
                assertionFailure()
            }
        } else if indexPath.row == 2 {
            adminConsole.tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.row == 3 {
            //Logout
            if Globals.isInSpectatorMode {
                Globals.recordAnalyticsEvent(eventType: "exit_spectator_mode")
            } else {
                
            }
            
            //Logout and show onboarding
            Globals.dataManager.signOut()
            
            UserDefaults.standard.setValue(false, forKey: Globals.isSpectatorModeKey)
        }
    }
}

//MARK: - Scouting Teams
/// Config section to manage scouting teams
class AdminConsoleScoutingTeamSection: AdminConsoleConfigSection {
    
    var reloadConfigSection: AdminConsoleUpdateConfigSectionHandler?
    
    var scoutingTeams = [ScoutingTeam]()
    var scoutingTeamWatcher: GraphQLQueryWatcher<ListEnrolledScoutingTeamsQuery>?
    var adminConsole: AdminConsoleController?
    
    init() {
        scoutingTeamWatcher = Globals.appSyncClient?.watch(query: ListEnrolledScoutingTeamsQuery(), cachePolicy: .returnCacheDataAndFetch, queue: DispatchQueue.global(qos: .userInteractive), resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "AdminConsole-ListEnrolledScoutingTeams", result: result, error: error) {
                self?.scoutingTeams = result?.data?.listEnrolledScoutingTeams?.map {$0!.fragments.scoutingTeam} ?? []
                self?.reloadConfigSection?(nil)
            }
        })
    }
    
    func registerUpdateFunction(dataChanged: @escaping (Int?) -> Void) {
        self.reloadConfigSection = dataChanged
    }
    
    func sectionTitle(_ adminConsole: AdminConsoleController) -> String? {
        "Scouting Teams"
    }
    
    func sectionFooter(_ adminConsole: AdminConsoleController) -> String? {
        return "Scouting teams allow you to share scouted data with all the members on your FRC team. Create a new one if you are the first person on your team to use FAST. Otherwise, join an existing scouting team."
    }
    
    func numOfRows(_ adminConsole: AdminConsoleController) -> Int {
        self.adminConsole = adminConsole
        return scoutingTeams.count + 1
    }
    
    func tableView(_ adminConsole: AdminConsoleController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < scoutingTeams.count {
            //Scouting Team Row
            let scoutTeam = scoutingTeams[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "scoutingTeam")!
            
            if scoutTeam.teamLead == Globals.dataManager.userSub {
                cell.detailTextLabel?.text = "Team Lead"
                cell.detailTextLabel?.textColor = .systemGreen
            } else {
                cell.detailTextLabel?.text = "Member"
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .secondaryLabel
                } else {
                    cell.detailTextLabel?.textColor = .lightText
                }
            }
            
            if Globals.dataManager.enrolledScoutingTeamID == scoutTeam.teamId {
                cell.textLabel?.text = "Currently Scouting: \(scoutTeam.name)"
                cell.textLabel?.textColor = .systemBlue
            } else {
                cell.textLabel?.text = scoutTeam.name
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    cell.textLabel?.textColor = .darkText
                }
            }
            return cell
        } else if indexPath.row == scoutingTeams.count {
            //The last row, so show a dialog to add or enroll in a scout team
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "addScoutingTeam")!
            
            //Add
            let addView = cell.contentView.viewWithTag(1)
            addView?.layer.cornerRadius = 8
            let addImageView = cell.contentView.viewWithTag(2) as! UIImageView
            if #available(iOS 13.0, *) {
                addImageView.image = UIImage(systemName: "plus")
            } else {
                // Fallback on earlier versions
                addImageView.image = UIImage(named: "Plus White")
            }
            addImageView.tintColor = .white
            
            //Join
            let joinView = cell.contentView.viewWithTag(4)
            joinView?.layer.cornerRadius = 8
            let joinImageView = cell.contentView.viewWithTag(5) as! UIImageView
            if #available(iOS 13.0, *) {
                joinImageView.image = UIImage(systemName: "magnifyingglass")
            } else {
                joinImageView.image = UIImage(named: "Search")
            }
            joinImageView.tintColor = .white
            
            //Add touch responder
            let addButton = cell.contentView.viewWithTag(3) as! UIButton
            addButton.addTarget(self, action: #selector(createScoutingTeam(_:)), for: .touchUpInside)
            let joinButton = cell.contentView.viewWithTag(6) as! UIButton
            joinButton.addTarget(self, action: #selector(joinScoutingTeam(_:)), for: .touchUpInside)
            
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func createScoutingTeam(_ sender: UIButton) {
        let createVC = adminConsole?.storyboard?.instantiateViewController(withIdentifier: "createScoutingTeam") as! CreateScoutingTeamTableViewController
        
        adminConsole?.present(UINavigationController(rootViewController: createVC), animated: true, completion: nil)
    }
    
    @objc func joinScoutingTeam(_ sender: UIButton) {
        let joinVC = adminConsole?.storyboard?.instantiateViewController(withIdentifier: "joinScoutingTeam") as! JoinScoutingTeamTableViewController
        
        adminConsole?.present(UINavigationController(rootViewController: joinVC), animated: true, completion: nil)
    }
    
    func height(_ adminConsole: AdminConsoleController, tableView: UITableView, forRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == scoutingTeams.count {
            return 110
        } else {
            return tableView.rowHeight
        }
    }
    
    func onSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) {
        if indexPath.row < scoutingTeams.count {
            let scoutingTeamInfoVC = adminConsole.storyboard?.instantiateViewController(withIdentifier: "scoutingTeamInfo") as! ScoutingTeamTableViewController
            scoutingTeamInfoVC.loadData(forId: scoutingTeams[indexPath.row].teamId)
            adminConsole.show(scoutingTeamInfoVC, sender: self)
        }
    }
    
    func willSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row < scoutingTeams.count {
            return indexPath
        } else {
            return nil
        }
    }
}

//MARK: - Events
class AdminConsoleEventsSection: AdminConsoleConfigSection {
    var trackedEvents: [ListTrackedEventsQuery.Data.ListTrackedEvent] = []
    var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    
    var reloadConfigSection: ((_ row: Int?) -> Void)?
    
    init() {
        loadData()
        
        NotificationCenter.default.addObserver(forName: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            self?.loadData()
        }
    }
    deinit {
        trackedEventsWatcher?.cancel()
    }
    
    func loadData() {
        //Get the tracked events
        trackedEventsWatcher?.cancel()
        if let scoutTeamId = Globals.dataManager.enrolledScoutingTeamID {
            trackedEventsWatcher = Globals.appSyncClient?.watch(query: ListTrackedEventsQuery(scoutTeam: scoutTeamId), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery-AdminConsole", result: result, error: error) {
                    self?.trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
                    self?.reloadConfigSection?(nil)
                } else {
                    
                }
            })
        }
    }
    
    func registerUpdateFunction(dataChanged: @escaping (_ row: Int?) -> Void) {
        self.reloadConfigSection = dataChanged
    }
    
    func sectionTitle(_ adminConsole: AdminConsoleController) -> String? {
        return "Events"
    }
    
    func sectionFooter(_ adminConsole: AdminConsoleController) -> String? {
        return "Swipe left on an event to export the data to CSV or delete it altogether"
    }
    
    func numOfRows(_ adminConsole: AdminConsoleController) -> Int {
        return trackedEvents.count + 1
    }
    
    func tableView(_ adminConsole: AdminConsoleController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Events
        if indexPath.row == numOfRows(adminConsole) - 1 {
            //Return the add event cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "addEvent")!
            let plusIcon = cell.contentView.viewWithTag(1) as! UIImageView
            let addText = cell.contentView.viewWithTag(2) as! UILabel
            
            if #available(iOS 13.0, *) {
                plusIcon.image = UIImage(systemName: "plus")
            }
            
            if Globals.dataManager.enrolledScoutingTeamID == nil {
                plusIcon.tintColor = .systemGray
                addText.textColor = .systemGray
            } else {
                plusIcon.tintColor = .systemBlue
                addText.tintColor = .systemBlue
            }
            
            return cell
        } else {
            //Return the event cell with event name and type
            let cell = tableView.dequeueReusableCell(withIdentifier: "event")!
            cell.textLabel?.text = "\(trackedEvents[indexPath.row].eventName) (\(trackedEvents[indexPath.row].eventKey.trimmingCharacters(in: CharacterSet.letters)))"
            cell.detailTextLabel?.text = trackedEvents[indexPath.row].eventKey
            //                cell.detailTextLabel?.text = events[indexPath.row].location
            return cell
        }
    }
    
    func onSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) {
        if indexPath.row == numOfRows(adminConsole) - 1 {
            //Did select add event
            if Globals.dataManager.enrolledScoutingTeamID != nil {
                let addEventVC = adminConsole.storyboard?.instantiateViewController(withIdentifier: "addEvent")
                
                adminConsole.present(UINavigationController(rootViewController: addEventVC!), animated: true, completion: nil)
            }
        } else {
            //Did select event info
            // TODO: Display event info
        }
    }
    
    func trailingSwipeActionsConfigiration(_ adminConsole: AdminConsoleController, forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == self.numOfRows(adminConsole) - 1 {
            return nil
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] action, view, completionHandler in
                //Ask for reassurance first
                let confirmationAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete \(self?.trackedEvents[indexPath.row].eventName ?? "") (\(self?.trackedEvents[indexPath.row].eventKey ?? ""))", preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "Yes, Delete It", style: .destructive, handler: { (action) in
                    self?.deleteAt(indexPath: indexPath, forAdminConsole: adminConsole)
                    completionHandler(true)
                }))
                confirmationAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                adminConsole.present(confirmationAlert, animated: true, completion: nil)
            }
            
            let reloadAction = UIContextualAction(style: .normal, title: "Reload") {[weak self] action, view, completionHandler in
                self?.reloadAt(indexPath: indexPath, forAdminConsole: adminConsole)
                completionHandler(true)
            }
            reloadAction.backgroundColor = .blue
            
            let exportToCSVAction = UIContextualAction(style: .normal, title: "CSV Export") {[unowned adminConsole, weak self] action, view, completionHandler in
                let sourceView: UIView
                if let cell = adminConsole.tableView.cellForRow(at: indexPath) {
                    sourceView = cell
                } else {
                    sourceView = adminConsole.tableView
                }
                
                self?.exportToCSV(eventKey: (self?.trackedEvents[indexPath.row].eventKey)!, withSourceView: sourceView, onAdminConsole: adminConsole) {successful in
                    completionHandler(true)
                }
            }
            exportToCSVAction.backgroundColor = .purple
            
            return UISwipeActionsConfiguration(actions: [reloadAction, exportToCSVAction, deleteAction])
        }
    }
    
    func willSelect(_ adminConsole: AdminConsoleController, rowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == numOfRows(adminConsole) - 1 {
            if let _ = Globals.dataManager.enrolledScoutingTeamID {
                return indexPath
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func reloadAt(indexPath: IndexPath, forAdminConsole adminConsole: AdminConsoleController, withCompletionHandler onCompletion: (() -> Void)? = nil) {
        let event = self.trackedEvents[indexPath.row]
        adminConsole.showLoadingIndicator()
        
        //Call to reload the event
        Globals.appSyncClient?.perform(mutation: AddTrackedEventMutation(scoutTeam: Globals.dataManager.enrolledScoutingTeamID ?? "", eventKey: event.eventKey), conflictResolutionBlock: { (snapshot, taskCompletionSource, result) in
            
        }, resultHandler: {[weak adminConsole] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ReloadTrackedEvent-AdminConsole", result: result, error: error) {
                adminConsole?.removeLoadingIndicator()
                onCompletion?()
            } else {
                
            }
        })
    }
    
    func deleteAt(indexPath: IndexPath, forAdminConsole adminConsole: AdminConsoleController) {
        //Call to remove the event
        let trackedEvent = trackedEvents[indexPath.row]
        Globals.appSyncClient?.perform(mutation: RemoveTrackedEventMutation(scoutTeam: Globals.dataManager.enrolledScoutingTeamID ?? "", eventKey: trackedEvent.eventKey), optimisticUpdate: { (transaction) in
            do {
                try transaction?.update(query: ListTrackedEventsQuery(scoutTeam: Globals.dataManager.enrolledScoutingTeamID ?? ""), { (data) in
                    if let index = data.listTrackedEvents?.firstIndex(where: {$0?.eventKey == trackedEvent.eventKey}) {
                        data.listTrackedEvents?.remove(at: index)
                    }
                })
            } catch {
                CLSNSLogv("Error performing opitimistic update on RemoveTrackedEvent", getVaList([]))
            }
        }, conflictResolutionBlock: { (snapshot, taskCompletionSource, result) in
            
        }, resultHandler: {[weak adminConsole] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "RemoveTrackedEvent", result: result, error: error) {
                //                tableView.beginUpdates()
                //                tableView.deleteRows(at: [indexPath], with: .left)
                //                tableView.endUpdates()
            } else {
                let alert = UIAlertController(title: "Problem Removing Event", message: "An error occured when removing the event.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                adminConsole?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func exportToCSV(eventKey: String, withSourceView sourceView: UIView?, onAdminConsole adminConsole: AdminConsoleController, onCompletion: @escaping (Bool) -> Void) {
        guard let scoutTeamId = Globals.dataManager.enrolledScoutingTeamID else {
            //TODO: Show error that there is no signed in scout team, not sure how you would get here though
            return
        }
        adminConsole.showLoadingIndicator()
        let perfTrace = Performance.startTrace(name: "CSV Export")
        perfTrace?.setValue(eventKey, forAttribute: "event_key")
        //        perfTrace?.start()
        
        let finishingActions: (URL?, Error?) -> Void = {path, error in
            DispatchQueue.main.async {
                perfTrace?.stop()
                adminConsole.removeLoadingIndicator()
                if let error = error {
                    let alert = UIAlertController(title: "Export Failed", message: "There was an error exporting to CSV: \(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    adminConsole.present(alert, animated: true, completion: nil)
                    
                    onCompletion(false)
                    
                    CLSNSLogv("Failed to write csv text to file: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    
                    Globals.recordAnalyticsEvent(eventType: "export_event_to_csv", attributes: ["event":eventKey, "successful":"false"])
                } else if let path = path {
                    let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: [])
                    
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.saveToCameraRoll]
                    
                    activityVC.popoverPresentationController?.sourceView = sourceView
                    
                    activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                        if let activityType = activityType {
                            Globals.recordAnalyticsEvent(eventType: AnalyticsEventShare, attributes: ["activity_type":activityType.rawValue, "content_type":"csv_event","item_id":eventKey])
                        }
                        
                        if let error = error {
                            CLSNSLogv("Activity share of csv export failed with error: \(error)", getVaList([]))
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    }
                    
                    onCompletion(true)
                    adminConsole.present(activityVC, animated: true, completion: nil)
                    Globals.recordAnalyticsEvent(eventType: "export_event_to_csv", attributes: ["event":eventKey, "successful":"true"])
                }
            }
        }
        
        DispatchQueue.main.async {
            //TODO: Add a timestamp to the filename
            let filename = "\(eventKey).csv"
            let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
            
            let stats = StatisticsDataSource().getStats(forType: ScoutedTeam.self, forEvent: eventKey)
            
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
            Globals.appSyncClient?.fetch(query: GetEventRankingQuery(scoutTeam: scoutTeamId, key: eventKey), cachePolicy: .returnCacheDataElseFetch, queue: queue, resultHandler: { (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "GetEventRanking-CSVExport", result: result, error: error) {
                    let eventRanking = result?.data?.getEventRanking?.fragments.eventRanking
                    
                    //Get the scouted teams
                    Globals.appSyncClient?.fetch(query: ListScoutedTeamsQuery(scoutTeam: scoutTeamId, eventKey: eventKey), cachePolicy: .returnCacheDataElseFetch, queue: queue, resultHandler: { (result, error) in
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
}
