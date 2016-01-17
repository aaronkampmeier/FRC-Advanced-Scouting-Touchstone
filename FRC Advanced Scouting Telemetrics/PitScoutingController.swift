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
    @IBOutlet weak var driverXpField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var teamNumberField: UITextField!
    let dataManager = TeamDataManager()
    
    @IBAction func addTeamPressed(sender: UIButton) {
        
        let driverXp = driverXpField.text
        let weight = weightField.text
        let teamNumber = teamNumberField.text
        
        let returnedTeams = dataManager.getTeams(teamNumber!)
        
        for team in returnedTeams {
            
            team.driverExp = Double(driverXp!)!
            team.robotWeight = Double(weight!)!
        }
        
        if returnedTeams.count == 0 {
            //Present Alert
        }
    }
    
}