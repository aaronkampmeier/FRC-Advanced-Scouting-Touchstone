//
//  SortVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

protocol SortDelegate {
	func selectedStat(_ stat: Int?, isAscending: Bool)
	
	///Returns an array of all the stats that can be sorted by. Automatically includes the Draft Board.
	func stats() -> [String]
}

class SortVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var sortTypePicker: UIPickerView!
    @IBOutlet weak var orderSegementedControl: UISegmentedControl!
	
    private var selectedStat: Int?
    private let dataManager = TeamDataManager()
	
	private var stats = [String]()
    private var isAscending = true
	
	var delegate: SortDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

		/*
		sortTypePicker.dataSource = self
        sortTypePicker.delegate = self
        
        orderSegementedControl.isEnabled = false
		
		stats = delegate?.stats() ?? []
*/
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.selectedStat(selectedStat, isAscending: isAscending)
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		sortTypePicker.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return stats.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Draft Board (Default)"
        } else {
            return stats[row - 1]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedStat = nil
            orderSegementedControl.isEnabled = false
        } else {
            selectedStat = row - 1
            orderSegementedControl.isEnabled = true
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isAscending = true
        } else if sender.selectedSegmentIndex == 1 {
            isAscending = false
        }
    }
}
