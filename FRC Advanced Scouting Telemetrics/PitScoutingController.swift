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
        //let driverXp = driverXpField.
        //dataManager.saveTeamNumber(<#T##number: String##String#>)
    }
    
}