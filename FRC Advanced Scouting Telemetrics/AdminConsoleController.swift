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
	@IBOutlet weak var navigationBar: UINavigationItem!
    
    let dataManager = DataManager()
	
	var events = [Event]()
    
    override func viewDidLoad() {
		events = dataManager.getEvents()
	}
	
	enum adminConsoleSections: Int {
		case Events
		case About
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
				cell.detailTextLabel?.text = "\(events[indexPath.row].eventTypeString ?? "")"
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
        default:
            break
		}
	}
	
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
		dataManager.commitChanges()
        dismiss(animated: true, completion: nil)
    }
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dataManager.discardChanges()
		dismiss(animated: true, completion: nil)
	}
    
    func comingBackFromConfigure() {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
    }
}
