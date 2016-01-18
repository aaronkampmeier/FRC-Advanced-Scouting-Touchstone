//
//  AddTeamVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AddTeamVC: UIViewController {
    @IBOutlet weak var teamField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    let dataManager = TeamDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Round the button's corners
        addButton.layer.cornerRadius = 10
        addButton.clipsToBounds = true
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        
        if dataManager.getTeams(teamField.text!).count == 0 {
            //Save new Team
            let newTeam = dataManager.saveTeamNumber(teamField.text!)
            
            //Post Notification of a new Team
            NSNotificationCenter.defaultCenter().postNotificationName("New Team", object: self, userInfo: ["New Team Object":newTeam])
            
            //Return back to the Team List view
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            //Create an Alert notifying the user that the team already exists
            let myAlert = UIAlertController(title: "Team Exists", message: "A team with this Team Number already esists in the local database", preferredStyle: .Alert)
            
            //Add the OK button
            myAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            //Present the Alert
            presentViewController(myAlert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}