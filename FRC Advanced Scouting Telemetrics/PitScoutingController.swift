//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class PitScoutingController: UIViewController {
    @IBOutlet weak var updateTeamButton: UIButton!
    @IBOutlet weak var driverXpField: UITextField!
    @IBOutlet weak var validTeamSymbol: UIImageView!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
    let dataManager = TeamDataManager()
    
    var acceptableTeam = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTeamButton.layer.cornerRadius = 10
        updateTeamButton.clipsToBounds = true
    }
    
    @IBAction func desiredTeamEdited(sender: UITextField) {
        if let number = teamNumberField.text {
            if dataManager.getTeams(number).count >= 1 {
                acceptableTeam = true
                validTeamSymbol.image = UIImage(named: "CorrectIcon")
            } else {
                acceptableTeam = false
                validTeamSymbol.image = UIImage(named: "IncorrectIcon")
            }
        }
    }
    
    @IBAction func updateTeamPressed(sender: UIButton) {
        
        if acceptableTeam {
            let driverXp = driverXpField.text
            let weight = weightField.text
            let teamNumber = teamNumberField.text
            
            let returnedTeams = dataManager.getTeams(teamNumber!)
            
            for team in returnedTeams {
                
                team.driverExp = Double(driverXp!)!
                team.robotWeight = Double(weight!)!
            }
            
            dataManager.save()
            
            //Present Confirmation Alert
            let alert = UIAlertController(title: "Team Updated", message: "Weight: \(weight) lbs. \n \(driverXp) yrs. \n added to Team \(teamNumber)", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
            
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            //Alert that the team does not exist
            let alert = UIAlertController(title: "Team Doesn't Exist", message: "The team you entered does not exist in the local databse", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}