//
//  AdminConfigureVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AdminConfigureVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var configureNavItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var matchTitleLabel: UILabel!
    lazy var navBar: UINavigationBar = self.navigationController!.navigationBar
    
    var previousViewController: AdminConsoleController?
    var configureSetting: CofigureSetting?
    var containerViewController: AdminConfigureDetailVC?
    var detailViewController: UIViewController?
    let dataManager = TeamDataManager()
    var selectedMatch: Match? {
        willSet {
            matchTitleLabel.text = "Match \(newValue!.matchNumber!)"
            (detailViewController as! AdminConfigureDetailMatchVC).didSelectMatch(newValue!)
        }
    }
	var selectedRegional: Regional? {
		willSet {
		matchTitleLabel.text = "Regional \(newValue!.regionalNumber!)"
		(detailViewController as! AdminConfigureDetailRegionalViewController).didSelectRegional(newValue!)
		if let regional = selectedRegional {
			tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: regionals.indexOf(regional) ?? 0, inSection: 0)], withRowAnimation: .Fade)
		}
		}
	}
	var regionals = [Regional]() {
		willSet {
		regionalsAndMatches = newValue.map({matchesForRegional($0)})
		}
	}
	var regionalsAndMatches: [[Match]] = [[Match]()]
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configureNavItem.title = configureSetting?.stringDescription()
		
		regionals = dataManager.getAllRegionals()
		regionalsAndMatches = regionals.map({matchesForRegional($0)})
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set the detail view to what is being edited
        switch configureSetting! {
        case .Matches:
            containerViewController!.presentMatchDetailView()case .Regionals:
			containerViewController!.presentRegionalDetailView()
        default:
            break
        }
        
        //Retrieve the detail view controller from the container
        detailViewController = containerViewController?.detailViewController
    }
    
    enum CofigureSetting {
        case Matches
		case Regionals
        case Unknown
        
        func stringDescription() -> String {
            switch self {
            case .Matches:
                return "Matches"
			case .Regionals:
				return "Regionals"
            case .Unknown:
                return ""
            }
        }
    }
	
	func matchesForRegional(regional: Regional) -> [Match] {
		return dataManager.getMatches(forRegional: regional).sort({
			let match1 = $0 as Match
			let match2 = $1 as Match
			
			return match1.matchNumber?.intValue < match2.matchNumber?.intValue
		})
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		switch configureSetting! {
		case .Matches:
			return (regionals.count)
		case .Regionals:
			return 1
		default:
			return 0
		}
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch configureSetting! {
        case .Matches:
            return regionalsAndMatches[section].count + 1
		case .Regionals:
			return regionals.count + 1
        default:
            return 0
        }
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch configureSetting! {
        case .Matches:
            if regionalsAndMatches[indexPath.section].count != indexPath.row {
				let cell = tableView.dequeueReusableCellWithIdentifier("cell")
				cell?.textLabel?.text = "Match \(regionalsAndMatches[indexPath.section][indexPath.row].matchNumber!)"
				return cell!
            } else {
                return tableView.dequeueReusableCellWithIdentifier("plusCell")!
            }
		case .Regionals:
			if regionals.count != indexPath.row {
				let cell = tableView.dequeueReusableCellWithIdentifier("cell")
				cell?.textLabel?.text = "\(regionals[indexPath.row].regionalNumber!). \(regionals[indexPath.row].name!)"
				return cell!
			} else {
				return tableView.dequeueReusableCellWithIdentifier("plusCell")!
			}
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch configureSetting! {
        case .Matches:
			if regionalsAndMatches[indexPath.section].count != indexPath.row /*The row selected is not the last row*/{
				selectedMatch = regionalsAndMatches[indexPath.section][indexPath.row]
			} else /*The row selected is the last row with the plus button*/{
				tableView.beginUpdates()
				//Create a new match
				do {
					var previousNumber = 0
					if let previousMatch = regionalsAndMatches[indexPath.section].last {
						previousNumber = Int((previousMatch.matchNumber?.intValue)!)
					}
					let newMatch = try dataManager.createNewMatch(previousNumber + 1, inRegional: regionals[indexPath.section])
					regionalsAndMatches[indexPath.section].append(newMatch)
					//Insert new match's cell into table view
					tableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: previousNumber, inSection: indexPath.section)], withRowAnimation: .Middle)
				} catch {
					//Present Alert saying unable to create new match
					let alert = UIAlertController(title: "Unable to Create New Match", message: "Contact the system administrator to have this diagnosed", preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
					presentViewController(alert, animated: true, completion: nil)
				}
				
				//Deselct the plus row
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				tableView.endUpdates()
				
				//Select the new match row
				tableView.selectRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0), animated: true, scrollPosition: .Bottom)
				self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
			}
		case .Regionals:
			if regionals.count != indexPath.row {
				selectedRegional = regionals[indexPath.row]
			} else {
				tableView.beginUpdates()
				
				var previousNumber = 0
				if let previousRegional = regionals.last {
					previousNumber = Int((previousRegional.regionalNumber?.intValue)!)
				}
				let newRegional = dataManager.addRegional(regionalNumber: previousNumber + 1, withName: "(NO NAME YET)")
				regionals.append(newRegional)
				
				//Insert the new cell in the table view
				tableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: previousNumber, inSection: 0)], withRowAnimation: .Middle)
				tableView.deselectRowAtIndexPath(indexPath, animated: true)
				tableView.endUpdates()
			}
        default:
            break
        }
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch configureSetting! {
		case .Matches:
			return regionals[section].name!
		default:
			return nil
		}
	}
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		switch configureSetting! {
		case .Matches:
			if indexPath.row == regionalsAndMatches[indexPath.section].count - 1 {
				return true
			} else {
				return false
			}
		case .Regionals:
			if regionals.count - 1 == indexPath.row {
				return true
			} else {
				return false
			}
		default:
			return false
		}
	}
	
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		switch configureSetting! {
		case .Matches:
			if indexPath.row == regionalsAndMatches[indexPath.section].count - 1 {
				return .Delete
			} else {
				return .None
			}
		case .Regionals:
			if regionals.count - 1 == indexPath.row {
				return .Delete
			} else {
				return .None
			}
		default:
			return .None
		}
    }
	
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
			switch configureSetting! {
			case .Matches:
				//Notify the detail view
				(detailViewController as! AdminConfigureDetailMatchVC).removedMatch(regionalsAndMatches[indexPath.section][indexPath.row])
				
				//Remove it from the table, from the data array, and from the persistent store
				dataManager.deleteMatch(regionalsAndMatches[indexPath.section][indexPath.row])
				regionalsAndMatches[indexPath.section].removeAtIndex(indexPath.row)
				tableView.beginUpdates()
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
				tableView.endUpdates()
			case .Regionals:
				//Warn the user of what they are doing
				let alert = UIAlertController(title: "Confidence Level?", message: "Are you sure you want to delete this regional? It will cause all associated matches and team data for those matches to be deleted as well.", preferredStyle: .Alert)
				let deleteAction: UIAlertAction = UIAlertAction(title: "Yes, Delete", style: .Destructive) {
					(alert: UIAlertAction) in
					self.dataManager.delete(Regional: self.regionals[indexPath.row])
					self.regionals.removeAtIndex(indexPath.row)
					tableView.beginUpdates()
					tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
					tableView.endUpdates()
				}
				let cancelAction = UIAlertAction(title: "No, Cancel", style: .Default, handler: nil)
				
				alert.addAction(deleteAction)
				alert.addAction(cancelAction)
				presentViewController(alert, animated: true, completion: nil)
			default:
				break
			}
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        previousViewController?.comingBackFromConfigure()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "adminConfigureDetail" {
            //When the detail view controller is being shown, capture the reference to it
            containerViewController = segue.destinationViewController as? AdminConfigureDetailVC
        }
    }
}