//
//  TeamListTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

@objc protocol TeamSelectionDelegate {
	func selectedTeam(_ team: Team?)
	@objc optional func selectedRegional(_ regional: Regional?)
}

class TeamListTableViewController: UITableViewController, UISearchControllerDelegate {
	@IBOutlet weak var regionalSelectionButton: UIButton!
	@IBOutlet weak var editTeamsButton: UIBarButtonItem!
	
	var searchController: UISearchController!
	weak var delegate: TeamSelectionDelegate?
	let teamManager = TeamDataManager()
	let teamImagesCache = NSCache<Team, UIImage>()
	
	var isSorted = false {
		didSet {
			if isSorted {
				
			} else {
				currentSortedTeams = nil
			}
		}
	}
	var sortVC: SortVC {
		return sortNavVC.topViewController as! SortVC
	}
	var sortNavVC: UINavigationController!
	var currentSortedTeams: [TeamListTeam]? {
		didSet {
			if let teams = currentSortedTeams {
				currentTeamsToDisplay = teams
			} else {
				currentTeamsToDisplay = currentRegionalTeams
			}
		}
	}
	
	var teams: [Team] {
		get {
			do {
				return try teamManager.getDraftBoard()
			} catch {
				NSLog("Unable to get the teams: \(error)")
				return [Team]()
			}
		}
	}
	var currentRegionalTeams: [TeamListTeam] = [TeamListTeam]() {
		didSet {
			currentTeamsToDisplay = currentRegionalTeams
		}
		
		willSet {
			//Update the stat contexts
			for team in newValue {
				if let regional = selectedRegional {
					let regionalPerformances = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
					let teamPerformances = Set(team.team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
					
					let regionalPerformance = Array(regionalPerformances.intersection(teamPerformances)).first!
					
					team.statContext.setRegionalPerformanceStatistics(regionalPerformance)
					team.statContext.setMatchPerformanceStatistics((regionalPerformance.matchPerformances!.allObjects as! [TeamMatchPerformance]))
				} else {
					let combinedMatchPerformances = team.team.regionalPerformances?.reduce([TeamMatchPerformance]()) {matchPerformances,regionalPerformance in
						let newMatchPerformances = (regionalPerformance as AnyObject).matchPerformances!?.allObjects as![TeamMatchPerformance]
						var mutableMatchPerformances = matchPerformances
						mutableMatchPerformances.append(contentsOf: newMatchPerformances)
						return mutableMatchPerformances
					}
					
					team.statContext.setRegionalPerformanceStatistics(nil)
					team.statContext.setMatchPerformanceStatistics(combinedMatchPerformances)
				}
			}
		}
	}
	var currentTeamsToDisplay = [TeamListTeam]() {
		didSet {
			tableView.reloadData()
		}
	}
	var selectedTeam: TeamListTeam? {
		didSet {
			delegate?.selectedTeam(selectedTeam?.team)
			NotificationCenter.default.post(name: Notification.Name(rawValue: "Different Team Selected"), object: self)
			if let sTeam = selectedTeam {
				if let index = currentTeamsToDisplay.index(where: {team in
					return team.team == sTeam.team
				}) {
					tableView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .none)
				}
			} else {
				tableView.deselectRow(at: tableView.indexPathForSelectedRow ?? IndexPath(), animated: false)
			}
		}
	}
	var selectedRegional: Regional? {
		didSet {
			delegate?.selectedRegional?(selectedRegional)
			
			if let regional = selectedRegional {
				//Set to nil, because the selected team might not be in the new regional
				selectedTeam = nil
				currentRegionalTeams = (regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance]).map({TeamListTeam(team: $0.team!)})
				regionalSelectionButton.setTitle(regional.name, for: UIControlState())
			} else {
				currentRegionalTeams = teams.map({TeamListTeam(team: $0)})
				regionalSelectionButton.setTitle("All Teams", for: UIControlState())
				
				//Set the same team as before
				let team = selectedTeam
				selectedTeam = team
			}
		}
	}
	var teamRegionalPerformance: TeamRegionalPerformance? {
		get {
			if let team = selectedTeam {
				if let regional = selectedRegional {
					//Get two sets
					let regionalPerformances: Set<TeamRegionalPerformance> = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
					let teamPerformances = Set(team.team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
					
					//Combine the two sets to find the one in both
					let teamRegionalPerformance = Array(regionalPerformances.intersection(teamPerformances)).first ?? nil
					
					return teamRegionalPerformance
				}
			}
			return nil
		}
	}
	
	//Holds a team and its associated stat context
	class TeamListTeam {
		let team: Team
		var statContext: StatContext
		var statCalculation: StatCalculation?
		
		init(team: Team) {
			self.team = team
			statContext = StatContext(context: team)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		(UIApplication.shared.delegate as! AppDelegate).teamListTableVC = self
		
		//Set up the searching capabilities and the search bar. At the time of coding, Storyboards do not support the new UISearchController, so this is done programatically.
		let searchResultsVC = storyboard?.instantiateViewController(withIdentifier: "teamListSearchResults") as! TeamListSearchResultsTableViewController
		searchController = UISearchController(searchResultsController: searchResultsVC)
		searchController.searchResultsUpdater = searchResultsVC
		tableView.tableHeaderView = searchController.searchBar
		
		//Add responder for notification about a new team
		NotificationCenter.default.addObserver(forName: NSNotification.Name("New Team"), object: nil, queue: nil, using: addTeamFromNotification)
		
		tableView.allowsSelectionDuringEditing = true
		
		sortNavVC = storyboard?.instantiateViewController(withIdentifier: "sortNav") as! UINavigationController
		
		//Load in the beginning data
		selectedRegional = nil
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if splitViewController?.isCollapsed ?? false {
			if let indexPath = tableView.indexPathForSelectedRow {
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentTeamsToDisplay.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "rankedCell", for: indexPath) as! TeamListTableViewCell

        let teamListTeam = currentTeamsToDisplay[(indexPath as NSIndexPath).row]
		
		if isEditing {
			cell.teamLabel.text = "\(teamListTeam.team.teamNumber!)"
			cell.statLabel.text = ""
		} else {
			cell.teamLabel.text = "Team \(teamListTeam.team.teamNumber!)"
			if isSorted {
				cell.statLabel.text = "\(teamListTeam.statCalculation!.value)"
			} else {
				cell.statLabel.text = ""
			}
		}
		
		cell.rankLabel.text = "\(try! TeamDataManager().getDraftBoard().index(of: teamListTeam.team)! as Int + 1)"
		
		if let image = teamImagesCache.object(forKey: teamListTeam.team) {
			cell.frontImage.image = image
		} else {
			if let imageData = teamListTeam.team.frontImage {
				guard let uiImage = UIImage(data: imageData as Data) else {
					fatalError("Image Data Corrupted")
				}
				cell.frontImage.image = uiImage
				teamImagesCache.setObject(uiImage, forKey: teamListTeam.team)
			} else {
				cell.frontImage.image = UIImage(named: "FRC-Logo")
			}
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedTeam = currentTeamsToDisplay[(indexPath as NSIndexPath).row]
		
		//Checks if the split view is collapsed or not. If it is then simply present the detail view controller because it will push onto self's navigation controller. If it isn't, then present the detail view controller's navigation controller because it is actually a "split" view.
		let detailRootController: UIViewController
		if splitViewController!.isCollapsed {
			detailRootController = appDelegate.teamListDetailVC!
		} else {
			detailRootController = appDelegate.teamListDetailVC!.navigationController!
		}
		splitViewController?.showDetailViewController(detailRootController, sender: self)
	}

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
		if selectedRegional == nil {
			return true
		} else {
			return false
		}
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		tableView.beginUpdates()
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .top)
			
			teamManager.deleteTeam(teams[(indexPath as NSIndexPath).row])
			let currentRegional = selectedRegional
			selectedRegional = currentRegional
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
		tableView.endUpdates()
    }
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		return .none
	}

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
		//Move the team in the array and in Core Data
		let movedTeamListTeam = currentRegionalTeams[(fromIndexPath as NSIndexPath).row]
		currentRegionalTeams.remove(at: (fromIndexPath as NSIndexPath).row)
		currentRegionalTeams.insert(movedTeamListTeam, at: (toIndexPath as NSIndexPath).row)
		
		do {
			try teamManager.moveTeam((fromIndexPath as NSIndexPath).row, toIndex: (toIndexPath as NSIndexPath).row)
		} catch {
			NSLog("Unable to save team move: \(error)")
		}
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
		if selectedRegional == nil {
			return true
		} else {
			return false
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let regional = selectedRegional {
			return "Regional: \(regional.name!)"
		} else {
			return "All Teams"
		}
	}
	
	//Function for setting the editing of the teams
	@IBAction func editTeamsPressed(_ sender: UIBarButtonItem) {
		
		tableView.beginUpdates()
		//When the edit button is pressed...
		if self.isEditing {
			//Stop editing
			self.setEditing(false, animated: true)
			//Change the label back
			editTeamsButton.title = "Edit Teams"
			
			tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
		} else {
			self.setEditing(true, animated: true)
			editTeamsButton.title = "Finish Editing"
			
			tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
		}
		tableView.endUpdates()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		tableView.setEditing(editing, animated: animated)
	}
	
	//MARK: -
	func addTeamFromNotification(_ notification: Notification) {
		isSorted = false
		selectedRegional = nil
	}
	
	//MARK: - Searching

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "regionalSelection" {
			let destinationVC = (segue.destination as! UINavigationController).topViewController as! RegionalPickerViewController
			destinationVC.delegate = self
		}
    }
	
	//MARK: - Sorting
	@IBAction func sortPressed(_ sender: UIBarButtonItem) {
		sortVC.delegate = self
		sortNavVC.modalPresentationStyle = .popover
		sortNavVC.preferredContentSize = CGSize(width: 350, height: 300)
		
		let popoverVC = sortNavVC.popoverPresentationController
		
		popoverVC?.barButtonItem = sender
		present(sortNavVC, animated: true, completion: nil)
	}
	
	func sortList(withStat stat: Int?, isAscending ascending: Bool) {
		var statName = ""
		if let stat = stat {
			//Update stats in cache
			for index in 0..<currentRegionalTeams.count {
				currentRegionalTeams[index].statCalculation = currentRegionalTeams[index].statContext.possibleStats[stat]
			}
			
			//Sort
			let currentTeams = currentRegionalTeams
			currentSortedTeams = currentTeams.sorted() {team1,team2 in
				let before = team1.statCalculation?.value ?? 0 > team2.statCalculation?.value ?? 0
				statName = team1.statCalculation?.description ?? ""
				if ascending {
					return before
				} else {
					return !before
				}
			}
			
			isSorted = true
		} else {
			//Update stats in cache
			for index in 0..<currentRegionalTeams.count {
				currentRegionalTeams[index].statCalculation = nil
			}
			
			statName = "Draft Board (Default)"
			
			isSorted = false
		}
		
		Answers.logCustomEvent(withName: "Sort Team List", customAttributes: ["Stat":statName, "Ascending":ascending.description])
	}
	
	@IBAction func returnToTeamList(_ segue: UIStoryboardSegue) {
		
	}
	
	@IBAction func returningWithSegue(_ segue: UIStoryboardSegue) {
		
	}
}

extension TeamListTableViewController: RegionalSelection {
	func regionalSelected(_ regional: Regional?) {
		selectedRegional = regional
	}
	
	func currentRegional() -> Regional? {
		return selectedRegional
	}
}

extension TeamListTableViewController: SortDelegate {
	func selectedStat(_ stat: Int?, isAscending: Bool) {
		sortList(withStat: stat, isAscending: isAscending)
	}
	
	func stats() -> [String] {
		return currentTeamsToDisplay.first?.statContext.possibleStats.map() {statCalculation in
			return statCalculation.description
		} ?? []
	}
}
