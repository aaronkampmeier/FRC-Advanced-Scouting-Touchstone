//
//  TeamListTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

protocol TeamSelectionDelegate: class {
	func selectedTeam(_ team: ObjectPair<Team, LocalTeam>?)
	func selectedEvent(_ event: Event?)
}

class TeamListTableViewController: UITableViewController, UISearchControllerDelegate {
	@IBOutlet weak var eventSelectionButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
	
	var searchController: UISearchController!
	weak var delegate: TeamSelectionDelegate?
	let dataManager = DataManager()
	let teamImagesCache = NSCache<Team, UIImage>()
	
    //Local Rank is not considered sorted
    var statToSortBy: String = Team.StatName.LocalRank.rawValue
	var isSorted = false {
		didSet {
			if isSorted {
				setEditing(false, animated: true)
                editButton.isEnabled = false
			} else {
				currentSortedTeams = nil
                editButton.isEnabled = true
			}
		}
	}
    var isSortingAscending: Bool = false
	var currentSortedTeams: [ObjectPair<Team, LocalTeam>]? {
		didSet {
			if let teams = currentSortedTeams {
				currentTeamsToDisplay = teams
			} else {
				currentTeamsToDisplay = currentEventTeams
			}
		}
	}
	
    var teams: [ObjectPair<Team, LocalTeam>] = []
	
	var currentEventTeams: [ObjectPair<Team,LocalTeam>] = [ObjectPair<Team,LocalTeam>]() {
		didSet {
			currentTeamsToDisplay = currentEventTeams
		}
	}
	var currentTeamsToDisplay = [ObjectPair<Team,LocalTeam>]() {
		didSet {
			tableView.reloadData()
		}
	}
    
    
	var selectedTeam: ObjectPair<Team, LocalTeam>? {
		didSet {
			delegate?.selectedTeam(selectedTeam)
			NotificationCenter.default.post(name: Notification.Name(rawValue: "Different Team Selected"), object: self)
			if let sTeam = selectedTeam {
				if let index = currentTeamsToDisplay.index(where: {team in
					return team.universal == sTeam.universal
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
			delegate?.selectedEvent(selectedEvent)
			
			if let event = selectedEvent {
				//Set to nil, because the selected team might not be in the new event
                isSorted = false
                statToSortBy = Team.StatName.LocalRank.rawValue
                
				selectedTeam = nil
                currentEventTeams = ObjectPair<Team,LocalTeam>.fromArray(locals: dataManager.localTeamRanking(forEvent: event))!
				eventSelectionButton.setTitle(event.name, for: UIControlState())
			} else {
                isSorted = false
                statToSortBy = Team.StatName.LocalRank.rawValue
                
				currentEventTeams = teams
				eventSelectionButton.setTitle("All Teams", for: UIControlState())
				
				//Again set selected team to nil
				selectedTeam = nil
			}
		}
	}
	var teamEventPerformance: TeamEventPerformance? {
		get {
			if let team = selectedTeam?.universal {
				if let event = selectedEvent {
					return dataManager.eventPerformance(forTeam: team, inEvent: event)
				}
			}
			return nil
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTeams()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		(UIApplication.shared.delegate as! AppDelegate).teamListTableVC = self
		
		//Set up the searching capabilities and the search bar. At the time of coding, Storyboards do not support the new UISearchController, so this is done programatically.
		let searchResultsVC = storyboard?.instantiateViewController(withIdentifier: "teamListSearchResults") as! TeamListSearchResultsTableViewController
        searchResultsVC.teamListTableVC = self
		searchController = UISearchController(searchResultsController: searchResultsVC)
		searchController.searchResultsUpdater = searchResultsVC
		tableView.tableHeaderView = searchController.searchBar
		
		//Add responder for notification about a new team
		NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdatedTeams"), object: nil, queue: nil, using: updateForImport)
		
		tableView.allowsSelectionDuringEditing = true
		
		
		//Load in the beginning data
		selectedEvent = nil
    }
    
    func loadTeams() {
        let universalTeams = dataManager.localTeamRanking()
        let localTeams = UniversalToLocalConversion<Team, LocalTeam>(universalObjects: universalTeams).convertToLocal()
        teams = ObjectPair<Team,LocalTeam>.fromArrays(universals: universalTeams, locals: localTeams)!
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
		
        cell.teamLabel.text = "Team \(team.universal.teamNumber!)"
        if isSorted {
            let statDouble: Double
            if let stat = Team.StatName(rawValue: statToSortBy) {
                statDouble = team.universal.statValue(forStat: stat).numericValue
            } else if let stat = TeamEventPerformance.StatName(rawValue: statToSortBy) {
                statDouble = dataManager.eventPerformance(forTeam: team.universal, inEvent: selectedEvent!).statValue(forStat: stat).numericValue
            } else {
                statDouble = 0.0
            }
            cell.statLabel.text = "\(Double(round(statDouble*100)/100))"
        } else {
            cell.statLabel.text = ""
        }
		
        cell.rankLabel.text = "\(currentEventTeams.index(where: {$0.universal == team.universal})! as Int + 1)"
		
		if let image = teamImagesCache.object(forKey: team.universal) {
			cell.frontImage.image = image
		} else {
			if let imageData = team.local.frontImage {
				guard let uiImage = UIImage(data: imageData as Data) else {
					fatalError("Image Data Corrupted")
				}
				cell.frontImage.image = uiImage
				teamImagesCache.setObject(uiImage, forKey: team.universal)
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
		return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
		//Move the team in the array and in Core Data
        //TODO: Move a team in the ranking when the user moves it
        dataManager.moveTeam(from: fromIndexPath.row, to: toIndexPath.row, inEvent: selectedEvent)
        
        let movedTeam = currentEventTeams[fromIndexPath.row]
        if selectedEvent == nil {
            teams.remove(at: fromIndexPath.row)
            teams.insert(movedTeam, at: toIndexPath.row)
        }
        currentEventTeams.remove(at: fromIndexPath.row)
        currentEventTeams.insert(movedTeam, at: toIndexPath.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
		return true
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
        
        if editing {
            editButton.image = UIImage(named: "Edit Filled")
        } else {
            editButton.image = UIImage(named: "Edit")
        }
	}
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        if isEditing {
            setEditing(false, animated: true)
        } else {
            setEditing(true, animated: true)
        }
    }
	
	//MARK: -
	func updateForImport(_ notification: Notification) {
        self.loadTeams()
        self.selectedEvent = nil
        self.isSorted = false
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
        let sortNavVC = storyboard?.instantiateViewController(withIdentifier: "sortNav") as! UINavigationController
        let sortVC = sortNavVC.topViewController as! SortVC
		sortVC.delegate = self
		sortNavVC.modalPresentationStyle = .popover
		sortNavVC.preferredContentSize = CGSize(width: 350, height: 300)
		
		let popoverVC = sortNavVC.popoverPresentationController
		
		popoverVC?.barButtonItem = sender
		present(sortNavVC, animated: true, completion: nil)
	}
	
	func sortList(withStat statName: String, isAscending ascending: Bool) {
        self.isSortingAscending = ascending
        
        let teamStat = Team.StatName(rawValue: statName)
        let eventPerformanceStat = TeamEventPerformance.StatName(rawValue: statName)
        
        if let stat = teamStat {
            statToSortBy = stat.rawValue
            switch stat {
            case Team.StatName.LocalRank:
                isSorted = false
            default:
                let currentTeams = currentEventTeams
                currentSortedTeams = currentTeams.sorted {objectPair1, objectPair2 in
                    let isBefore = objectPair1.universal.statValue(forStat: stat).numericValue > objectPair2.universal.statValue(forStat: stat).numericValue
                    if ascending {
                        return !isBefore
                    } else {
                        return isBefore
                    }
                }
                
                isSorted = true
            }
        } else if let stat = eventPerformanceStat {
            statToSortBy = stat.rawValue
            
            let currentTeams = currentEventTeams
            currentSortedTeams = currentTeams.sorted {objectPair1, objectPair2 in
                let firstTeamEventPerformance: TeamEventPerformance = dataManager.eventPerformance(forTeam: objectPair1.universal, inEvent: selectedEvent!)
                let secondTeamEventPerformance: TeamEventPerformance = dataManager.eventPerformance(forTeam: objectPair2.universal, inEvent: selectedEvent!)
                
                let firstStatValue = firstTeamEventPerformance.statValue(forStat: stat).numericValue
                let secondStatValue = secondTeamEventPerformance.statValue(forStat: stat).numericValue
                
                if firstStatValue.isNaN {
                    return false
                } else if secondStatValue.isNaN {
                    return true
                }
                
                let isBefore = firstStatValue > secondStatValue
                if ascending {
                    return !isBefore
                } else {
                    return isBefore
                }
            }
            
            isSorted = true
        } else {
            assertionFailure()
        }
        
        
        
		Answers.logCustomEvent(withName: "Sort Team List", customAttributes: ["Stat":statName, "Ascending":ascending.description])
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
	func selectedStat(_ stat: String, isAscending: Bool) {
		sortList(withStat: stat, isAscending: isAscending)
	}
	
    ///Returns all the stats to be potentially sorted by. If there is a selected event, then also return stats for TeamEventPerformances.
	func statsToDisplay() -> [String] {
        return Team.StatName.allValues.map {$0.rawValue} + (selectedEvent != nil ? TeamEventPerformance.StatName.allValues.map {$0.rawValue} : [])
	}
    
    func currentStat() -> String {
        return statToSortBy
    }
    
    func isAscending() -> Bool {
        return isSortingAscending
    }
}
