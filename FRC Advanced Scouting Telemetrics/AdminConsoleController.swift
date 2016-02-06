//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AdminConsoleController: UIViewController {
    @IBOutlet weak var newStatTypeField: UITextField!
    
    let dataManager = TeamDataManager()
    
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
}