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
    @IBOutlet weak var newStatTypeField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
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
            cell?.textLabel?.text = "Statistics"
            cell?.detailTextLabel!.text = "Add and Remove Statistic Types"
        }
        
        return cell!
    }
    
    @IBAction func addStatTypePressed(sender: AnyObject) {
        if let text = newStatTypeField.text {
            do {
                try dataManager.createNewStatType("\(text)")
            } catch {
                NSLog("Unable to create new stat type: \(error)")
            }
            
            let alert = UIAlertController(title: "Stat Type Saved", message: "The statistic type was saved succesfully.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Great", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Text", message: "There is no name for the new stat type. Make sure to enter text into the field.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
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
                configureVC.configureSetting = .Statistics
            default:
                configureVC.configureSetting = .Unknown
            }
        }
    }
}