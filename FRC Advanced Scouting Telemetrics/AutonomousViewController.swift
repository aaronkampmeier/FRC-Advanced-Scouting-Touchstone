//
//  AutonomousViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AutonomousViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var optionsList: UITableView!
	
	var standsScoutingVC: StandsScoutingViewController?
	let dataManager = TeamDataManager()
	
	var autonomousCycles: [AutonomousCycle] = [AutonomousCycle]()
	var sections: [AutonomousSection] = []
	
    var rowStage = 0
	
	var spySection = AutonomousSection(title: "Spy")
	
	var normalRows: [AutonomousRow] = [AutonomousRow]()
	
	struct AutonomousSection {
		let title: String
		var rows = [AutonomousRow]()
		var autonomousCycle: AutonomousCycle? {
			didSet {
				var newRows = [AutonomousRow]()
				for row in rows {
					var newRow = row
					switch newRow.label {
					case "Did they move?":
						newRow.associatedProperty = autonomousCycle?.moved
					case "Did they reach a defense?":
						newRow.associatedProperty = autonomousCycle?.reachedDefense
					case "Did they cross it successfully?":
						newRow.associatedProperty = autonomousCycle?.crossedDefense
					case "Did they shoot?":
						newRow.associatedProperty = autonomousCycle?.shot
					case "Did they return?":
						newRow.associatedProperty = autonomousCycle?.returned
					default:
						break
					}
					
					newRows.append(newRow)
				}
				
				rows = newRows
			}
		}
		
		init(title: String) {
			self.title = title
		}
		
		init(title: String, withRows rows: [AutonomousRow], andAutonomousCycle cycle: AutonomousCycle) {
			self.title = title
			self.rows = rows
			self.autonomousCycle = cycle
		}
	}
	
	struct AutonomousRow {
		var cellType: UITableViewCell.Type
		var associatedProperty: NSNumber?
		var label: String
		
		var firstLabel: String?
		var secondLabel: String?
		
		init(cellType: UITableViewCell.Type, label: String) {
			self.cellType = cellType
			self.label = label
		}
		
		init(cellType: UITableViewCell.Type, label: String, property: NSNumber?) {
			self.cellType = cellType
			self.label = label
			self.associatedProperty = property
		}
		
		init(cellType: UITableViewCell.Type, label: String, property: NSNumber?, first: String, second: String) {
			self.cellType = cellType
			self.label = label
			self.associatedProperty = property
			self.firstLabel = first
			self.secondLabel = second
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        optionsList.dataSource = self
        optionsList.delegate = self
        optionsList.allowsSelection = false
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		setup()
	}
	
	var isSetup = false
	func setup() {
		if !isSetup {
			isSetup = true
			standsScoutingVC = (parentViewController as! StandsScoutingViewController)
			if standsScoutingVC?.matchPerformance?.autonomousCycles?.count == 0 {
				let cycle = dataManager.createAutonomousCycle(inMatchPerformance: standsScoutingVC!.matchPerformance!)
				autonomousCycles.append(cycle)
			} else {
				autonomousCycles = standsScoutingVC?.matchPerformance?.autonomousCycles?.allObjects as! [AutonomousCycle]
			}
			
			normalRows = [
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they move?"),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they reach a defense?"),
				AutonomousRow(cellType: AutonomousPickerCell.self, label: "Defense Reached"),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they cross it successfully?"),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they shoot?"),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they return?")
			]
			
			spySection.rows = [
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Start in the spy box", property: (standsScoutingVC?.matchPerformance?.autoSpy)),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they shoot?", property: (standsScoutingVC?.matchPerformance?.autoSpyDidShoot)),
				AutonomousRow(cellType: AutonomousSwitchCell.self, label: "Did they make it?", property: (standsScoutingVC?.matchPerformance?.autoSpyDidMakeShot)),
				AutonomousRow(cellType: AutonomousSegmentCell.self, label: "In what goal?", property: (standsScoutingVC?.matchPerformance?.autoSpyShotHighGoal), first: "Low Goal", second: "High Goal")
			]
			
			sections.append(spySection)
			sections.append(AutonomousSection(title: "Cycle 1", withRows: normalRows, andAutonomousCycle: autonomousCycles.first!))
			optionsList.reloadData()
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return sections.count
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let row = sections[indexPath.section].rows[indexPath.row]
		switch row.cellType {
		case is AutonomousPickerCell.Type:
			let cell = tableView.dequeueReusableCellWithIdentifier("defenseReachedCell") as! AutonomousPickerCell
			cell.associatedAutonomousCycle = sections[indexPath.section].autonomousCycle
			cell.autonomousVC = self
			cell.defenses = standsScoutingVC?.defenses
			return cell
		case is AutonomousSwitchCell.Type:
			let cell = tableView.dequeueReusableCellWithIdentifier("mainCell") as! AutonomousSwitchCell
			cell.label.text = row.label
			cell.associatedProperty = row.associatedProperty
			return cell
		case is AutonomousSegmentCell.Type:
			let cell = tableView.dequeueReusableCellWithIdentifier("segmentCell") as! AutonomousSegmentCell
			cell.label.text = row.label
			cell.associatedProperty = row.associatedProperty
			cell.firstOption = row.firstLabel
			cell.secondOption = row.secondLabel
			return cell
		default:
			return UITableViewCell()
		}
    }
}

class AutonomousSwitchCell: UITableViewCell {
	@IBOutlet weak var toggleSwitch: UISwitch!
	@IBOutlet weak var label: UILabel!
	
	var associatedProperty: NSNumber? {
		didSet {
			if let property = associatedProperty {
				toggleSwitch.on = property.boolValue
			}
		}
	}
	
	@IBAction func switchSwitched(sender: UISwitch) {
		associatedProperty = sender.on
	}
}

class AutonomousSegmentCell: UITableViewCell {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	var associatedProperty: NSNumber? {
		didSet {
			if let property = associatedProperty {
				segmentedControl.selectedSegmentIndex = property.integerValue
			}
		}
	}
	var firstOption: String? {
		didSet {
			segmentedControl.setTitle(firstOption, forSegmentAtIndex: 0)
		}
	}
	var secondOption: String? {
		didSet {
			segmentedControl.setTitle(secondOption, forSegmentAtIndex: 1)
		}
	}
	
	@IBAction func segmentChanged(sender: UISegmentedControl) {
		associatedProperty = sender.selectedSegmentIndex
	}
}

class AutonomousPickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
	@IBOutlet weak var selectButton: UIButton!
	var associatedAutonomousCycle: AutonomousCycle? {
		didSet {
			if let cycle = associatedAutonomousCycle {
				selectButton.setTitle(cycle.defenseReached?.defenseName ?? "", forState: .Normal)
			}
		}
	}
	var autonomousVC: AutonomousViewController?
	var defenses: [Defense]?
	
	@IBAction func selectDefenseButtonPressed(sender: UIButton) {
		let defensePickerVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("defensePicker") as! PopoverPickerViewController
		defensePickerVC.modalPresentationStyle = .Popover
		defensePickerVC.preferredContentSize = CGSize(width: 300, height: 250)
		let popoverController = defensePickerVC.popoverPresentationController!
		popoverController.sourceView = sender
		
		autonomousVC?.presentViewController(defensePickerVC, animated: true) {
			defensePickerVC.picker.dataSource = self
			defensePickerVC.picker.delegate = self
		}
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return (autonomousVC?.standsScoutingVC?.defenses?.count ?? 0) + 1
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if row < defenses?.count {
			return defenses![row].defenseName
		} else {
			return "Low Bar"
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//Update core data
		if row < defenses?.count {
			associatedAutonomousCycle?.defenseReached = defenses?[row]
		} else {
			associatedAutonomousCycle?.defenseReached = autonomousVC?.dataManager.getLowBar()
		}
		
		selectButton.setTitle((associatedAutonomousCycle?.defenseReached?.defenseName) ?? "ERROR", forState: .Normal)
	}
}
