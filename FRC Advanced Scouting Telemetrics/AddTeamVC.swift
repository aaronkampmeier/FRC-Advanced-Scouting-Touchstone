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
	@IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var teamField: UITextField!
	@IBOutlet weak var addedTeamLabelView: UIView!
	@IBOutlet weak var addedTeamLabel: UILabel!
    let dataManager = TeamDataManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		addedTeamLabelView.hidden = true
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		teamField.becomeFirstResponder()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		//teamField.becomeFirstResponder()
	}
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        //Check if the team already exists
        if dataManager.getTeams(teamField.text!).count == 0 {
            //Check to make sure it is actually a number
            if Int(teamField.text!) == nil {
                //If it is not a number, present an alert
                let myAlert = UIAlertController(title: "Not a Valid Team Number", message: "You entered an invalid number. Try removing any characters that are not base-10 digits.", preferredStyle: .Alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(myAlert, animated: true, completion: nil)
            } else {
                //If it is a number, save the new Team
                let newTeam = dataManager.saveTeamNumber(teamField.text!)
				dataManager.commitChanges()
                
                //Post Notification of a new Team
                NSNotificationCenter.defaultCenter().postNotificationName("New Team", object: self, userInfo: ["New Team Object":newTeam])
				
				//Set up the added team label
				addedTeamLabel.text = "Added Team: \(teamField.text!)"
				addedTeamLabelView.hidden = true
				let snapshot = addedTeamLabel.snapshotViewAfterScreenUpdates(true)
				view.addSubview(snapshot)
				snapshot.center = teamField.center
				snapshot.alpha = 0
				
				//Show the added team label
				UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
					self.teamField.text = ""
					snapshot.alpha = 1
					snapshot.center = self.addedTeamLabel.superview!.center
				}) {completed in
					self.addedTeamLabelView.hidden = false
					snapshot.removeFromSuperview()
				}
            }
        } else {
            //Create an Alert notifying the user that the team already exists
            let myAlert = UIAlertController(title: "Team Exists", message: "A team with this Team Number already esists in the local database.", preferredStyle: .Alert)
            
            //Add the OK button
            myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            //Present the Alert
            presentViewController(myAlert, animated: true, completion: nil)
        }
        
    }
	
	
	@IBAction func textEntryEnterPressed(sender: UITextField) {
		addButtonPressed(sender)
	}
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}