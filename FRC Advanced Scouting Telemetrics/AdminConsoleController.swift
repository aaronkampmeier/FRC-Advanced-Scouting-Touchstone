//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AdminConsoleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager = DataManager()
	
	var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		events = dataManager.getEvents()
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
			return 1
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
				cell.textLabel?.text = "\(events[indexPath.row].name ?? "")"
				cell.detailTextLabel?.text = "\(events[indexPath.row].location)"
				return cell
			}
		case tableView.numberOfSections - 1:
			//About Section
			return tableView.dequeueReusableCell(withIdentifier: "about")!
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
            performSegue(withIdentifier: "about", sender: self)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            switch indexPath.section {
            case 0:
                //Events
                if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
                    
                } else {
                    //Remove the event
                    let removalManager = CloudEventRemovalManager(eventToRemove: events[indexPath.row]) {finished in
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
                    }
                    removalManager.remove()
                }
            default:
                break
            }
        default:
            break
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
            events = dataManager.events()
            tableView.reloadData()
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dataManager.commitChanges()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}
