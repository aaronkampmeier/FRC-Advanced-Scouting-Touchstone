//
//  AddStatVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AddStatVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var statTypePicker: UIPickerView!
    let dataManager = TeamDataManager()
    var statTypes: [StatType]?
    var selectedType: StatType?
    var team: Team?
    
    override func viewDidLoad() {
        statTypePicker.delegate = self
        statTypePicker.dataSource = self
        
        do {
            statTypes = try dataManager.getStatTypes()
        } catch {
            NSLog("Could not get stat types: \(error)")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if statTypes!.count > 0 {
            selectedType = statTypes![0]
            return statTypes!.count
        } else {
            //Present an alert that
            presentOkAlert("No Stat Types", descritpion: "There are currently no statistic types. Go to the Admin Console to add some.", okActionHandler: alertActionHandler)
            return 0
        }
    }
    
    func alertActionHandler(alert: UIAlertAction) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statTypes![row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = statTypes![row]
    }
    
    @IBAction func valueDidFinishEntering(sender: UITextField) {
        //Save and close the view
        if let team = self.team {
            if let type = selectedType {
                if let value = Double(sender.text!) {
                    dataManager.addStatToTeam(team, statType: type, statValue: value)
                    NSNotificationCenter.defaultCenter().postNotificationName("New Stat", object: self)
                    dismissViewControllerAnimated(true, completion: nil)
                } else {
                    NSLog("Unable to save new stat")
                    presentOkAlert("Unable to Save", descritpion: "The new stat could not save because the value is not a number. Try removing anything that is not a base-10 number.", okActionHandler: nil)
                }
            } else {
                NSLog("Unable to save new stat")
                presentOkAlert("Unable to Save", descritpion: "The new stat could not save because there is no selected type.", okActionHandler: nil)
            }
        } else {
            NSLog("Unable to save new stat")
            presentOkAlert("Unable to Save", descritpion: "The new stat could not save because the current team was unable to be retrieved.", okActionHandler: nil)
        }
    }
    
    func presentOkAlert(title: String, descritpion: String, okActionHandler: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okActionHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(sender: UIBarButtonItem) {
        valueDidFinishEntering(valueTextField)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}