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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Matches"
            cell?.detailTextLabel?.text = "Add, Edit, and Configure Matches"
        } else if indexPath.row == 1 {
			cell?.textLabel?.text = "Regionals"
			cell?.detailTextLabel!.text = "Add, Edit, and Configure Regionals"
		}
		
        return cell!
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
		dataManager.commitChanges()
        dismissViewControllerAnimated(true, completion: nil)
    }
	
	@IBAction func cancelPressed(sender: UIBarButtonItem) {
		dataManager.discardChanges()
		dismissViewControllerAnimated(true, completion: nil)
	}
    
    func comingBackFromConfigure() {
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "pushToConfigure" {
            let configureVC = segue.destinationViewController as! AdminConfigureVC
            configureVC.previousViewController = self
            
            //Set the setting being configured
            switch tableView.indexPathForSelectedRow!.row {
            case 0:
                configureVC.configureSetting = .Matches
            case 1:
				configureVC.configureSetting = .Regionals
            default:
                configureVC.configureSetting = .Unknown
            }
        }
    }
}