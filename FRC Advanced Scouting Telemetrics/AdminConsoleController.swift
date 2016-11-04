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
    
    let dataManager = TeamDataManager()
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (indexPath as NSIndexPath).row == 0 {
            cell?.textLabel?.text = "Matches"
            cell?.detailTextLabel?.text = "Add, Edit, and Configure Matches"
        } else if (indexPath as NSIndexPath).row == 1 {
			cell?.textLabel?.text = "Regionals"
			cell?.detailTextLabel!.text = "Add, Edit, and Configure Regionals"
		}
		
        return cell!
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
        
        if segue.identifier == "pushToConfigure" {
            let configureVC = segue.destination as! AdminConfigureVC
            configureVC.previousViewController = self
            
            //Set the setting being configured
            switch (tableView.indexPathForSelectedRow! as NSIndexPath).row {
            case 0:
                configureVC.configureSetting = .matches
            case 1:
				configureVC.configureSetting = .regionals
            default:
                configureVC.configureSetting = .unknown
            }
        }
    }
}
