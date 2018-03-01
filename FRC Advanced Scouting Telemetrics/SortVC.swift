//
//  SortVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

protocol SortDelegate {
	func selectedStat(_ stat: String, isAscending: Bool)
    func statsToDisplay() -> [String]
    func currentStat() -> String
    func isAscending() -> Bool
}

//T is the type to be sorted
class SortVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sortTypePicker: UIPickerView!
    @IBOutlet weak var orderSegementedControl: UISegmentedControl!
	
    var statsToDisplay = [String]()
    fileprivate var selectedStat: String?
	
    fileprivate var isAscending = false
	
	var delegate: SortDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

		sortTypePicker.dataSource = self
        sortTypePicker.delegate = self
		
		statsToDisplay = delegate?.statsToDisplay() ?? []
        selectedStat = delegate?.currentStat()
        sortTypePicker.selectRow(statsToDisplay.index(of: selectedStat!)!, inComponent: 0, animated: false)
        
        if delegate?.isAscending() ?? false {
            orderSegementedControl.selectedSegmentIndex = 1
        } else {
            orderSegementedControl.selectedSegmentIndex = 0
        }
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.selectedStat(selectedStat!, isAscending: isAscending)
        Answers.logCustomEvent(withName: "Sort Team List", customAttributes: ["Stat":selectedStat, "Ascending":isAscending.description])
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		sortTypePicker.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return statsToDisplay.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statsToDisplay[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStat = statsToDisplay[row]
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isAscending = false
        } else if sender.selectedSegmentIndex == 1 {
            isAscending = true
        }
    }
}
