//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import NYTPhotoViewer

class TeamListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	@IBOutlet weak var regionalSelectionButton: UIButton!
	@IBOutlet weak var frontImageButton: UIButton!
	@IBOutlet weak var sideImageButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var teamList: UITableView!
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var driverExpLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var editTeamsButton: UIBarButtonItem!
    @IBOutlet weak var teamListToolbar: UIToolbar!
	@IBOutlet weak var standsScoutingButton: UIBarButtonItem!
	@IBOutlet weak var segmentControl2: UISegmentedControl!
	@IBOutlet weak var updateButton: UIBarButtonItem!
	
	var frontImage: TeamImagePhoto? {
		didSet {
			frontImageButton.setImage(frontImage?.image, forState: .Normal)
		}
	}
	
	var sideImage: TeamImagePhoto? {
		didSet {
			sideImageButton.setImage(sideImage?.image, forState: .Normal)
		}
	}
    
    let teamManager = TeamDataManager()
    var adjustsForToolbarInsets: UIEdgeInsets? = nil
	//Child View COntrollers
	var currentChildVC: UIViewController?
	var gameStatsController: GameStatsController?
	var shotChartController: ShotChartViewController?
	var statsViewController: StatsVC?
	var sortVC: SortVC!
	var teamDetailVC: UIViewController?
	var matchOverviewVC: MatchOverviewViewController?
    
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
	var searchBase = [TeamCache]()
    var searchResultTeams = [TeamCache]()
	var isSearching = false {
		didSet {
		if !isSearching {
			searchBase.removeAll()
			currentTeamsToDisplay = currentRegionalTeams
		} else {
			searchBase = currentTeamsToDisplay
		}
		}
	}
	var isSorted = false {
		didSet {
		if !isSorted {
			currentTeamsToDisplay = currentRegionalTeams
			currentSortedTeams = nil
		} else {
			isSearching = false
			currentTeamsToDisplay = currentSortedTeams!
		}
		}
	}
	var currentSortedTeams: [TeamCache]?
	
	//A structure with sub-structures to cache data about teams and their stats
	class TeamCache {
		let team: Team
		var statContextCache: StatContextCache = StatContextCache()
		
		init(team: Team) {
			self.team = team
			statContextCache.statContext.setTeamStatistics(team)
		}
		
		struct StatContextCache {
			var statContext: StatContext = StatContext()
			var calculationCache: StatCalculationCache?
			
			struct StatCalculationCache {
				let calculation: StatCalculation
				let value: Double
				let name: String
				
				init(statCalculation calculation: StatCalculation) {
					self.calculation = calculation
					value = calculation.value
					name = calculation.description
				}
			}
		}
	}
	
	var currentlyEditingTeams = false
	
	var currentRegionalTeams: [TeamCache] = [TeamCache]() {
		didSet {
		currentTeamsToDisplay = currentRegionalTeams
		}
		
		willSet {
		//Reset the stat contexts in the team caches
		for index in 0..<newValue.count {
			var context: StatContext = newValue[index].statContextCache.statContext
			if let regional = selectedRegional {
				let regionalPerformances = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
				let teamPerformances = Set(newValue[index].team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
				
				let regionalPerformance = Array(regionalPerformances.intersect(teamPerformances)).first!
				
				context.setRegionalPerformanceStatistics(regionalPerformance)
				context.setMatchPerformanceStatistics(regionalPerformance.matchPerformances!.allObjects as! [TeamMatchPerformance])
			} else {
				let combinedMatchPerformances = newValue[index].team.regionalPerformances?.reduce([TeamMatchPerformance]()) {matchPerformances,regionalPerformance in
					let newMatchPerformances = regionalPerformance.matchPerformances!?.allObjects as![TeamMatchPerformance]
					var mutableMatchPerformances = matchPerformances
					mutableMatchPerformances.appendContentsOf(newMatchPerformances)
					return mutableMatchPerformances
				}
				context.setRegionalPerformanceStatistics(nil)
				context.setMatchPerformanceStatistics(combinedMatchPerformances)
			}
			newValue[index].statContextCache.statContext = context
		}
		}
	}
	var currentTeamsToDisplay: [TeamCache] = [TeamCache]() {
		didSet {
		teamList.reloadData()
		}
	}
	
    var selectedTeamCache: TeamCache? {
        didSet {
		//Reload the team's detail view
		gameStatsController?.selectedNewThing(teamRegionalPerformance)
		
		if teamRegionalPerformance != nil {
			setSelectedSegment(0)
			segmentSelected(0, sender: nil)
		} else {
			setSelectedSegment(-1)
			segmentSelected(-1, sender: nil)
		}
		
		if selectedRegional != nil && selectedTeamCache != nil {
			standsScoutingButton.enabled = true
		} else {
			standsScoutingButton.enabled = false
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("Different Team Selected", object: self)
		}
    }
	
	var selectedRegional: Regional? {
		didSet {
		isSorted = false
		setSelectedSegment(-1)
		segmentSelected(-1, sender: nil)
		if let regional = selectedRegional {
			//Set to nil, because the selected team might not be in the new regional
			selectedTeamCache = nil
			currentRegionalTeams = (regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance]).map({TeamCache(team: $0.team!)})
			regionalSelectionButton.setTitle(regional.name, forState: .Normal)
			
			segmentControl.setEnabled(true, forSegmentAtIndex: 0)
			segmentControl.setEnabled(true, forSegmentAtIndex: 1)
		} else {
			currentRegionalTeams = teams.map() {TeamCache(team: $0)}
			regionalSelectionButton.setTitle("All Teams", forState: .Normal)
			//Set the same team as before
			let team = selectedTeamCache
			selectedTeamCache = team
			
			segmentControl.setEnabled(false, forSegmentAtIndex: 0)
			segmentControl.setEnabled(false, forSegmentAtIndex: 1)
		}
		}
	}
	
	var teamRegionalPerformance: TeamRegionalPerformance? {
		get {
			if let teamCache = selectedTeamCache {
				if let regional = selectedRegional {
					//Get two sets
					let regionalPerformances: Set<TeamRegionalPerformance> = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
					let teamPerformances = Set(teamCache.team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
					
					//Combine the two sets to find the one in both
					let teamRegionalPerformance = Array(regionalPerformances.intersect(teamPerformances)).first!
					
					return teamRegionalPerformance
				}
			}
			return nil
		}
	}
	
	//MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add responder for notification about a new team
        NSNotificationCenter.defaultCenter().addObserverForName("New Team", object: nil, queue: nil, usingBlock: addTeamFromNotification)
		
		//Add observer for if the app can be updated
		NSNotificationCenter.defaultCenter().addObserverForName("UpdateIsAvailable", object: nil, queue: nil) { notification in
			let userInfo = notification.userInfo
			let isUpdateAvailable = userInfo!["isAvailable"] as! Bool
			
			if isUpdateAvailable {
				self.updateButton.enabled = true
			} else {
				self.updateButton.enabled = false
			}
		}
		
		//Add an observer to update the table if new changes are merged in
//		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncer:NewChangesMerged", object: nil, queue: nil) {notification in
//			self.teamList.reloadData()
//		}
		
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
		
		selectedRegional = nil
        
        //Allow the teams to be selected even during editing
        teamList.allowsSelectionDuringEditing = true
        
        //Prevent the bottom table view cells from being covered by the toolbar
        adjustsForToolbarInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGRectGetHeight(teamListToolbar.frame), right: 0)
        teamList.contentInset = adjustsForToolbarInsets!
        teamList.scrollIndicatorInsets = adjustsForToolbarInsets!
        
        //Set the stands scouting button to not selectable since there is no team selected
		standsScoutingButton.enabled = false
		
		//Get the child view controllers
		gameStatsController = (storyboard?.instantiateViewControllerWithIdentifier("gameStatsCollection") as! GameStatsController)
		shotChartController = (storyboard?.instantiateViewControllerWithIdentifier("shotChart") as! ShotChartViewController)
		statsViewController = (storyboard?.instantiateViewControllerWithIdentifier("statsView") as! StatsVC)
		teamDetailVC = storyboard?.instantiateViewControllerWithIdentifier("teamDetail")
		matchOverviewVC = (storyboard?.instantiateViewControllerWithIdentifier("matchOverview") as! MatchOverviewViewController)
		
		sortVC = storyboard!.instantiateViewControllerWithIdentifier("statsSortView") as! SortVC
		
		//Set the images(buttons) content sizing property
		frontImageButton.imageView?.contentMode = .ScaleAspectFit
		sideImageButton.imageView?.contentMode = .ScaleAspectFit
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//Move initially to the game stats
		if currentChildVC != gameStatsController {
			cycleFromViewController(childViewControllers.first!, toViewController: gameStatsController!)
		}
		
		if let selectedIndexPath = teamList.indexPathForSelectedRow {
			teamList.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
			tableView(teamList, didSelectRowAtIndexPath: selectedIndexPath)
		}
	}
	
	func cycleFromViewController(oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMoveToParentViewController(nil)
		addChildViewController(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transitionFromViewController(oldVC, toViewController: newVC, duration: 0, options: .TransitionNone, animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMoveToParentViewController(self); self.currentChildVC = newVC})
	}
    
    func addTeamFromNotification(notification:NSNotification) {
		isSearching = false
		isSorted = false
        selectedRegional = nil
    }
	
	//MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentTeamsToDisplay.count
    }
    
    /*<---- CELL FOR ROW AT INDEX PATH---->*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//NSLog("Loading Cell")
		
        let cell = teamList.dequeueReusableCellWithIdentifier("rankedCell") as! TeamListTableViewCell
        
        let teamCache = currentTeamsToDisplay[indexPath.row]
        
        if editing {
			cell.teamLabel.text = "\(teamCache.team.teamNumber!)"
			cell.statLabel.text = ""
        } else {
            cell.teamLabel.text = "Team \(teamCache.team.teamNumber!)"
			if isSorted {
				cell.statLabel.text = "\((teamCache.statContextCache.calculationCache?.value)!)"
			} else {
				cell.statLabel.text = ""
			}
        }
		
		cell.rankLabel.text = "\(try! TeamDataManager().getDraftBoard().indexOf(teamCache.team)! as Int + 1)"
        
        if let image = teamCache.team.frontImage {
			cell.frontImage.image = UIImage(data: image)
			//cell!.imageView?.image = UIImage(data: image)
        } else {
			cell.frontImage.image = UIImage(named: "FRC-Logo")
			//cell!.imageView?.image = UIImage(named: "FRC-Logo")
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedTeamCache = currentTeamsToDisplay[indexPath.row]
        
        teamNumberLabel.text = selectedTeamCache!.team.teamNumber
        
        weightLabel.text = "Weight: \(selectedTeamCache!.team.robotWeight ?? 0) lbs"
        
        driverExpLabel.text = "Driver Exp: \(selectedTeamCache!.team.driverExp ?? 0) yrs"
        
        //Populate the images, if there are images
        if let image = selectedTeamCache!.team.frontImage {
			frontImage = TeamImagePhoto(image: UIImage(data: image), attributedCaptionTitle: NSAttributedString(string: "Team \(selectedTeamCache!.team.teamNumber!): Front Image"))
        } else {
			frontImage = nil
        }
        if let image = selectedTeamCache!.team.sideImage {
			sideImage = TeamImagePhoto(image: UIImage(data: image), attributedCaptionTitle: NSAttributedString(string: "Team \(selectedTeamCache!.team.teamNumber!): Side Image"))
        } else {
            sideImage = nil
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = teamList.dequeueReusableHeaderFooterViewWithIdentifier("Header")
		
		if let regional = selectedRegional {
			header?.textLabel?.text = "Regional: \(regional.name!)"
		} else {
			header?.textLabel?.text = "All Teams"
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
		let movedTeamCache = currentRegionalTeams[sourceIndexPath.row]
        currentRegionalTeams.removeAtIndex(sourceIndexPath.row)
        currentRegionalTeams.insert(movedTeamCache, atIndex: destinationIndexPath.row)
        
        do {
            try teamManager.moveTeam(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        } catch {
            NSLog("Unable to save team move: \(error)")
        }
    }
    //
	
	//MARK: Search Bar
    //Functions for the search bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //Set that we are searching
        isSearching = true
        
        //Show the cancel button
        searchBar.showsCancelButton = true
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
		for teamCache in searchBase {
			if predicate.evaluateWithObject(teamCache.team) {
				searchResultTeams.append(teamCache)
			}
		}
		
		currentTeamsToDisplay = searchResultTeams
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearching = false
        
        //Clear the text, dismiss the keyboard, and hide the cancel
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
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
            
            teamList.reloadRowsAtIndexPaths(teamList.indexPathsForVisibleRows!, withRowAnimation: .None)
        } else {
            self.setEditing(true, animated: true)
            editTeamsButton.title = "Finish Editing"
            
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
        
        if segue.identifier == "pickARegional" {
			(segue.destinationViewController as! RegionalPickerViewController).teamListController = self
		} else if segue.identifier == "standsScouting" {
			let destinationVC = segue.destinationViewController as! StandsScoutingViewController
			destinationVC.teamPerformance = teamRegionalPerformance
		}
    }
	
	@IBAction func returningWithSegue(segue: UIStoryboardSegue) {
		
	}
	
	@IBAction func returnToTeamList(segue: UIStoryboardSegue) {
		
	}
	
	//MARK: Sorting
    @IBAction func sortPressed(sender: UIBarButtonItem) {
		sortVC.statContext = currentTeamsToDisplay.first?.statContextCache.statContext
        sortVC.modalPresentationStyle = .Popover
        sortVC.preferredContentSize = CGSizeMake(350, 350)
        
        let popoverVC = sortVC.popoverPresentationController
        
        popoverVC?.delegate = self
        popoverVC?.barButtonItem = sender
        presentViewController(sortVC, animated: true, completion: nil)
    }
    
    
    //<---FUNCTIONALITY FOR SORTING THE TEAM LIST--->
    
	func sortList(withStat stat: Int?, isAscending ascending: Bool) {
		var statName = ""
		if let stat = stat {
			//Update stats in cache
			currentlyEditingTeams = true
			for index in 0..<currentRegionalTeams.count {
				currentRegionalTeams[index].statContextCache.calculationCache = TeamCache.StatContextCache.StatCalculationCache(statCalculation: currentRegionalTeams[index].statContextCache.statContext.possibleStats[stat])
			}
			currentlyEditingTeams = false
			
			//Sort
			let currentTeams = currentRegionalTeams
			currentSortedTeams = currentTeams.sort() {team1,team2 in
				let before = team1.statContextCache.calculationCache?.value > team2.statContextCache.calculationCache?.value
				statName = team1.statContextCache.calculationCache?.name ?? ""
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
				currentRegionalTeams[index].statContextCache.calculationCache = nil
			}
			
			statName = "Draft Board (Default)"
			
			isSorted = false
		}
		
		Answers.logCustomEventWithName("Sort Team List", customAttributes: ["Stat":statName, "Ascending":ascending.hashValue])
    }
	
	//MARK: Segmented Control
    //Functionality for the Segemented Control
    @IBAction func segmentChanged(sender: UISegmentedControl) {
		//Check which row control it is
		if sender == segmentControl {
			segmentControl2.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex, sender: sender)
		} else if sender == segmentControl2 {
			segmentControl.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex + 3, sender: sender)
		}
    }
	
	func segmentSelected(segment: Int, sender: UISegmentedControl?) {
		switch segment {
		case 0, -1:
			//Check to see if the current view controller is the same as the game stats controller. If it is different, than switch to it.
			if currentChildVC != gameStatsController {
				cycleFromViewController(currentChildVC!, toViewController: gameStatsController!)
			}
		case 1:
			if selectedRegional == nil {
				//Haha, nope. You aren't in a regional
				setSelectedSegment(0)
			} else {
				//Check to see if the current view controller is the same as the shot chart controller. If it is different, than switch to it.
				if currentChildVC != shotChartController {
					cycleFromViewController(currentChildVC!, toViewController: shotChartController!)
				}
				
				//Present Alert asking for the match the user would like to view
				let alert = UIAlertController(title: "Select Match", message: "Select a match to see its shots.", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "Overall", style: .Default, handler: {_ in self.shotChartController?.selectedMatchPerformance(nil)}))
				let sortedMatchPerformances = (teamRegionalPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance] ?? [TeamMatchPerformance]()).sort() {$0.0.match?.matchNumber?.integerValue < $0.1.match?.matchNumber?.integerValue}
				for matchPerformance in sortedMatchPerformances {
					alert.addAction(UIAlertAction(title: String(matchPerformance.match!.matchNumber!), style: .Default, handler: {_ in self.shotChartController!.selectedMatchPerformance(matchPerformance)}))
				}
				presentViewController(alert, animated: true, completion: nil)
			}
		case 2:
			cycleFromViewController(currentChildVC!, toViewController: statsViewController!)
		case 3:
			setUpTeamDetailController(teamDetailVC!)
			cycleFromViewController(currentChildVC!, toViewController: teamDetailVC!)
		case 4:
			cycleFromViewController(currentChildVC!, toViewController: matchOverviewVC!)
		default:
			break
		}
	}
	
	func setSelectedSegment(segment: Int) {
		if segment == -1 {
			segmentControl.selectedSegmentIndex = -1
			segmentControl2.selectedSegmentIndex = -1
		} else if segment <= 2 {
			segmentControl.selectedSegmentIndex = segment
			segmentControl2.selectedSegmentIndex = -1
		} else {
			segmentControl2.selectedSegmentIndex = segment - 3
			segmentControl.selectedSegmentIndex = -1
		}
	}
	
	func didChooseRegional(regional: Regional?) {
		selectedRegional = regional
	}
	
	@IBAction func updateButtonPressed(sender: UIBarButtonItem) {
		(UIApplication.sharedApplication().delegate as! AppDelegate).checkForUpdate(forceful: true)
	}
	
	//Presenting modal view of more Team details
	@IBAction func showMoreDetailsPressed(sender: UIButton) {
		
	}
	
	func setUpTeamDetailController(detailController: UIViewController) {
//		let detailTable = detailController.view.viewWithTag(1) as! UITableView
//		let dataAndDelegate = TeamDetailTableViewDataAndDelegate(withTableView: detailTable)
//		detailTable.dataSource = dataAndDelegate
//		detailTable.delegate = dataAndDelegate
//		
//		dataAndDelegate.setUpWithTeam(selectedTeamCache?.team)
		
		let detailsLabel = detailController.view.viewWithTag(2) as! UILabel
		var detailString = ""
		detailString.appendContentsOf("Height: \((selectedTeamCache?.team.height) ?? 0)")
		detailString.appendContentsOf("\nDrive Train: \(selectedTeamCache?.team.driveTrain ?? "")")
		detailString.appendContentsOf("\nVision Tracking Rating: \(selectedTeamCache?.team.visionTrackingRating ?? 0)")
		detailString.appendContentsOf("\nClimber: \(selectedTeamCache?.team.climber?.boolValue ?? false)")
		detailString.appendContentsOf("\nHigh Goal: \(selectedTeamCache?.team.highGoal?.boolValue ?? false)")
		detailString.appendContentsOf("\nLow Goal: \(selectedTeamCache?.team.lowGoal?.boolValue ?? false)")
		detailString.appendContentsOf("\nAutonomous Defenses Able To Cross: ")
		for defense in selectedTeamCache?.team.autonomousDefensesAbleToCross?.allObjects as? [Defense] ?? [Defense]() {
			detailString.appendContentsOf(" \(defense.defenseName!),")
		}
		detailString.appendContentsOf("\nAutonomous Defenses Able To Shoot From: ")
		for defense in selectedTeamCache?.team.autonomousDefensesAbleToShoot?.allObjects as? [Defense] ?? [Defense]() {
			detailString.appendContentsOf(" \(defense.defenseName!),")
		}
		detailString.appendContentsOf("\nDefenses Able To Cross: ")
		for defense in selectedTeamCache?.team.defensesAbleToCross?.allObjects as? [Defense] ?? [Defense]() {
			detailString.appendContentsOf(" \(defense.defenseName!),")
		}
		
		detailsLabel.text = detailString
		
		let notesView = detailController.view.viewWithTag(3) as! UITextView
		notesView.text = selectedTeamCache?.team.notes
		notesView.layer.cornerRadius = 5
		notesView.layer.borderWidth = 3
		notesView.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		notesView.delegate = self
	}
	
	//MARK: Displaying full screen photos
	@IBAction func selectedImage(sender: UIButton) {
		let photo: NYTPhoto
		var photosArray: [NYTPhoto] = []
		switch sender {
		case frontImageButton:
			if let image = frontImage {
				photo = image
			} else {return}
		case sideImageButton:
			if let image = sideImage {
				photo = image
			} else {return}
		default:
			return
		}
		
		if let image = frontImage {
			photosArray.append(image)
		}
		if let image = sideImage {
			photosArray.append(image)
		}
		
		let photoVC = NYTPhotosViewController(photos: photosArray, initialPhoto: photo, delegate: self)
		presentViewController(photoVC, animated: true, completion: nil)
		Answers.logContentViewWithName("Team Robot Images", contentType: "Photo", contentId: nil, customAttributes: ["Team":"\(selectedTeamCache?.team.teamNumber ?? "")"])
	}
}

class TeamImagePhoto: NSObject, NYTPhoto {
	var image: UIImage?
	var imageData: NSData?
	var placeholderImage: UIImage?
	var attributedCaptionTitle: NSAttributedString?
	var attributedCaptionCredit: NSAttributedString?
	var attributedCaptionSummary: NSAttributedString?
	
	init(image: UIImage?, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString) {
		self.image = image
		self.imageData = imageData
		self.attributedCaptionTitle = attributedCaptionTitle
	}
}

extension TeamListController: UITextViewDelegate {
	func textViewDidEndEditing(textView: UITextView) {
		selectedTeamCache?.team.notes = textView.text
		teamManager.commitChanges()
	}
}

extension TeamListController: UIPopoverPresentationControllerDelegate {
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
		sortList(withStat: sortVC.selectedStat, isAscending: sortVC.isAscending)
	}
}

extension TeamListController: NYTPhotosViewControllerDelegate {
	func photosViewController(photosViewController: NYTPhotosViewController, captionViewForPhoto photo: NYTPhoto) -> UIView? {
		return nil
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, referenceViewForPhoto photo: NYTPhoto) -> UIView? {
		if let photo = photo as? TeamImagePhoto {
			if photo == frontImage {
				return frontImageButton
			} else if photo == sideImage {
				return sideImageButton
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, titleForPhoto photo: NYTPhoto, atIndex photoIndex: UInt, totalPhotoCount: UInt) -> String? {
		return nil
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, maximumZoomScaleForPhoto photo: NYTPhoto) -> CGFloat {
		return CGFloat(2)
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
		NSLog("Completed Action: \(activityType ?? "Unknown")")
		Answers.logShareWithMethod(activityType, contentName: "Team Photos", contentType: "Photo", contentId: nil, customAttributes: nil)
	}
}

class TeamDetailTableViewDataAndDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
	let tableView: UITableView
	var currentTeam: Team?
	
	init(withTableView tableView: UITableView) {
		self.tableView = tableView
//		tableView.rowHeight = UITableViewAutomaticDimension
//		tableView.estimatedRowHeight = 44
	}
	
	func setUpWithTeam(team: Team?) {
		currentTeam = team
		tableView.reloadData()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("cell")
		
		switch indexPath.row {
		case 0:
			cell?.textLabel?.text = "Height"
			cell?.detailTextLabel?.text = String(currentTeam?.height ?? "")
		case 1:
			cell?.textLabel?.text = "Drive Train"
			cell?.detailTextLabel?.text = currentTeam?.driveTrain
		case 2:
			cell?.textLabel?.text = "Vision Tracking Rating"
			cell?.detailTextLabel?.text = String(currentTeam?.visionTrackingRating ?? "")
		case 3:
			let largeCell = tableView.dequeueReusableCellWithIdentifier("largeCell") as! TeamDetailLargeCell
			largeCell.mainLabel?.text = "Autonomous Defenses Able To Cross"
			var stringOfDefenses = ""
			for defense in currentTeam?.autonomousDefensesAbleToCross?.allObjects as! [Defense] {
				stringOfDefenses.appendContentsOf("\n\(defense.defenseName!)")
			}
			largeCell.detailLabel?.text = stringOfDefenses
			
			cell = largeCell
		case 4:
			let largeCell = tableView.dequeueReusableCellWithIdentifier("largeCell") as! TeamDetailLargeCell
			largeCell.mainLabel?.text = "Defenses Able To Cross"
			var stringOfDefenses = ""
			for defense in currentTeam?.defensesAbleToCross?.allObjects as! [Defense] {
				stringOfDefenses.appendContentsOf("\n\(defense.defenseName!)")
			}
			largeCell.detailLabel?.text = stringOfDefenses
			
			cell = largeCell
		default:
			break
		}
		
		return cell!
	}
}

class TeamDetailLargeCell: UITableViewCell {
	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
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