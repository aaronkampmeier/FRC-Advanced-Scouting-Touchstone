//
//  SyncingConflictViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/8/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class SyncingConflictViewController: UIViewController, UITableViewDataSource {
	@IBOutlet weak var conflictManagementTable: UITableView!
	@IBOutlet weak var conflictMessage: UILabel!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	var conflicts: [MergeManager.Conflict]? {
		didSet {
			highUnresolvedConflicts = (conflicts?.filter() {$0.priority == MergeManager.ConflictPriority.High && $0.doesConflict && $0.resolution == nil})!
		}
	}
	
	var highUnresolvedConflicts: [MergeManager.Conflict] = Array()
	
	var resolvedConflicts: [MergeManager.Conflict] = Array() {
		didSet {
			if resolvedConflicts.count == highUnresolvedConflicts.count {
				doneButton.enabled = true
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		conflictManagementTable.dataSource = self
		conflictManagementTable.allowsSelection = false
		conflictManagementTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		return
	}
	
	@IBAction func resolutionPicked(sender: UISegmentedControl) {
		var indexPath: NSIndexPath = NSIndexPath()
		var view: UIView? = sender
		while view != nil {
			if view!.isKindOfClass(UITableViewCell) {
				indexPath = conflictManagementTable.indexPathForCell(view as! UITableViewCell)!
				break
			} else {
				view = view!.superview
			}
		}
		
		let conflict = highUnresolvedConflicts[indexPath.row]
		
		//Set the resolution
		switch sender.selectedSegmentIndex {
		case 0:
			conflict.resolution = conflict.payload1
		case 1:
			conflict.resolution = conflict.payload2
		default:
			assertionFailure("Check this.")
		}
		
		if !resolvedConflicts.contains({$0 === conflict}) {
			resolvedConflicts.append(conflict)
		}
	}
	
	@IBAction func selectAllLeft(sender: UIButton) {
		for conflict in highUnresolvedConflicts {
			conflict.resolution = conflict.payload1
		}
		resolvedConflicts = highUnresolvedConflicts
		
		conflictManagementTable.beginUpdates()
		conflictManagementTable.reloadRowsAtIndexPaths(conflictManagementTable.indexPathsForVisibleRows!, withRowAnimation: .Automatic)
		conflictManagementTable.endUpdates()
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return highUnresolvedConflicts.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = conflictManagementTable.dequeueReusableCellWithIdentifier("cell") as! ConflictTableViewCell
		
		let conflict = highUnresolvedConflicts[indexPath.row]
		cell.mainTitle.text = conflict.title
		cell.identifierLabel.text = conflict.identifier
		let payload = conflict.payload1
		let description = payload.description
		cell.firstDetail.text = description
		cell.secondDetail.text = conflict.payload2.description
		
		if let resolution = conflict.resolution as? AnyObject {
			if resolution === conflict.payload1 as? AnyObject {
				cell.resolutionPicker.selectedSegmentIndex = 0
			} else if resolution === conflict.payload2 as? AnyObject {
				cell.resolutionPicker.selectedSegmentIndex = 1
			} else {
				cell.resolutionPicker.selectedSegmentIndex = -2
			}
		} else {
			cell.resolutionPicker.selectedSegmentIndex = -1
		}
		
		return cell
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
