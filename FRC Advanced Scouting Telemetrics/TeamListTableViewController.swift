//
//  TeamListTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSAuthUI
import RealmSwift

class EventSelectionTitleButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}

class TeamListTableViewController: UITableViewController, TeamListDetailDataSource {
    @IBOutlet weak var graphButton: UIBarButtonItem!
    @IBOutlet weak var eventSelectionButton: EventSelectionTitleButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var matchesButton: UIBarButtonItem!
    
    var searchController: UISearchController!
    let realmController = RealmController.realmController
    var teamImages = [String:UIImage]()
    var teamListSplitVC: TeamListSplitViewController {
        get {
            return splitViewController as! TeamListSplitViewController
        }
    }
    
    //Local Rank is not considered sorted
    var statToSortBy: String = Team.StatName.LocalRank.rawValue
    //Should move functionality in here to a setSortingState func
    var isSorted = false
    var isSortingAscending: Bool = false
    
    var isSearching = false
    
    //Is a hierarchy
    var currentEventTeams: [Team] = [Team]() {
        didSet {
            sortList(withStat: statToSortBy, isAscending: isSortingAscending)
        }
    }
    var currentSortedTeams: [Team] = [] {
        didSet {
//            currentTeamsToDisplay = currentSortedTeams
            self.updateSearchResults(for: searchController)
        }
    }
    //Searching would happen right in between here
    var currentTeamsToDisplay = [Team]() { //This is always eaxaclty the end what the table view will display
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedTeam: Team? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "Different Team Selected"), object: self)
            if let sTeam = selectedTeam {
                //Select row in table view
                if let index = currentTeamsToDisplay.index(where: {team in
                    return team == sTeam
                }) {
                    tableView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .none)
                }
            } else {
                tableView.deselectRow(at: tableView.indexPathForSelectedRow ?? IndexPath(), animated: false)
            }
            
            teamListSplitVC.teamListDetailVC.reloadData()
        }
    }
    var selectedEvent: Event? {
        didSet {
            //Set to nil, because the selected team might not be in the new event
            selectedTeam = nil
            
            statToSortBy = Team.StatName.LocalRank.rawValue
            currentEventTeams = realmController.teamRanking(selectedEvent)
            
            if let event = selectedEvent {
                eventSelectionButton.setTitle(event.name, for: UIControlState())
                
                matchesButton.isEnabled = true
                graphButton.isEnabled = true
            } else {
                eventSelectionButton.setTitle("All Teams", for: UIControlState())
                
                matchesButton.isEnabled = false
                graphButton.isEnabled = false
            }
            
            reloadEventRankerObserver()
            
            teamListSplitVC.teamListDetailVC.reloadData()
        }
    }
    var teamEventPerformance: TeamEventPerformance? {
        get {
            if let team = selectedTeam {
                if let event = selectedEvent {
                    return realmController.eventPerformance(forTeam: team, atEvent: event)
                }
            }
            return nil
        }
    }
    
    var generalRealmObserverToken: NotificationToken?
    var initialProgressNotification: NotificationToken?
    var eventsObserverToken: NotificationToken?
    var eventRankerObserverToken: NotificationToken? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        teamListSplitVC.teamListTableVC = self
        
        eventSelectionButton.widthAnchor.constraint(equalToConstant: CGFloat.greatestFiniteMagnitude - (navigationItem.leftBarButtonItem?.width)! - (navigationItem.rightBarButtonItem?.width)!)
        
        //Set up the searching capabilities and the search bar. At the time of coding, Storyboards do not support the new UISearchController, so this is done programatically.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedEvent?.isInvalidated ?? false {
            selectedEvent = nil
        }
        
        currentEventTeams = realmController.teamRanking(selectedEvent)
        if isSearching {
            //Upon returning to a search we won't update the teams and re-read from the model like normally. We will just use the original event teams for simplicity's sake.
//            self.updateSearchResults(for: searchController)
            self.navigationController?.setToolbarHidden(true, animated: true) //Set hidden if we are returning to a search
        } else {
//            currentEventTeams = realmController.teamRanking(selectedEvent)
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        
        //Deselect the current row if the detail vc is not showing at the moment
        if splitViewController?.isCollapsed ?? false {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        //Track if an event was added or deleted (redundant most of the time with the following team observer except for when an event doesn't have any teams)
        eventsObserverToken = realmController.generalRealm.objects(Event.self).observe {[weak self] eventsChanges in
            switch eventsChanges {
            case .update(_, let deletions,_,_):
                if deletions.count > 0 {
                    DispatchQueue.main.async {
                        self?.selectedEvent = nil
                    }
                }
            default:
                break
            }
        }
        //Add responder for notification about changes in the amount of teams
        generalRealmObserverToken = realmController.generalRealm.objects(Team.self).observe {[weak self] collectionChange in
            switch collectionChange {
            case .initial:
                break
            case .update(_, let deletions, let insertions, _):
                if insertions.count > 0 || deletions.count > 0 {
                    DispatchQueue.main.async {
                        if deletions.count > 0 {
                            self?.selectedEvent = nil
                        }
                        self?.currentEventTeams = RealmController.realmController.teamRanking(self?.selectedEvent)
                    }
                }
            case .error(let error):
                CLSNSLogv("Error observing general realm in team list table view: %@", getVaList([error as CVarArg]))
                Crashlytics.sharedInstance().recordError(error)
            }
        }
        
        //Add a monitor to check when all new information is downloaded
        initialProgressNotification = realmController.currentSyncUser?.session(for: realmController.syncedRealmURL!)?.addProgressNotification(for: .download, mode: .forCurrentlyOutstandingWork) {[weak self] progress in
            if progress.isTransferComplete {
                //It is complete, reload the data
                DispatchQueue.main.async {
                    self?.currentEventTeams = RealmController.realmController.teamRanking(self?.selectedEvent)
                }
            }
        }
        
        reloadEventRankerObserver()
    }
    
    func reloadEventRankerObserver() {
        //Add observer to listen for changes in the pick list
        eventRankerObserverToken = nil
        if let event = selectedEvent {
            if let eventRanker = realmController.getTeamRanker(forEvent: event) {
                self.eventRankerObserverToken = eventRanker.observe {[weak self] objectChange in
                    switch objectChange {
                    case .change(let changes):
                        DispatchQueue.main.async {
                            for change in changes {
                                if change.name == "pickedTeams" {
                                    //Reload all visible rows
                                    if let visibleRows = self?.tableView.indexPathsForVisibleRows {
                                        self?.tableView.reloadRows(at: visibleRows, with: UITableViewRowAnimation.none)
                                    }
                                }
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        generalRealmObserverToken?.invalidate()
        initialProgressNotification?.invalidate()
        eventsObserverToken?.invalidate()
        eventRankerObserverToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        self.teamImages.removeAll()
    }
    
    //MARK: - TeamListDetailDataSource
    func team() -> Team? {
        return selectedTeam
    }
    
    func inEvent() -> Event? {
        return selectedEvent
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
        
        cell.teamLabel.text = "Team \(team.teamNumber)"
        if isSorted {
            let statValue: StatValue
            if let stat = Team.StatName(rawValue: statToSortBy) {
                statValue = team.statValue(forStat: stat)
            } else if let stat = TeamEventPerformance.StatName(rawValue: statToSortBy) {
                statValue = realmController.eventPerformance(forTeam: team, atEvent: selectedEvent!).statValue(forStat: stat)
            } else {
                statValue = .NoValue
            }
            cell.statLabel.text = "\(statValue)"
        } else {
            cell.statLabel.text = ""
        }
        
        cell.rankLabel.text = "\(currentEventTeams.index(where: {$0 == team})! as Int + 1)"
        
        //Show a red X over the rank label if they have been picked
        cell.accessoryView = nil
        if let event = selectedEvent {
            if let eventRanker = realmController.getTeamRanker(forEvent: event) {
                if !eventRanker.isInPickList(team: team) {
                    //Show indicator that it is not in pick list
//                    cell.accessoryType = .checkmark
                    let crossImage = UIImageView(image: #imageLiteral(resourceName: "Cross"))
                    crossImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                    cell.accessoryView = crossImage
                    
                }
            }
        }
        
        if let image = teamImages[team.key] {
            cell.frontImage.image = image
        } else {
            if let imageData = team.scouted.frontImage {
                guard let uiImage = UIImage(data: imageData as Data) else {
                    Crashlytics.sharedInstance().recordCustomExceptionName("Image data corrupted", reason: "Attempt to create UIImage from data failed.", frameArray: [])
                    return cell
                }
                cell.frontImage.image = uiImage
                teamImages[team.key] = uiImage
            } else {
                cell.frontImage.image = UIImage(named: "FRC-Logo")
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let teamListDetailVC: TeamListDetailViewController = teamListSplitVC.teamListDetailVC
        
        //Set the selected team (and alert the delegate)
        selectedTeam = currentTeamsToDisplay[(indexPath as NSIndexPath).row]
        
        //Show the detail vc
        splitViewController?.showDetailViewController(teamListDetailVC, sender: self)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        //Only allow editing in an event
        if let _ = self.selectedEvent {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    //For selecting which teams have been picked
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if let event = selectedEvent {
            
            guard let ranker = RealmController.realmController.getTeamRanker(forEvent: event) else {
                return nil
            }
            let team = self.currentTeamsToDisplay[indexPath.row]
            
            let markAsPicked = UIContextualAction(style: .normal, title: "Mark Picked") {(contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                RealmController.realmController.syncedRealm.beginWrite()
                ranker.setIsInPickList(!ranker.isInPickList(team: team), team: team)
                do {
                    try RealmController.realmController.syncedRealm.commitWrite(withoutNotifying: [self.eventRankerObserverToken ?? NotificationToken()])
                } catch {
                    CLSNSLogv("Error saving write of change to pick list: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                }
                
                completionHandler(true)
                
                //Reload that row
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.right)
            }
            
            markAsPicked.backgroundColor = ranker.isInPickList(team: team) ? .purple : .red
            markAsPicked.title = ranker.isInPickList(team: team) ? "Mark As Picked" : "Unmark as Picked"
            
            let swipeConfig = UISwipeActionsConfiguration(actions: [markAsPicked])
            return swipeConfig
        }
        
        return nil
    }
    

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        //Move the team in the array and in Core Data
        guard let _ = selectedEvent else {
            return
        }
        realmController.moveTeam(from: fromIndexPath.row, to: toIndexPath.row, inEvent: selectedEvent)
        
        let movedTeam = currentEventTeams[fromIndexPath.row]
        currentEventTeams.remove(at: fromIndexPath.row)
        currentEventTeams.insert(movedTeam, at: toIndexPath.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return selectedEvent != nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let event = selectedEvent {
            return "Event: \(event.name)"
        } else {
            return "All Teams"
        }
    }
    
    //MARK: Editing
    //Function for setting the editing of the teams
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        
        if editing {
            editButton.image = UIImage(named: "Edit Filled")
        } else {
            editButton.image = UIImage(named: "Edit")
        }
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem, forEvent event: UIEvent) {
        guard let touch = event.allTouches?.first else {
            return
        }
        
        if touch.tapCount == 1 {
            //Is asingle short press
            if isEditing {
                setEditing(false, animated: true)
            } else {
                setEditing(true, animated: true)
            }
        } else if touch.tapCount == 0 {
            //Long press
            if let frcEvent = selectedEvent {
                let clearPickListAlert = UIAlertController(title: "Reset Picked Teams", message: "Would you like to reset what teams are picked or not? This will not affect any scouting data, just the Xs next to teams that were marked as picked. ", preferredStyle: .alert)
                clearPickListAlert.addAction(UIAlertAction(title: "Reset", style: .default, handler: {_ in
                    //Reset the picked teams
                    let eventRanker = RealmController.realmController.getTeamRanker(forEvent: frcEvent)
                    
                    RealmController.realmController.genericWrite(onRealm: .Synced) {
                        eventRanker?.pickedTeams.removeAll()
                    }
                }))
                clearPickListAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(clearPickListAlert, animated: true, completion: nil)
            }
        }
    }
    
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
        popoverVC?.delegate = self
        
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
                currentSortedTeams = currentEventTeams
                isSorted = false
            default:
                currentSortedTeams = currentEventTeams.sorted {team1, team2 in
                    let isBefore = team1.statValue(forStat: stat) > team2.statValue(forStat: stat)
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
            
            currentSortedTeams = currentEventTeams.sorted {team1, team2 in
                let firstTeamEventPerformance: TeamEventPerformance = realmController.eventPerformance(forTeam: team1, atEvent: selectedEvent!)
                let secondTeamEventPerformance: TeamEventPerformance = realmController.eventPerformance(forTeam: team2, atEvent: selectedEvent!)
                
                let firstStatValue = firstTeamEventPerformance.statValue(forStat: stat)
                let secondStatValue = secondTeamEventPerformance.statValue(forStat: stat)
                
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
        
        if isSorted {
            setEditing(false, animated: true)
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    @IBAction func matchesButtonPressed(_ sender: UIBarButtonItem) {
        let matchesSplitVC = storyboard?.instantiateViewController(withIdentifier: "matchOverviewSplitVC") as! MatchOverviewSplitViewController
        let matchOverviewMaster = (matchesSplitVC.viewControllers.first as! UINavigationController).topViewController as! MatchOverviewMasterViewController
        
        matchOverviewMaster.dataSource = self
        
        present(matchesSplitVC, animated: true, completion: nil)
        
        Answers.logCustomEvent(withName: "Opened Matches Overview", customAttributes: nil)
    }
    
    @IBAction func chartButtonPressed(_ sender: UIBarButtonItem) {
        if let event = selectedEvent {
            let eventStatGraphVC = storyboard?.instantiateViewController(withIdentifier: "eventStatsGraph") as! EventStatsGraphViewController
            let navVC = UINavigationController(rootViewController: eventStatGraphVC)
            
            navVC.modalPresentationStyle = .fullScreen
            
            eventStatGraphVC.setUp(forEvent: event)
            
            present(navVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnToTeamList(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returningWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}

extension TeamListTableViewController: MatchOverviewMasterDataSource {
    func event() -> Event? {
        return selectedEvent
    }
}

extension TeamListTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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

extension TeamListTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if isSearching {
            if let searchText = searchController.searchBar.text {
                Answers.logSearch(withQuery: searchText, customAttributes: nil)
                
                //For the new realm database
                var universalPredicates: [NSPredicate] = []
                universalPredicates.append(NSPredicate(format: "location CONTAINS[cd] %@", argumentArray: [searchText]))
                universalPredicates.append(NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [searchText]))
                universalPredicates.append(NSPredicate(format: "nickname CONTAINS[cd] %@", argumentArray: [searchText]))
                //For team number we want to return as many as possible as we are building the string (i.e. "42" should include team 4256 as a result).
                if let inputtedNum = Int(searchText) {
                    if inputtedNum < 9999 && inputtedNum > 0 {
                        var upperTeamNumLimit = inputtedNum
                        while upperTeamNumLimit < 1000 {
                            upperTeamNumLimit = (upperTeamNumLimit * 10) + 9
                        }
                        
                        var lowerTeamNumLimit = inputtedNum
                        while lowerTeamNumLimit < 1000 {
                            lowerTeamNumLimit = lowerTeamNumLimit * 10
                        }
                        
                        //Now create predicate with limits
                        universalPredicates.append(NSPredicate(format: "teamNumber BETWEEN {%@,%@}", argumentArray: [lowerTeamNumLimit, upperTeamNumLimit]))
                    }
                }
                universalPredicates.append(NSPredicate(format: "website CONTAINS[cd] %@", argumentArray: [searchText]))
                let universalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: universalPredicates)
                
                let filteredTeams = self.currentSortedTeams.filter() {team in
                    return universalPredicate.evaluate(with: team)
                }
                
                currentTeamsToDisplay = filteredTeams
                
                tableView.reloadData()
            }
        } else {
            currentTeamsToDisplay = currentSortedTeams
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //Set the current teams to display back
        currentTeamsToDisplay = currentSortedTeams
        isSearching = false
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
}
