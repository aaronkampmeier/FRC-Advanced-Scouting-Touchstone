//
//  EventInfoVCViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 12/27/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSMobileClient

class EventInfoVC: UIViewController, UITableViewDataSource {
    var selectedEvent: Event?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventShortName: UILabel!
    @IBOutlet weak var eventType: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
        eventShortName.text = selectedEvent?.name
        eventType.text = selectedEvent?.eventTypeString
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        guard let scoutTeamId = Globals.dataManager.enrolledScoutingTeamID else {
            let alert = UIAlertController(title: "Error: No Scouting Team", message: "You are currently not associated with any scouting teams. Please join or create one before trying to scout data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        //Check if we are using syncing
        if Globals.isInSpectatorMode {
            assertionFailure()
        } else {
            if let eventKey = selectedEvent?.key {
                if #available(iOS 13.0, *) {
                    self.isModalInPresentation = true
                }
                
                self.activityIndicator.startAnimating()
                self.loadingView.isHidden = false
                
                //Add the event to be tracked
                Globals.appSyncClient?.perform(mutation: AddTrackedEventMutation(scoutTeam: scoutTeamId, eventKey: eventKey), resultHandler: {[weak self] (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "AddTrackedEventMutation", result: result, error: error) {
                        //Import finished, update the cache and dismiss this view
                        self?.loadingView.isHidden = true
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                        
                        if let newEvent = result?.data?.addTrackedEvent {
                            let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Bool in
                                do {
                                    try transaction.update(query: ListTrackedEventsQuery(scoutTeam: scoutTeamId)) { (selectionSet) in
                                        selectionSet.listTrackedEvents?.append(try ListTrackedEventsQuery.Data.ListTrackedEvent(newEvent))
                                    }
                                    return true
                                } catch {
                                    return false
                                }
                            })
                        }
                        
                        Globals.recordAnalyticsEvent(eventType: "attempted_event_import", attributes: ["successful":true.description])
                    } else {
                        Globals.recordAnalyticsEvent(eventType: "attempted_event_import", attributes: ["successful":false.description])
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = selectedEvent?.website {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //Year cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameValue")
            
            let keyLabel = cell?.viewWithTag(1) as! UILabel
            keyLabel.text = "Year"
            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = keyLabel.intrinsicContentSize.width
            
            (cell?.viewWithTag(2) as! UILabel).text = selectedEvent?.year.description
            
            return cell!
        case 1:
            //Address
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameValue")
            
            let keyLabel = cell?.viewWithTag(1) as! UILabel
            keyLabel.text = "Address"
            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = keyLabel.intrinsicContentSize.width
            
            (cell?.viewWithTag(2) as! UILabel).text = selectedEvent?.address
            
            return cell!
        case 2:
            //Official FIRST FMS
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameValue")
            
            let keyLabel = cell?.viewWithTag(1) as! UILabel
            keyLabel.text = "Location"
            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = keyLabel.intrinsicContentSize.width
            (cell?.viewWithTag(2) as! UILabel).text = selectedEvent?.locationName ?? "Unkown"
            //TODO: Find another way to describe if it is official or not
//            let keyLabel = cell?.viewWithTag(1) as! UILabel
//            keyLabel.text = "Uses Official FIRST FMS"
//            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = keyLabel.intrinsicContentSize.width
//
//            (cell?.viewWithTag(2) as! UILabel).text = selectedEvent?.official.description.capitalized
            
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "websiteButton")
            
            (cell?.viewWithTag(1) as! UIButton).addTarget(self, action: #selector(websiteButtonPressed(_:)), for: .touchUpInside)
            
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    @objc func websiteButtonPressed(_ sender: UIButton) {
        if let url = URL(string: selectedEvent?.website ?? "") {
            UIApplication.shared.openURL(url)
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
