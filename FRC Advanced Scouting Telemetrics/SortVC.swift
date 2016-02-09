//
//  SortVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class SortVC: UIViewController, UIPickerViewDelegate {
    @IBOutlet weak var sortTypePicker: UIPickerView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var statTypes: [StatType]?
    var selectedType: StatType?
    let dataManager = TeamDataManager()
    var successful = false
    var currentSortType: StatType?
    
    var isAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortTypePicker.dataSource = StatTypePickerData()
        sortTypePicker.delegate = self
        
        segmentControl.enabled = false
        
        do {
            statTypes = try dataManager.getStatTypes()
        } catch {
            NSLog("Could not get stat types: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get the index of the current stat type for sorting
        let row: Int?
        if let type = currentSortType {
            row = (statTypes?.indexOf(type))! + 1
        } else {
            row = 0
        }
        
        //Set that index in the picker view
        sortTypePicker.selectRow(row!, inComponent: 0, animated: false)
        self.pickerView(sortTypePicker, didSelectRow: row!, inComponent: 0)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        NSLog("Entering picker view numOfRows")
        if statTypes!.count > 0 {
            successful = true
            selectedType = nil
            return statTypes!.count + 1
        } else {
            //Present an alert
            presentOkAlert("No Stat Types", descritpion: "There are currently no statistic types. Go to the Admin Console to add some.", okActionHandler: alertActionHandler)
            return 0
        }
    }
    
    func alertActionHandler(alert: UIAlertAction) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Draft Board (Default)"
        } else {
            return statTypes![row-1].name
        }
    }
    
    func presentOkAlert(title: String, descritpion: String, okActionHandler: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okActionHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedType = nil
            segmentControl.enabled = false
        } else {
            selectedType = statTypes![row-1]
            segmentControl.enabled = true
        }
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isAscending = true
        } else if sender.selectedSegmentIndex == 1 {
            isAscending = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if successful && selectedType != nil {
            //Sort the team list
            NSNotificationCenter.defaultCenter().postNotificationName("New Sort Type", object: self, userInfo: ["SortType":selectedType!, "Ascending":isAscending, "DraftBoardDefault":false])
        } else if successful && selectedType == nil {
            //If the default is slected then send the noftication to undo the sorting
            NSNotificationCenter.defaultCenter().postNotificationName("New Sort Type", object: self, userInfo: ["DraftBoardDefault":true])
        }
    }
}