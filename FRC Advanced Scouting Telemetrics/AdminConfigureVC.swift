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
	var regionals = [Regional]()
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
            containerViewController!.presentMatchDetailView()
        case .Statistics:
            containerViewController!.presentStatDetailView()
        default:
            break
        }
        
        //Retrieve the detail view controller from the container
        detailViewController = containerViewController?.detailViewController
    }
    
    enum CofigureSetting {
        case Matches
        case Statistics
		case Regionals
        case Unknown
        
        func stringDescription() -> String {
            switch self {
            case .Matches:
                return "Matches"
            case .Statistics:
                return "Statistics"
			case .Regionals:
				return "Regionals"
            case .Unknown:
                return ""
            }
        }
    }
	
	func matchesForRegional(regional: Regional) -> [Match] {
		return dataManager.getMatches(forRegional: regional)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return (regionals.count)
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch configureSetting! {
        case .Matches:
            return regionalsAndMatches[section].count + 1
        case .Statistics:
            return 0
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
        case .Statistics:
            return UITableViewCell()
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
                    try dataManager.createNewMatch(previousNumber + 1, inRegional: regionals[indexPath.section])
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
                
                //Select the new match row
                //tableView.selectRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0), animated: true, scrollPosition: .Bottom)
                
                tableView.endUpdates()
            }
        case .Statistics:
            fallthrough
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == regionalsAndMatches[indexPath.section].count - 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == regionalsAndMatches[indexPath.section].count - 1 {
            return .Delete
        } else {
            return .None
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dataManager.deleteMatch(regionalsAndMatches[indexPath.section][indexPath.row])
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            tableView.endUpdates()
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