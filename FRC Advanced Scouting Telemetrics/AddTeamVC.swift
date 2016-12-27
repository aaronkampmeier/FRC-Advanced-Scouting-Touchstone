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
    let dataManager = DataManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		addedTeamLabelView.isHidden = true
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		teamField.becomeFirstResponder()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//teamField.becomeFirstResponder()
	}
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
		/*
        //Check if the team already exists
        if dataManager.getTeams(teamField.text!).count == 0 {
            //Check to make sure it is actually a number
            if Int(teamField.text!) == nil {
                //If it is not a number, present an alert
                let myAlert = UIAlertController(title: "Not a Valid Team Number", message: "You entered an invalid number. Try removing any characters that are not base-10 digits.", preferredStyle: .alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(myAlert, animated: true, completion: nil)
            } else {
                //If it is a number, save the new Team
				let newTeam = dataManager.saveTeamNumber(teamField.text!, performCommit: true)
                
                //Post Notification of a new Team
                NotificationCenter.default.post(name: Notification.Name(rawValue: "New Team"), object: self, userInfo: ["New Team Object":newTeam])
				
				//Set up the added team label
				addedTeamLabel.text = "Added Team: \(teamField.text!)"
				addedTeamLabelView.isHidden = true
				let snapshot = addedTeamLabel.snapshotView(afterScreenUpdates: true)
				view.addSubview(snapshot!)
				snapshot?.center = teamField.center
				snapshot?.alpha = 0
				
				//Show the added team label
				UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(), animations: {
					self.teamField.text = ""
					snapshot?.alpha = 1
					snapshot?.center = self.addedTeamLabel.superview!.center
				}) {completed in
					self.addedTeamLabelView.isHidden = false
					snapshot?.removeFromSuperview()
				}
            }
        } else {
            //Create an Alert notifying the user that the team already exists
            let myAlert = UIAlertController(title: "Team Exists", message: "A team with this Team Number already esists in the local database.", preferredStyle: .alert)
            
            //Add the OK button
            myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            //Present the Alert
            present(myAlert, animated: true, completion: nil)
        }
*/
        
    }
	
	
	@IBAction func textEntryEnterPressed(_ sender: UITextField) {
		addButtonPressed(sender)
	}
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
