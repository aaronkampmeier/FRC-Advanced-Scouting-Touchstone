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
	@objc optional func selectedEvent(_ event: Event?)
}

class TeamListTableViewController: UITableViewController, UISearchControllerDelegate {
	@IBOutlet weak var eventSelectionButton: UIButton!
	
	var searchController: UISearchController!
	weak var delegate: TeamSelectionDelegate?
	let dataManager = DataManager()
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
	var currentSortedTeams: [Team]? {
		didSet {
			if let teams = currentSortedTeams {
				currentTeamsToDisplay = teams
			} else {
				currentTeamsToDisplay = currentEventTeams
			}
		}
	}
	
    var teams: [Team] = [] {
        didSet {
            localTeams = UniversalToLocalConversion<Team,LocalTeam>(universalObjects: teams).convertToLocal()
        }
    }
    var localTeams = [LocalTeam]()
	
	var currentEventTeams: [Team] = [Team]() {
		didSet {
			currentTeamsToDisplay = currentEventTeams
		}
		
		willSet {
			//Update the stat contexts
//			for team in newValue {
//				if let event = selectedEvent {
//					let eventPerformances = Set(event.teamEventPerformances?.allObjects as! [TeamEventPerformance])
//					let teamPerformances = Set(team.team.eventPerformances?.allObjects as! [TeamEventPerformance])
//					
//					let eventPerformance = Array(eventPerformances.intersection(teamPerformances)).first!
//					
//					team.statContext.setEventPerformanceStatistics(eventPerformance)
//					team.statContext.setMatchPerformanceStatistics((eventPerformance.matchPerformances!.allObjects as! [TeamMatchPerformance]))
//				} else {
//					let combinedMatchPerformances = team.team.eventPerformances?.reduce([TeamMatchPerformance]()) {matchPerformances,eventPerformance in
//						let newMatchPerformances = (eventPerformance as AnyObject).matchPerformances!?.allObjects as![TeamMatchPerformance]
//						var mutableMatchPerformances = matchPerformances
//						mutableMatchPerformances.append(contentsOf: newMatchPerformances)
//						return mutableMatchPerformances
//					}
//					
//					team.statContext.setEventPerformanceStatistics(nil)
//					team.statContext.setMatchPerformanceStatistics(combinedMatchPerformances)
//				}
//			}
		}
	}
	var currentTeamsToDisplay = [Team]() {
		didSet {
			tableView.reloadData()
		}
	}
	var selectedTeam: Team? {
		didSet {
			delegate?.selectedTeam(selectedTeam)
			NotificationCenter.default.post(name: Notification.Name(rawValue: "Different Team Selected"), object: self)
			if let sTeam = selectedTeam {
				if let index = currentTeamsToDisplay.index(where: {team in
					return team == sTeam
				}) {
					tableView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .none)
				}
			} else {
				tableView.deselectRow(at: tableView.indexPathForSelectedRow ?? IndexPath(), animated: false)
			}
		}
	}
	var selectedEvent: Event? {
		didSet {
			delegate?.selectedEvent?(selectedEvent)
			
			if let event = selectedEvent {
				//Set to nil, because the selected team might not be in the new event
				selectedTeam = nil
				currentEventTeams = (event.teamEventPerformances?.allObjects as! [TeamEventPerformance]).map({$0.team!})
				eventSelectionButton.setTitle(event.name, for: UIControlState())
			} else {
				currentEventTeams = teams
				eventSelectionButton.setTitle("All Teams", for: UIControlState())
				
				//Again set selected team to nil
				selectedTeam = nil
			}
		}
	}
	var teamEventPerformance: TeamEventPerformance? {
		get {
			if let team = selectedTeam {
				if let event = selectedEvent {
					//Get two sets
					let eventPerformances: Set<TeamEventPerformance> = Set(event.teamEventPerformances?.allObjects as! [TeamEventPerformance])
					let teamPerformances = Set(team.eventPerformances?.allObjects as! [TeamEventPerformance])
					
					//Combine the two sets to find the one in both
					let teamEventPerformance = Array(eventPerformances.intersection(teamPerformances)).first ?? nil
					
					return teamEventPerformance
				}
			}
			return nil
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teams = dataManager.localTeamRanking()

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
		selectedEvent = nil
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Deselect the current row if the detail vc is not showing at the moment
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

        let team = currentTeamsToDisplay[(indexPath as NSIndexPath).row]
        let localTeam = localTeams[localTeams.index(where: {$0.key == team.key})!]
		
		if isEditing {
			cell.teamLabel.text = "\(team.teamNumber!)"
			cell.statLabel.text = ""
		} else {
			cell.teamLabel.text = "Team \(team.teamNumber!)"
			if isSorted {
//				cell.statLabel.text = "\(teamListTeam.statCalculation!.value)"
			} else {
				cell.statLabel.text = ""
			}
		}
		
		cell.rankLabel.text = "\(dataManager.localTeamRanking().index(of: team)! as Int + 1)"
		
		if let image = teamImagesCache.object(forKey: team) {
			cell.frontImage.image = image
		} else {
			if let imageData = localTeam.frontImage {
				guard let uiImage = UIImage(data: imageData as Data) else {
					fatalError("Image Data Corrupted")
				}
				cell.frontImage.image = uiImage
				teamImagesCache.setObject(uiImage, forKey: team)
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
		return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
    }
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		return .none
	}

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
		//Move the team in the array and in Core Data
//		let movedTeamListTeam = currentEventTeams[(fromIndexPath as NSIndexPath).row]
//		currentEventTeams.remove(at: (fromIndexPath as NSIndexPath).row)
//		currentEventTeams.insert(movedTeamListTeam, at: (toIndexPath as NSIndexPath).row)
//		
//		do {
//			try dataManager.moveTeam((fromIndexPath as NSIndexPath).row, toIndex: (toIndexPath as NSIndexPath).row)
//		} catch {
//			NSLog("Unable to save team move: \(error)")
//		}
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
		if selectedEvent == nil {
			return true
		} else {
			return false
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let event = selectedEvent {
			return "Event: \(event.name!)"
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
//			editTeamsButton.title = "Edit Teams"
			
			tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)
		} else {
			self.setEditing(true, animated: true)
//			editTeamsButton.title = "Finish Editing"
			
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
		selectedEvent = nil
	}
	
	//MARK: - Searching

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "eventSelection" {
			let destinationVC = (segue.destination as! UINavigationController).topViewController as! EventPickerViewController
			destinationVC.delegate = self
		}
    }
	
	//MARK: - Sorting
	@IBAction func sortPressed(_ sender: UIBarButtonItem) {
//		sortVC.delegate = self
//		sortNavVC.modalPresentationStyle = .popover
//		sortNavVC.preferredContentSize = CGSize(width: 350, height: 300)
//		
//		let popoverVC = sortNavVC.popoverPresentationController
//		
//		popoverVC?.barButtonItem = sender
//		present(sortNavVC, animated: true, completion: nil)
	}
	
	func sortList(withStat stat: Int?, isAscending ascending: Bool) {
//		var statName = ""
//		if let stat = stat {
//			//Update stats in cache
//			for index in 0..<currentEventTeams.count {
//				currentEventTeams[index].statCalculation = currentEventTeams[index].statContext.possibleStats[stat]
//			}
//			
//			//Sort
//			let currentTeams = currentEventTeams
//			currentSortedTeams = currentTeams.sorted() {team1,team2 in
//				let before = team1.statCalculation?.value ?? 0 > team2.statCalculation?.value ?? 0
//				statName = team1.statCalculation?.description ?? ""
//				if ascending {
//					return before
//				} else {
//					return !before
//				}
//			}
//			
//			isSorted = true
//		} else {
//			//Update stats in cache
//			for index in 0..<currentEventTeams.count {
//				currentEventTeams[index].statCalculation = nil
//			}
//			
//			statName = "Draft Board (Default)"
//			
//			isSorted = false
//		}
//		
//		Answers.logCustomEvent(withName: "Sort Team List", customAttributes: ["Stat":statName, "Ascending":ascending.description])
	}
	
	@IBAction func returnToTeamList(_ segue: UIStoryboardSegue) {
		
	}
	
	@IBAction func returningWithSegue(_ segue: UIStoryboardSegue) {
		
	}
}

extension TeamListTableViewController: EventSelection {
	func eventSelected(_ event: Event?) {
		selectedEvent = event
	}
	
	func currentEvent() -> Event? {
		return selectedEvent
	}
}

extension TeamListTableViewController: SortDelegate {
	func selectedStat(_ stat: Int?, isAscending: Bool) {
		sortList(withStat: stat, isAscending: isAscending)
	}
	
	func stats() -> [String] {
		return []
	}
}
