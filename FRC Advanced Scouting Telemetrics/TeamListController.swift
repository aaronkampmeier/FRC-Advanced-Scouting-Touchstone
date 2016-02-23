//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var regionalSelectionButton: UIButton!
    @IBOutlet weak var sideImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var teamList: UITableView!
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var driverExpLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var editTeamsButton: UIBarButtonItem!
    @IBOutlet weak var teamListToolbar: UIToolbar!
    @IBOutlet weak var statsButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var standsScoutingButton: UIBarButtonItem!
    
    let teamManager = TeamDataManager()
    var adjustsForToolbarInsets: UIEdgeInsets? = nil
    
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
    var searchResultTeams = [Team]()
    var sortedTeams = [Team]()
	var isSearching = false {
		didSet {
		if !isSearching {
			currentTeamsToDisplay = currentRegionalTeams
		}
		}
	}
	var isSorted = false {
		didSet {
		if !isSorted {
			currentTeamsToDisplay = currentRegionalTeams
		}
		}
	}
	
	var currentRegionalTeams: [Team] = [Team]() {
		didSet {
		currentTeamsToDisplay = currentRegionalTeams
		}
	}
	var currentTeamsToDisplay: [Team] = [Team]() {
		didSet {
		teamList.reloadData()
		}
	}
	
    var selectedTeam: Team? {
        didSet {
            collectionView.reloadData()
			
			if let _ = selectedRegional {
				standsScoutingButton.enabled = true
			} else {
				standsScoutingButton.enabled = false
			}
        }
    }
	
	var selectedRegional: Regional? {
		didSet {
		if let regional = selectedRegional {
			currentRegionalTeams = (regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance]).map({$0.team!})
		} else {
			currentRegionalTeams = teams
			standsScoutingButton.enabled = false
		}
		}
	}
	
	var teamRegionalPerformance: TeamRegionalPerformance? {
		get {
			if let team = selectedTeam {
				if let regional = selectedRegional {
					//Get two sets
					let regionalPerformances: Set<TeamRegionalPerformance> = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
					let teamPerformances = Set(team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
					
					//Combine the two sets to find the one in both
					let teamRegionalPerformance = Array(regionalPerformances.intersect(teamPerformances))[0]
					
					return teamRegionalPerformance
				}
			}
			return nil
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add responder for notification about a new team
        NSNotificationCenter.defaultCenter().addObserverForName("New Team", object: nil, queue: nil, usingBlock: addTeamFromNotification)
        //Add an observer to resort the team list
        NSNotificationCenter.defaultCenter().addObserverForName("New Sort Type", object: nil, queue: nil, usingBlock: sortList)
        
        //Create reusable cell
        teamList.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        
        //Create reusable header view
        teamList.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
        
        //Set the labels' default text
        weightLabel.text = ""
        driverExpLabel.text = ""
        
        //Hide the search bar's cancel button
        searchBar.showsCancelButton = false
		
		currentRegionalTeams = teams
        
        //Allow the teams to be selected even during editing
        teamList.allowsSelectionDuringEditing = true
        
        //Prevent the bottom table view cells from being covered by the toolbar
        adjustsForToolbarInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(teamListToolbar.frame), right: 0)
        teamList.contentInset = adjustsForToolbarInsets!
        teamList.scrollIndicatorInsets = adjustsForToolbarInsets!
        
        //Set the stats button to not selectable since there is no team selected
        statsButton.enabled = false
		standsScoutingButton.enabled = false
        
        //Set that the current team list is displaying the default order
        isDefault = true
        
        //Set collection view's data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Register cell for Collection View
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "teamCell")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "matchCell")
    }
    
    func addTeamFromNotification(notification:NSNotification) {
		isSearching = false
		isSorted = false
        selectedRegional = nil
		currentRegionalTeams = teams
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentTeamsToDisplay.count
		
        if isSearching {
            return searchResultTeams.count
        } else if isSorted {
            return sortedTeams.count
        } else {
            return teams.count
        }
    }
    
    /*<---- CELL FOR ROW AT INDEX PATH---->*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var teamDataArray = [Team]()
        
        //If there are search results, then display those
        if isSearching {
            teamDataArray = searchResultTeams
        } else if isSorted {
            teamDataArray = sortedTeams
        } else {
            teamDataArray = teams
        }
        
        //Testing with new rankedCell
        /*
        let cell = teamList.dequeueReusableCellWithIdentifier("rankedCell")
        
        let team = teamDataArray[indexPath.row]
        
        let rankLabel: UILabel = cell?.contentView.viewWithTag(10) as! UILabel
        let imageView: UIImageView = cell?.contentView.viewWithTag(2) as! UIImageView
        let teamLabel: UILabel = cell?.contentView.viewWithTag(3) as! UILabel
        
        rankLabel.text = "1."
        imageView.image = UIImage(named: "FRC-Logo")
        teamLabel.text = "Team \(team.teamNumber)"
        */
        
        
        let cell = teamList.dequeueReusableCellWithIdentifier("Cell")
        
        let team = currentTeamsToDisplay[indexPath.row]
        
        if editing {
            cell!.textLabel?.text = "\(team.teamNumber!)"
        } else {
            cell!.textLabel?.text = "Team \(team.teamNumber!)"
        }
        
        if let image = team.frontImage {
            cell!.imageView?.image = UIImage(data: image)
        } else {
            cell!.imageView?.image = UIImage(named: "FRC-Logo")
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Check if we are searching or not
        var teamDataArray = [Team]()
        if isSearching {
            teamDataArray = searchResultTeams
        } else if isSorted {
            teamDataArray = sortedTeams
        } else {
            teamDataArray = teams
        }
        
        selectedTeam = currentTeamsToDisplay[indexPath.row]
        
        teamNumberLabel.text = selectedTeam!.teamNumber
        
        weightLabel.text = "Weight: \(selectedTeam!.robotWeight!) lbs"
        
        driverExpLabel.text = "Driver Exp: \(selectedTeam!.driverExp!) yrs"
        
        //Populate the images, if there are images
        if let image = selectedTeam!.frontImage {
            frontImageView.image = UIImage(data: image)
        } else {
            frontImageView.image = nil
        }
        if let image = selectedTeam!.sideImage {
            sideImageView.image = UIImage(data: image)
        } else {
            sideImageView.image = nil
        }
        
        //Set the stats button to be selectable
        statsButton.enabled = true
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = teamList.dequeueReusableHeaderFooterViewWithIdentifier("Header")
        
        if isSorted {
            if let name = sortTypeName {
                
                header?.textLabel?.text = "Sorted Teams by: \(name)"
            } else {
                header?.textLabel?.text = "Sorted Teams"
            }
        } else if isDefault! {
            header?.textLabel?.text = "All Teams"
        } else {
            
        }
        
        return header
    }
    
    //Two functions to allow deletion of Teams from the Table View
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let _ = selectedRegional {
			return false
		} else {
			return true
		}
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //Remove the team and reload the table
            teamManager.deleteTeam(teams[indexPath.row])
            currentRegionalTeams.removeAtIndex(indexPath.row)
            teamList.reloadData()
        }
    }
    
    //Team List TableView Functions for editing:
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let _ = selectedRegional {
			return false
		} else {
			return true
		}
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return .None
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //Move the team in the array and in Core Data
        let movedTeam = teams[sourceIndexPath.row]
        currentRegionalTeams.removeAtIndex(sourceIndexPath.row)
        currentRegionalTeams.insert(movedTeam, atIndex: destinationIndexPath.row)
        
        do {
            try teamManager.moveTeam(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        } catch {
            NSLog("Unable to save team move: \(error)")
        }
    }
    //
    
    //Functions for the search bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //Set that we are searching
        isSearching = true
        
        //Show the cancel button
        searchBar.showsCancelButton = true
        
        //Give beginning data
        if isDefault! {
            searchResultTeams = currentRegionalTeams
        } else if isSorted {
            searchResultTeams = sortedTeams
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //Clear the previous search results
        searchResultTeams.removeAll()
        
        //Create a predicate
        var predicate: NSPredicate
        
        if searchText.characters.count == 0 {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "teamNumber contains %@", argumentArray: [searchText])
        }
        
        //Take each team and check if it meets the required criteria, then add it to the search results array
		for team in currentRegionalTeams {
			if predicate.evaluateWithObject(team) {
				searchResultTeams.append(team)
			}
		}
		
		/*
        if isDefault! {
            for team in teams {
                if predicate.evaluateWithObject(team) {
                    searchResultTeams.append(team)
                }
            }
        } else if isSorted {
            for team in sortedTeams {
                if predicate.evaluateWithObject(team) {
                    searchResultTeams.append(team)
                }
            }
        }
		*/
		
		currentTeamsToDisplay = searchResultTeams
        teamList.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false
        
        //Clear the text, dismiss the keyboard, and hide the cancel
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
        
        //Reload the team list table
        teamList.reloadData()
    }
    //
    
    //Function for setting the editing of the teams
    @IBAction func editTeamsPressed(sender: UIBarButtonItem) {
        //Turn off searching if necessary
        if isSearching {
            searchBarCancelButtonClicked(searchBar)
        }
        
        teamList.beginUpdates()
        //When the edit button is pressed...
        if self.editing {
            //Stop editing
            self.setEditing(false, animated: true)
            //Change the label back
            editTeamsButton.title = "Edit Teams"
            //Hide the teamList's toolbar
            //teamListToolbar.hidden = true
            
            //Undo the scrolling insets
//            teamList.contentInset = UIEdgeInsetsZero
//            teamList.scrollIndicatorInsets = UIEdgeInsetsZero
            
            teamList.reloadRowsAtIndexPaths(teamList.indexPathsForVisibleRows!, withRowAnimation: .None)
        } else {
            self.setEditing(true, animated: true)
            editTeamsButton.title = "Finish Editing"
            
            //teamListToolbar.hidden = false
            
            //Fix the scrolling so the toolbar doesn't hide any cells
            teamList.contentInset = adjustsForToolbarInsets!
            teamList.scrollIndicatorInsets = adjustsForToolbarInsets!
            
            teamList.reloadRowsAtIndexPaths(teamList.indexPathsForVisibleRows!, withRowAnimation: .None)
        }
        teamList.endUpdates()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        teamList.setEditing(editing, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "statsSegue" {
            let destinationVC = segue.destinationViewController as! StatsVC
            
            destinationVC.team = selectedTeam!
		} else if segue.identifier == "pickARegional" {
			(segue.destinationViewController as! RegionalPickerViewController).teamListController = self
		} else if segue.identifier == "standsScouting" {
			let destinationVC = segue.destinationViewController as! StandsScoutingViewController
			destinationVC.teamPerformance = teamRegionalPerformance
		}
    }
    
    @IBAction func sortPressed(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Popovers", bundle: nil)
        let sortVC = storyboard.instantiateViewControllerWithIdentifier("SortVC") as! SortVC
        
        sortVC.modalPresentationStyle = .Popover
        sortVC.preferredContentSize = CGSizeMake(300, 300)
        
        //Tell the sort view controller the current sortType
        sortVC.currentSortType = sortType
        
        let popoverVC = sortVC.popoverPresentationController
        
        popoverVC?.permittedArrowDirections = .Up
        popoverVC?.delegate = self
        popoverVC?.barButtonItem = sender
        presentViewController(sortVC, animated: true, completion: nil)
    }
    
    
    //<---FUNCTIONALITY FOR SORTING THE TEAM LIST--->
    //TEMPORARY (Actually maybe not anymore...)
    var sortType: StatType?
    var isAscending: Bool?
    var isDefault: Bool?
    var sortTypeName: String?
    
    func sortList(notification: NSNotification) {
        //Retrieve the statType used for sorting and the direction for sorting from the notification's UserInfo
        sortType = notification.userInfo!["SortType"] as? StatType
        sortTypeName = sortType?.name
        isAscending = notification.userInfo!["Ascending"] as? Bool
        isDefault = notification.userInfo!["DraftBoardDefault"] as? Bool
        
        //Filter all the teams to only include ones with stats of the specific type used for soting
        sortedTeams = teams.filter(initialSorting)
        
        //Sort the teams
        sortedTeams.sortInPlace(compareTeamsSats)
        
        //Compensate for ascending or descending
        if let a = isAscending {
            if !a {
                sortedTeams = sortedTeams.reverse()
            }
        }
        
        //Sets if the user is sorting the list
        if let d = isDefault {
            if d {
                isSorted = false
                sortType = nil
            } else {
                isSorted = true
            }
        } else {
            isSorted = true
        }
        
        teamList.reloadData()
    }
    
    func initialSorting(team: Team) -> Bool {
        if ((team.stats?.allObjects as! [Stat]).filter() {
            if $0.statType == sortType {
                return true
            } else {
                return false
            }
        }).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func compareTeamsSats(firstTeam: Team, secondTeam: Team) -> Bool {
        //Get the values for comparison from the stats in both team
        let firstValue = (firstTeam.stats?.allObjects as! [Stat]).filter() {
            if $0.statType == sortType {
                return true
            } else {
                return false
            }
        }[0].value as! Double
        let secondValue = (secondTeam.stats?.allObjects as! [Stat]).filter() {
            if $0.statType == sortType {
                return true
            } else {
                return false
            }
        }[0].value as! Double
        
        return firstValue > secondValue
    }
    
    //Functionality for the Segemented Control
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
    }
    
    //---FUNCTIONS FOR GAME STATS AND SHOT CHART---
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let performance = teamRegionalPerformance {
			return (performance.matchPerformances?.count)! * 6 + (performance.matchPerformances?.count)!
		}
		
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //Get the matches for selected team
		let matches: [Match] = (teamRegionalPerformance?.matchPerformances!.allObjects as! [TeamMatchPerformance]).map({$0.match!})
		
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("teamTrialCell", forIndexPath: indexPath) as! GameStatsCollectionViewCell
        if indexPath.item % 7 == 0 {
            let matchNumber = matches[indexPath.item/7].matchNumber
            //Set the matches label
            let label = cell.label
            label.text = "\(matchNumber!)"
            
            //Make sure the background color is white
            cell.contentView.backgroundColor = nil
            label.textColor = UIColor(white: 0, alpha: 1)
        } else if indexPath.item % 8 == 0 || indexPath.item == 1 {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else if indexPath.item % 9 == 0 || indexPath.item == 2 {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			
			let filteredTeams = (matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 2})
			
			let matchPerformance = filteredTeams.first
			cell.label.text = (matchPerformance?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			
//			if filteredTeams.count > 0 {
//				cell.label.text = (filteredTeams[0].regionalPerformance?.valueForKey("team") as! Team).teamNumber
//			} else {
//				cell.label.text = nil
//			}
			
			//cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 2})[0]).regionalPerformance?.valueForKey("team") as! Team).teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else if indexPath.item % 10 == 0 || indexPath.item == 3 {
            cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
            cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else if indexPath.item % 11 == 0 || indexPath.item == 4 {
            cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			
            cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else if indexPath.item % 12 == 0 || indexPath.item == 5 {
            cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 2})[safe: 0])?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else if indexPath.item % 13 == 0 || indexPath.item == 6 {
            cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
            cell.label.textColor = UIColor(white: 1, alpha: 1)
        } else {
            cell.label.text = nil
            cell.contentView.backgroundColor = nil
        }
        
        return cell
    }
	
	func didChooseRegional(regional: Regional?) {
		selectedRegional = regional
		
		if let regional = regional {
			regionalSelectionButton.setTitle(regional.name, forState: .Normal)
		} else {
			regionalSelectionButton.setTitle("All Teams", forState: .Normal)
		}
	}
}


//extension TeamListController: UICollectionViewDelegateFlowLayout {
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        if indexPath.item % 7 == 0 {
//            return CGSize(width: 100, height: 50)
//        } else {
//            return CGSize(width: 50, height: 50)
//        }
//    }
//}