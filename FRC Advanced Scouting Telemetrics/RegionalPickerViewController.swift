//
//  RegionalPickerViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/15/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class RegionalPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	@IBOutlet weak var regionalPicker: UIPickerView!
	
	var teamListController: TeamListController?
	var dataManager = TeamDataManager()
	var regionals: [Regional]?
	var currentRegional: Regional?
	var chosenRegional: Regional?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		regionalPicker.dataSource = self
		regionalPicker.delegate = self
		
		//Load all the regionals
		regionals = dataManager.getAllRegionals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if let current = currentRegional {
			regionalPicker.selectRow((regionals?.indexOf(current))!, inComponent: 0, animated: true)
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		teamListController!.didChooseRegional(chosenRegional)
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return regionals!.count + 1
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch row {
		case 0:
			return "All Teams (Default)"
		default:
			return regionals![row-1].name
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		chosenRegional = regionals![row-1]
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
