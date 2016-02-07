//
//  StatTypePickerData.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class StatTypePickerData: UIViewController, UIPickerViewDataSource {
    var statTypes: [StatType]?
    let dataManager = TeamDataManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        do {
            statTypes = try dataManager.getStatTypes()
        } catch {
            NSLog("Could not get stat types: \(error)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        NSLog("Entering picker view numOfRows")
        if statTypes!.count > 0 {
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statTypes![row].name
    }
    
    func presentOkAlert(title: String, descritpion: String, okActionHandler: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okActionHandler))
        presentViewController(alert, animated: true, completion: nil)
    }
}