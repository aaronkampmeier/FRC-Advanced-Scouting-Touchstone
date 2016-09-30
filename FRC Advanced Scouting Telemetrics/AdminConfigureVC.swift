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
			tableView.reloadRows(at: [IndexPath.init(row: regionals.index(of: regional) ?? 0, section: 0)], with: .fade)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set the detail view to what is being edited
        switch configureSetting! {
        case .matches:
            containerViewController!.presentMatchDetailView()case .regionals:
			containerViewController!.presentRegionalDetailView()
        default:
            break
        }
        
        //Retrieve the detail view controller from the container
        detailViewController = containerViewController?.detailViewController
    }
    
    enum CofigureSetting {
        case matches
		case regionals
        case unknown
        
        func stringDescription() -> String {
            switch self {
            case .matches:
                return "Matches"
			case .regionals:
				return "Regionals"
            case .unknown:
                return ""
            }
        }
    }
	
	func matchesForRegional(_ regional: Regional) -> [Match] {
		return dataManager.getMatches(forRegional: regional).sorted(by: {
			let match1 = $0 as Match
			let match2 = $1 as Match
			
			return (match1.matchNumber?.int32Value)! < (match2.matchNumber?.int32Value)!
		})
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		switch configureSetting! {
		case .matches:
			return (regionals.count)
		case .regionals:
			return 1
		default:
			return 0
		}
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch configureSetting! {
        case .matches:
            return regionalsAndMatches[section].count + 1
		case .regionals:
			return regionals.count + 1
        default:
            return 0
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch configureSetting! {
        case .matches:
            if regionalsAndMatches[(indexPath as NSIndexPath).section].count != (indexPath as NSIndexPath).row {
				let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
				cell?.textLabel?.text = "Match \(regionalsAndMatches[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].matchNumber!)"
				return cell!
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "plusCell")!
            }
		case .regionals:
			if regionals.count != (indexPath as NSIndexPath).row {
				let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
				cell?.textLabel?.text = "\(regionals[(indexPath as NSIndexPath).row].regionalNumber!). \(regionals[(indexPath as NSIndexPath).row].name!)"
				return cell!
			} else {
				return tableView.dequeueReusableCell(withIdentifier: "plusCell")!
			}
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch configureSetting! {
        case .matches:
			if regionalsAndMatches[(indexPath as NSIndexPath).section].count != (indexPath as NSIndexPath).row /*The row selected is not the last row*/{
				selectedMatch = regionalsAndMatches[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
			} else /*The row selected is the last row with the plus button*/{
				tableView.beginUpdates()
				//Create a new match
				do {
					var previousNumber = 0
					if let previousMatch = regionalsAndMatches[(indexPath as NSIndexPath).section].last {
						previousNumber = Int((previousMatch.matchNumber?.int32Value)!)
					}
					let newMatch = try dataManager.createNewMatch(previousNumber + 1, inRegional: regionals[(indexPath as NSIndexPath).section])
					regionalsAndMatches[(indexPath as NSIndexPath).section].append(newMatch)
					//Insert new match's cell into table view
					tableView.insertRows(at: [IndexPath.init(row: previousNumber, section: (indexPath as NSIndexPath).section)], with: .middle)
				} catch {
					//Present Alert saying unable to create new match
					let alert = UIAlertController(title: "Unable to Create New Match", message: "Contact the system administrator to have this diagnosed", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
					present(alert, animated: true, completion: nil)
				}
				
				//Deselct the plus row
				tableView.deselectRow(at: indexPath, animated: true)
				tableView.endUpdates()
				
				//Select the new match row
				tableView.selectRow(at: IndexPath(row: (indexPath as NSIndexPath).row, section: 0), animated: true, scrollPosition: .bottom)
				self.tableView(tableView, didSelectRowAt: indexPath)
			}
		case .regionals:
			if regionals.count != (indexPath as NSIndexPath).row {
				selectedRegional = regionals[(indexPath as NSIndexPath).row]
			} else {
				tableView.beginUpdates()
				
				var previousNumber = 0
				if let previousRegional = regionals.last {
					previousNumber = Int((previousRegional.regionalNumber?.int32Value)!)
				}
				let newRegional = dataManager.addRegional(regionalNumber: previousNumber + 1, withName: "(NO NAME YET)")
				regionals.append(newRegional)
				
				//Insert the new cell in the table view
				tableView.insertRows(at: [IndexPath.init(row: previousNumber, section: 0)], with: .middle)
				tableView.deselectRow(at: indexPath, animated: true)
				tableView.endUpdates()
			}
        default:
            break
        }
    }
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch configureSetting! {
		case .matches:
			return regionals[section].name!
		default:
			return nil
		}
	}
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		switch configureSetting! {
		case .matches:
			if (indexPath as NSIndexPath).row == regionalsAndMatches[(indexPath as NSIndexPath).section].count - 1 {
				return true
			} else {
				return false
			}
		case .regionals:
			if regionals.count - 1 == (indexPath as NSIndexPath).row {
				return true
			} else {
				return false
			}
		default:
			return false
		}
	}
	
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		switch configureSetting! {
		case .matches:
			if (indexPath as NSIndexPath).row == regionalsAndMatches[(indexPath as NSIndexPath).section].count - 1 {
				return .delete
			} else {
				return .none
			}
		case .regionals:
			if regionals.count - 1 == (indexPath as NSIndexPath).row {
				return .delete
			} else {
				return .none
			}
		default:
			return .none
		}
    }
	
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			switch configureSetting! {
			case .matches:
				//Notify the detail view
				(detailViewController as! AdminConfigureDetailMatchVC).removedMatch(regionalsAndMatches[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
				
				//Remove it from the table, from the data array, and from the persistent store
				dataManager.deleteMatch(regionalsAndMatches[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
				regionalsAndMatches[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
				tableView.beginUpdates()
				tableView.deleteRows(at: [indexPath], with: .top)
				tableView.endUpdates()
			case .regionals:
				//Warn the user of what they are doing
				let alert = UIAlertController(title: "Confidence Level?", message: "Are you sure you want to delete this regional? It will cause all associated matches and team data for those matches to be deleted as well.", preferredStyle: .alert)
				let deleteAction: UIAlertAction = UIAlertAction(title: "Yes, Delete", style: .destructive) {
					(alert: UIAlertAction) in
					self.dataManager.delete(Regional: self.regionals[(indexPath as NSIndexPath).row])
					self.regionals.remove(at: (indexPath as NSIndexPath).row)
					tableView.beginUpdates()
					tableView.deleteRows(at: [indexPath], with: .middle)
					tableView.endUpdates()
				}
				let cancelAction = UIAlertAction(title: "No, Cancel", style: .default, handler: nil)
				
				alert.addAction(deleteAction)
				alert.addAction(cancelAction)
				present(alert, animated: true, completion: nil)
			default:
				break
			}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previousViewController?.comingBackFromConfigure()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "adminConfigureDetail" {
            //When the detail view controller is being shown, capture the reference to it
            containerViewController = segue.destination as? AdminConfigureDetailVC
        }
    }
}
