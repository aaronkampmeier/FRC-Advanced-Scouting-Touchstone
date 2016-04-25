//
//  SortVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class SortVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sortTypePicker: UIPickerView!
    @IBOutlet weak var orderSegementedControl: UISegmentedControl!
	
    var selectedStat: Int?
    let dataManager = TeamDataManager()
    var successful = false
	
	var statContext: StatContext?
    var isAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

		sortTypePicker.dataSource = self
        sortTypePicker.delegate = self
        
        orderSegementedControl.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		sortTypePicker.reloadAllComponents()
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (statContext?.possibleStats.count) ?? 0
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
            return statContext?.possibleStats[row-1].description ?? ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedStat = nil
            orderSegementedControl.enabled = false
        } else {
            selectedStat = row - 1
            orderSegementedControl.enabled = true
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
    }
}