//
//  AutonomousViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AutonomousViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var optionsList: UITableView!
	
	var standsScoutingVC: StandsScoutingViewController?
	let dataManager = TeamDataManager()
	
	var autonomousCycles: [AutonomousCycle] = [AutonomousCycle]()
	var defenseReachedButton: UIButton?
    var rowStage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        optionsList.dataSource = self
        optionsList.delegate = self
        optionsList.allowsSelection = false
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		standsScoutingVC = (parentViewController as! StandsScoutingViewController)
		if standsScoutingVC?.matchPerformance?.autonomousCycles?.count == 0 {
			let cycle = dataManager.createAutonomousCycle(inMatchPerformance: standsScoutingVC!.matchPerformance!)
			autonomousCycles.append(cycle)
		} else {
			autonomousCycles = standsScoutingVC?.matchPerformance?.autonomousCycles?.allObjects as! [AutonomousCycle]
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		dataManager.commitChanges()
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch rowStage {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 6
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Did they move?"
            let switchView = cell?.viewWithTag(3) as! UISwitch
            switchView.on = false
            switchView.addTarget(self, action: "didMoveSwitchFlipped:", forControlEvents: .ValueChanged)
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Did they reach a defense?"
            let switchView = cell?.viewWithTag(3) as! UISwitch
            switchView.on = false
            switchView.addTarget(self, action: "didReachDefenseSwitchFlipped:", forControlEvents: .ValueChanged)
            return cell!
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("defenseReachedCell")
			defenseReachedButton = cell?.viewWithTag(14) as? UIButton
            return cell!
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Did they cross it succesfully?"
            let switchView = cell?.viewWithTag(3) as! UISwitch
            switchView.on = false
            switchView.addTarget(self, action: "crossedSwitchFlipped:", forControlEvents: .ValueChanged)
            return cell!
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Did they shoot?"
            let switchView = cell?.viewWithTag(3) as! UISwitch
            switchView.on = false
            switchView.addTarget(self, action: "shotSwitchFlipped:", forControlEvents: .ValueChanged)
            return cell!
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mainCell")
            (cell?.viewWithTag(1) as! UILabel).text = "Did they return?"
            let switchView = cell?.viewWithTag(3) as! UISwitch
            switchView.on = false
            switchView.addTarget(self, action: "returnSwitchFlipped:", forControlEvents: .ValueChanged)
            return cell!
        } else {
            return UITableViewCell()
        }
    }
    
    func returnSwitchFlipped(sender: UISwitch) {
        autonomousCycles.first?.returned = sender.on
    }
    
    func shotSwitchFlipped(sender: UISwitch) {
        autonomousCycles.first?.shot = sender.on
    }
    
    func crossedSwitchFlipped(sender: UISwitch) {
        autonomousCycles.first?.crossedDefense = sender.on
    }
    
    func didMoveSwitchFlipped(sender: UISwitch) {
		//Update core data
		autonomousCycles.first!.moved = sender.on
		
        optionsList.beginUpdates()
        if sender.on {
            rowStage = 1
            optionsList.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Top)
        } else {
            //Get an array of all the index paths
            let num = tableView(optionsList, numberOfRowsInSection: 0)
            var indexPaths = [NSIndexPath]()
            for index in 2...num {
                indexPaths.append(NSIndexPath(forRow: index-1, inSection: 0))
            }
            rowStage = 0
            optionsList.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        optionsList.endUpdates()
    }
    
    func didReachDefenseSwitchFlipped(sender: UISwitch) {
		//Update core data
		autonomousCycles.first?.reachedDefense = sender.on
		
        optionsList.beginUpdates()
        if sender.on {
            rowStage = 2
            var indexPaths = [NSIndexPath]()
            for index in 1...4 {
                indexPaths.append(NSIndexPath(forRow: index+1, inSection: 0))
            }
            optionsList.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        } else {
            //Get an array of all the index paths
            let num = tableView(optionsList, numberOfRowsInSection: 0)
            var indexPaths = [NSIndexPath]()
            for index in 3...num {
                indexPaths.append(NSIndexPath(forRow: index-1, inSection: 0))
            }
            
            rowStage = 1
            optionsList.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
        }
        optionsList.endUpdates()
    }
	
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (standsScoutingVC?.defenses?.count)! + 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if row < standsScoutingVC?.defenses?.count {
			return standsScoutingVC?.defenses?[row].defenseName
		} else {
			return "Low Bar"
		}
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//Update core data
		if row < standsScoutingVC?.defenses?.count {
			autonomousCycles.first?.defenseReached = standsScoutingVC?.defenses![row]
		} else {
			autonomousCycles.first?.defenseReached = dataManager.getLowBar()
		}
		
		//Update the button
		defenseReachedButton?.setTitle((autonomousCycles.first?.defenseReached?.defenseName) ?? "ERROR", forState: .Normal)
	}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popover" {
			let destinationVC = segue.destinationViewController as! PopoverPickerViewController
            destinationVC.autonomousViewController = self
			
			destinationVC.popoverPresentationController?.sourceRect = (defenseReachedButton?.frame)!
        }
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
