//
//  EventSelectorTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 7/19/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSAppSync

extension Notification.Name {
    static let FASTSelectedEventChanged = Notification.Name("FASTSelectedEventChanged")
}

class EventSelectorTableViewController: UITableViewController {
    
    fileprivate var events: [(eventKey: String, eventName: String)] = []
    fileprivate var currentEvent: String?
    
    private var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Load all the events
        if let scoutTeamId = Globals.dataManager.enrolledScoutingTeamID {
            trackedEventsWatcher = Globals.appSyncClient?.watch(query: ListTrackedEventsQuery(scoutTeam: scoutTeamId), cachePolicy: .returnCacheDataElseFetch, queue: DispatchQueue.global(qos: .userInteractive)) {[weak self] result, error in
                DispatchQueue.main.async {
                    if Globals.handleAppSyncErrors(forQuery: "ListTrackedEventsQuery", result: result, error: error) {
                        self?.events = result?.data?.listTrackedEvents?.map {(eventKey: $0!.eventKey, eventName: $0!.eventName)} ?? []
                        self?.tableView.reloadData()
                        //Transition the view to the proper size
                        //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        //                        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                        //                            let newFrame = CGRect(x: self?.tableView.frame.origin.x ?? .zero, y: self?.tableView.frame.origin.y ?? .zero, width: self?.tableView.frame.width ?? .zero, height: self?.tableView.contentSize.height ?? .zero)
                        //                            self?.tableView.frame = newFrame
                        //                        }) { (completed) in
                        //                            self?.tableView.invalidateIntrinsicContentSize()
                        //                        }
                        //                    }
                    } else {
                        
                    }
                }
            }
        } else {
            //TODO: Show error message in table view background that there is no enrolled scout team
        }
    }
    
    deinit {
        trackedEventsWatcher?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Globals.appDelegate.supportedInterfaceOrientations = .portrait
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Globals.appDelegate.supportedInterfaceOrientations = .all
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != events.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let eventInfo = events[indexPath.row]
            cell.textLabel?.text = eventInfo.eventName
            cell.detailTextLabel?.text = eventInfo.eventKey.trimmingCharacters(in: CharacterSet.letters)
            
            return cell
        } else {
            //Add Event Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "add", for: indexPath)
            
            if #available(iOS 13.0, *) {
                cell.accessoryView = UIImageView(image: UIImage(systemName: "plus.circle"))
            } else {
                // Fallback on earlier versions
                cell.accessoryView = UIImageView(image: UIImage(named: "Plus Math Filled-100"))
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == events.count {
            //Show the add event view
            if let _ = Globals.dataManager.enrolledScoutingTeamID {
                let addEventVC = storyboard?.instantiateViewController(withIdentifier: "addEvent")
                
                self.present(UINavigationController(rootViewController: addEventVC!), animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "No Scouting Team", message: "Please create or join a scouting team in the admin console before adding an event.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Go to the Admin Console", style: .default, handler: { (action) in
//
//                }))
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            var userInfo: [String : Any] = ["eventKey":events[indexPath.row].eventKey]
            if #available(iOS 13.0, *) {
                userInfo["sceneId"] = view.window?.windowScene?.session.persistentIdentifier
            }
            NotificationCenter.default.post(name: .FASTSelectedEventChanged, object: self, userInfo: userInfo)
            self.dismiss(animated: true, completion: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
