//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import VTAcknowledgementsViewController

class AdminConsoleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
	
	var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		events = Array(RealmController.realmController.generalRealm.objects(Event.self))
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
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
			return events.count + 1
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
				cell.textLabel?.text = "\(events[indexPath.row].name) (\(events[indexPath.row].year))"
				cell.detailTextLabel?.text = events[indexPath.row].location
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
                
                let teamNumber: String = UserDefaults.standard.value(forKey: "LoggedInTeam") as? String ?? "?"
                (cell.viewWithTag(1) as! UILabel).text = "Log Out of Team \(teamNumber)"
                
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
			return "Events"
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
				performSegue(withIdentifier: "addEvent", sender: tableView)
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
                    ackVC.headerText = "Some portions of this app run on the following libraries"
                    
                    if let path = Bundle.main.path(forResource: "Additional Licenses", ofType: "plist") {
                        let additionalLicensesDict = NSDictionary(contentsOfFile: path)! as! Dictionary<String, Dictionary<String, String>>
                        
                        let keys = additionalLicensesDict.keys
                        for key in keys {
                            let ack = VTAcknowledgement(title: additionalLicensesDict[key]!["Title"]!, text: additionalLicensesDict[key]!["Text"]!, license: additionalLicensesDict[key]?["License"])
                            
                            ackVC.acknowledgements?.append(ack)
                        }
                    }
                    
                    self.navigationController?.pushViewController(ackVC, animated: true)
                } else {
                    assertionFailure()
                }
            } else if indexPath.row == 2 {
                let loggedInTeam: String = UserDefaults.standard.value(forKey: "LoggedInTeam") as? String ?? "Unknown"
                Answers.logCustomEvent(withName: "Sign Out", customAttributes: ["Team":loggedInTeam])
                
                //Remove user default
                UserDefaults.standard.setValue(nil, forKeyPath: "LoggedInTeam")
                
                //Logout button pressed
                RealmController.realmController.currentSyncUser?.logOut()
                RealmController.realmController.currentSyncUser = nil
                
                //Now return to the log in screen
                (UIApplication.shared.delegate as! AppDelegate).displayLogin()
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
                let reloadAction = UITableViewRowAction.init(style: .normal, title: "Reload") {(rowAction, indexPath) in
                    //Create a loading view
                    let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
                    let grayView = UIView(frame: CGRect(x: self.tableView.frame.width / 2 - 50, y: self.tableView.frame.height / 2 - 50, width: 120, height: 120))
                    grayView.backgroundColor = UIColor.lightGray
                    grayView.backgroundColor?.withAlphaComponent(0.7)
                    grayView.layer.cornerRadius = 10
                    spinnerView.frame = CGRect(x: grayView.frame.width / 2 - 25, y: grayView.frame.height / 2 - 25, width: 50, height: 50)
                    grayView.addSubview(spinnerView)
                    spinnerView.startAnimating()
                    self.tableView.addSubview(grayView)
                    
                    //Prevent user interaction
                    self.view.isUserInteractionEnabled = false
                    self.navigationController?.navigationBar.isUserInteractionEnabled = false
                    
                    CloudReloadingManager(eventToReload: self.events[indexPath.row]) {successful in
                        //Return user interaction
                        self.view.isUserInteractionEnabled = true
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        
                        grayView.removeFromSuperview()
                        
                        self.events = Array(RealmController.realmController.generalRealm.objects(Event.self))
                        tableView.reloadData()
                    }
                        .reload()
                }
                reloadAction.backgroundColor = UIColor.blue
                
                let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") {(rowAction, indexPath) in
                    //Remove the event
                    let removalManager = CloudEventRemovalManager(eventToRemove: self.events[indexPath.row]) {finished in
                        if !finished {
                            let alert = UIAlertController(title: "Problem Removing Event", message: "An error occured when removing the event.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            tableView.beginUpdates()
                            tableView.deleteRows(at: [indexPath], with: .left)
                            self.events.remove(at: indexPath.row)
                            tableView.endUpdates()
                        }
                        
                        tableView.reloadData()
                    }
                    removalManager.remove()
                }
                
                
                return [delete, reloadAction]
            }
        default:
            return nil
        }
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
    
    @IBAction func rewindToAdminConsole(withSegue segue: UIStoryboardSegue) {
        if segue.identifier == "unwindToAdminConsoleFromEventAdd" {
            events = Array(RealmController.realmController.generalRealm.objects(Event.self))
            tableView.reloadData()
        }
        
        viewWillAppear(true)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func advancedPressed(_ sender: UIBarButtonItem) {
//        let advancedController = storyboard?.instantiateViewController(withIdentifier: "advancedControl") as! HiddenDebugViewController
//        present(advancedController, animated: true, completion: nil)
    }
}
