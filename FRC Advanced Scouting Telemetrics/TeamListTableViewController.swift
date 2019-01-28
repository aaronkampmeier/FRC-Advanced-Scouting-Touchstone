//
//  TeamListTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import AWSCore
import AWSAppSync
import AWSMobileClient

class EventSelectionTitleButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}

class TeamListTableViewController: UITableViewController, TeamListDetailDataSource {
    @IBOutlet weak var incompleteEventView: UIView!
    @IBOutlet weak var graphButton: UIBarButtonItem!
    @IBOutlet weak var eventSelectionButton: EventSelectionTitleButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var matchesButton: UIBarButtonItem!
    
    var searchController: UISearchController!
    var teamImages = [String:UIImage]()
    var teamListSplitVC: TeamListSplitViewController {
        get {
            return splitViewController as! TeamListSplitViewController
        }
    }
    
    var statToSortBy: Statistic<ScoutedTeam>?
    //Should move functionality in here to a setSortingState func
//    var isSorted = false
    var isSortingAscending: Bool = false
    
    var isSearching = false
    
    var unorderedTeamsInEvent: [Team] = []
    var scoutedTeams: [Team] = []
    
    //Is a hierarchy
    var currentEventTeams: [Team] = [Team]() {
        didSet {
            sortList(withStat: statToSortBy, isAscending: isSortingAscending)
        }
    }
    var currentSortedTeams: [Team] = [] {
        didSet {
            self.updateSearchResults(for: searchController)
        }
    }
    //Searching would happen right in between here
    var currentTeamsToDisplay = [Team]() { //This is always exaclty the end what the table view will display
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
                    return team.key == sTeam.key
                }) {
                    tableView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .none)
                }
            } else {
                tableView.deselectRow(at: tableView.indexPathForSelectedRow ?? IndexPath(), animated: false)
            }
            
            teamListSplitVC.teamListDetailVC.reloadData()
        }
    }
    let lastSelectedEventStorageKey = "Last-Selected-Event"
    var selectedEventRanking: EventRanking?
    
    var selectedEventKey: String? {
        didSet {
            setUpForEvent()
//            reloadEventRankerObserver()
        }
    }
    
    var deleteTrackedEventSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnRemoveTrackedEventSubscription>?
    var changeTeamRankSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnUpdateTeamRankSubscription>?
    var pickedTeamSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnSetTeamPickedSubscription>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        //Set background view of table view
        let noEventView = NoEventSelectedView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        tableView.backgroundView = noEventView
        
        //Set last selected event
        if let lastSelectedEventKey = UserDefaults.standard.value(forKey: lastSelectedEventStorageKey) as? String {
            //Get event
            self.selectedEventKey = lastSelectedEventKey
        }
        
        //Set up a subscriber to event deletions
        do {
            let subscription = OnRemoveTrackedEventSubscription(userID: AWSMobileClient.sharedInstance().username ?? "")
            deleteTrackedEventSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: subscription) {[weak self] (result, transaction, error) in
                if let result = result {
                    //Simply returns the event key
                    let removedEventKey: String = result.data!.onRemoveTrackedEvent!
                    if self?.selectedEventKey ?? "" == removedEventKey {
                        //TODO: Use transaction to edit cache
                        self?.selectedEventKey = nil
                    }
                } else if let error = error {
                    CLSNSLogv("Error subscribing to OnDeleteTrackedEvent: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                }
            }
        } catch {
            CLSNSLogv("Error starting subscriptions: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    //For some reason this is called when moving the app to the background during stands scouting, not sure if this a beta issue or what but it does cause crash
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedEventKey == nil {
            Globals.appDelegate.appSyncClient?.fetch(query: ListTrackedEventsQuery(), cachePolicy: .fetchIgnoringCacheData) {[weak self] result, error in
                if let error = error {
                    CLSNSLogv("Error ListTrackedEventsQuery: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                } else if let errors = result?.errors {
                    CLSNSLogv("Errors ListTrackedEventQuery (GraphQL): \(errors)", getVaList([]))
                    for error in errors {
                        Crashlytics.sharedInstance().recordError(error)
                    }
                } else {
                    self?.selectedEventKey = result?.data?.listTrackedEvents?.first??.eventKey
                }
            }
        } else {
            setUpForEvent()
        }
        
        if isSearching {
            self.navigationController?.setToolbarHidden(true, animated: true) //Set hidden if we are returning to a search
        } else {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        
        //Deselect the current row if the detail vc is not showing at the moment
        if splitViewController?.isCollapsed ?? false {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    fileprivate func setUpForEvent() {
        //Set to nil, because the selected team might not be in the new event
        selectedTeam = nil
        statToSortBy = nil
        
        if let eventKey = selectedEventKey {
            UserDefaults.standard.set(eventKey, forKey: lastSelectedEventStorageKey)
            
            //As a hold over until the event ranking loads
            eventSelectionButton.setTitle(eventKey, for: UIControlState())
            
            Globals.appDelegate.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataAndFetch, queue: DispatchQueue(label: "Team List Loading", qos: .userInteractive)) {[weak self] result, error in
                if Globals.handleAppSyncErrors(forQuery: "ListTeams", result: result, error: error) {
                    
                    //Get all of the info on teams in an event
                    self?.unorderedTeamsInEvent = result?.data?.listTeams?.map {return $0!.fragments.team} ?? []
                    
                    //Now, go get the ranking of them
                    Globals.appDelegate.appSyncClient?.fetch(query: GetEventRankingQuery(key: eventKey), cachePolicy: .returnCacheDataAndFetch) {[weak self] result, error in
                        if Globals.handleAppSyncErrors(forQuery: "GetEventRanking", result: result, error: error) {
                            self?.selectedEventRanking = result?.data?.getEventRanking?.fragments.eventRanking
                            
                            self?.eventSelectionButton.setTitle(self?.selectedEventRanking?.eventName, for: UIControlState())
                            
                            self?.orderTeamsUsingRanking()
                            
                            //Now go fetch all of the scouted teams just to get them into the cache
                            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, resultHandler: { (result, error) in
                                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams", result: result, error: error) {
                                    //Ta da
                                }
                            })
                        } else {
                            //TODO: - Show error
                        }
                    }
                } else {
                    //TODO: - Show error
                }
            }
            
            matchesButton.isEnabled = true
            graphButton.isEnabled = true
            
            //Set up subscribers
            do {
                changeTeamRankSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnUpdateTeamRankSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey)) {[weak self] result, transaction, error in
                    if let result = result {
                        self?.selectedEventRanking = result.data?.onUpdateTeamRank?.fragments.eventRanking
                        self?.orderTeamsUsingRanking()
                        
                        //TODO: Edit the transaction cache
                    } else if let error = error {
                        CLSNSLogv("Error with rank subscription: \(error)", getVaList([]))
                    }
                }
                
                pickedTeamSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnSetTeamPickedSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey)) {[weak self] result, transaction, error in
                    if let result = result {
                        //TODO: Update the cache
                        
                        self?.selectedEventRanking = result.data?.onSetTeamPicked?.fragments.eventRanking
                        
                        //Reload the cell
                        if let visibleRows = self?.tableView.indexPathsForVisibleRows {
                            self?.tableView.reloadRows(at: visibleRows, with: UITableViewRowAnimation.none)
                        }
                    } else if let error = error {
                        CLSNSLogv("Error OnSetTeamPickedSubscription: \(error)", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    }
                }
            } catch {
                CLSNSLogv("Error starting subcriptions: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                //TODO: Handle this error
            }
        } else {
            currentEventTeams = []
            selectedEventRanking = nil
            
            eventSelectionButton.setTitle("Select Event", for: UIControlState())
            
            matchesButton.isEnabled = false
            graphButton.isEnabled = false
        }
        
        teamListSplitVC.teamListDetailVC.reloadData()
    }
    
    func orderTeamsUsingRanking() {
        //Orders the teams into the currentEventTeams using the selectedEventRanking
        if let eventRanking = selectedEventRanking {
            //Now order the teams according to the ranking
            var shouldReload = false
            self.currentEventTeams = self.unorderedTeamsInEvent.sorted {team1, team2 in
                let firstIndex = eventRanking.rankedTeams?.firstIndex(where: {$0!.teamKey == team1.key})
                let secondIndex = eventRanking.rankedTeams?.firstIndex(where: {$0!.teamKey == team2.key})
                if let firstIndex = firstIndex , let secondIndex = secondIndex {
                    return firstIndex < secondIndex
                } else {
                    //One of the teams does not exist in the ranking, reload the ranking
                    shouldReload = true
                    return false
                }
            }
            
            if shouldReload {
                reloadEvent(eventKey: eventRanking.eventKey)
            }
        } else {
            currentEventTeams = []
        }
    }
    
    ///Reloads the teams in an event in the cloud, use if a team does not exist in the ranking
    func reloadEvent(eventKey: String) {
        Globals.appDelegate.appSyncClient?.perform(mutation: AddTrackedEventMutation(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey), optimisticUpdate: {transaction in
            //TODO: Add Optimistic update
        }) {[weak self] result, error in
            if let error = error {
                CLSNSLogv("Error AddTrackedEvent: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            } else if let errors = result?.errors {
                CLSNSLogv("Errors AddTrackedEvent: \(errors)", getVaList([]))
                for error in errors {
                    Crashlytics.sharedInstance().recordError(error)
                }
            } else {
                self?.selectedEventRanking = result?.data?.addTrackedEvent?.fragments.eventRanking
                self?.orderTeamsUsingRanking()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let previousOpenKey = "FAST-HasBeenOpened"
        //Show a choose event screen if we are in spectator mode and is the first time opening
        if Globals.isInSpectatorMode && !(UserDefaults.standard.value(forKey: previousOpenKey) as? Bool ?? false) {
            let chooseEventScreen = storyboard?.instantiateViewController(withIdentifier: "addEvent") as! AddEventTableViewController
            
            let nav = UINavigationController(rootViewController: chooseEventScreen)
            nav.modalPresentationStyle = .formSheet
            
            self.present(nav, animated: true) {
                UserDefaults.standard.setValue(true, forKey: previousOpenKey)
            }
        }
        
        let hasShownInstructionalAlertKey = "FAST-HasShownInstructionalAlert"
        //Show an instructional alert about the event ranks
        if Globals.isInSpectatorMode && !(UserDefaults.standard.value(forKey: hasShownInstructionalAlertKey) as? Bool ?? false) {
            //Wait until the user has finished adding the first event
            if selectedEventKey != nil {
                //Now show it
                let alert = UIAlertController(title: "Important Tip", message: "The edit button on the bottom left allows you to reorder the team list however you would like in order to bring your favorite teams to the top. The rank numbers on the left correspond to this order and not the event qualification ranking. To find the qualification ranking of a team, click into that team's detail page or use the sort menu.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                UserDefaults.standard.set(true, forKey: hasShownInstructionalAlertKey)
            }
        }
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
    
    func inEventKey() -> String? {
        return selectedEventKey
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = selectedEventKey {
            //Hide the show event text
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
            tableView.tableHeaderView?.isHidden = false
            return 1
        } else {
            //Show the select event text
            tableView.backgroundView?.isHidden = false
            tableView.tableHeaderView?.isHidden = true
            tableView.separatorStyle = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTeamsToDisplay.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "rankedCell", for: indexPath) as! TeamListTableViewCell

        let team = currentTeamsToDisplay[(indexPath as NSIndexPath).row]
        
        let stateID = UUID().uuidString
        cell.stateID = stateID
        
        cell.teamLabel.text = "Team \(team.teamNumber)"
        cell.teamNameLabel.text = team.nickname
        cell.statLabel.text = ""
        if let stat = statToSortBy {
            //Get the scouted team
            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: self.selectedEventKey!), cachePolicy: .returnCacheDataElseFetch) {result, error in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-CellStatValue", result: result, error: error) {
                    let sTeam = (result?.data?.listScoutedTeams?.first {$0?.teamKey == team.key})??.fragments.scoutedTeam
                    
                    guard let scoutedTeam = sTeam else {
                        //Error that no scouted team for team
                        CLSNSLogv("No Scouted Team for Team: \(team.key)", getVaList([]))
                        return
                    }
                    //Get the stat value also async
                    stat.calculate(forObject: scoutedTeam) {value in
                        //Check that the cell is the right state
                        if stateID == cell.stateID {
                            //Set the stat label
                            cell.statLabel.text = "\(value)"
                        }
                    }
                }
            }
        }
        
        if let index = currentEventTeams.index(where: {$0.key == team.key}) {
            cell.rankLabel.text = "\(index as Int + 1)"
        } else {
            cell.rankLabel.text = "?"
            Crashlytics.sharedInstance().recordCustomExceptionName("Team Event Rank Failed", reason: "Team is not in currentEventTeams. Team: \(team.key), Event: \(selectedEventKey)", frameArray: [])
        }
        
        //Show an X if they have been picked
        cell.accessoryView = nil
        if let eventRanking = self.selectedEventRanking {
            //Find the team in the ranking
            let rankedTeam = eventRanking.rankedTeams?.first {$0!.teamKey == team.key}
            if rankedTeam??.isPicked ?? false {
                //Show indicator that it is picked
                let crossImage = UIImageView(image: #imageLiteral(resourceName: "Cross"))
                crossImage.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                cell.accessoryView = crossImage
            }
        }
        
        //TODO: Add image functionality
//        if let image = teamImages[team.key] {
//            cell.frontImage.image = image
//        } else {
//            if let imageData = team.scouted?.frontImage {
//                guard let uiImage = UIImage(data: imageData as Data) else {
//                    Crashlytics.sharedInstance().recordCustomExceptionName("Image data corrupted", reason: "Attempt to create UIImage from data failed.", frameArray: [])
//                    return cell
//                }
//                cell.frontImage.image = uiImage
//                teamImages[team.key] = uiImage
//            } else {
//                cell.frontImage.image = UIImage(named: "FRC-Logo")
//            }
//        }
        
        //Show the indicator if this is the team that is currently logged in
        cell.myTeamIndicatorImageView.isHidden = true
        if let loggedInTeam = AWSMobileClient.sharedInstance().username {
            if let teamInt = Int(loggedInTeam) {
                if teamInt == team.teamNumber {
                    cell.myTeamIndicatorImageView.isHidden = false
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pressedTeam = currentTeamsToDisplay[indexPath.row]
        
        let teamListDetailVC: TeamListDetailViewController = teamListSplitVC.teamListDetailVC
        
        //Set the selected team (and alert the delegate)
        selectedTeam = pressedTeam
        
        //Show the detail vc
        splitViewController?.showDetailViewController(teamListDetailVC, sender: self)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        //Only allow editing in an event
        if let _ = self.selectedEventKey {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        if let event = selectedEvent {
//            guard let ranker = RealmController.realmController.getTeamRanker(forEvent: event) else {
//                return nil
//            }
//            let team = self.currentTeamsToDisplay[indexPath.row]
//
//            let markAsPicked = UITableViewRowAction(style: .default, title: "Mark Picked") {action, indexPath in
//
//            }
//
//        }
//
//        return nil
//    }
//
//    func markAsPicked(atIndexPath indexPath: IndexPath, inTableView tableView: UITableView) {
//
//    }
    
    //For selecting which teams have been picked
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard Globals.isInSpectatorMode else {
            return nil
        }
        
        if let eventKey = selectedEventKey {
            let team = self.currentTeamsToDisplay[indexPath.row]
            
            let markAsPicked = UIContextualAction(style: .normal, title: "Mark Picked") {(contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                //Check if it is picked yet
                let rankedTeam = self.selectedEventRanking?.rankedTeams?.first {$0!.teamKey == team.key}
                let isPicked = rankedTeam??.isPicked ?? false
                
                Globals.appDelegate.appSyncClient?.perform(mutation: SetTeamPickedMutation(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey, teamKey: team.key, isPicked: !isPicked), optimisticUpdate: { (transaction) in
                    //TODO: Optimistic update
                }, conflictResolutionBlock: { (snapshot, source, result) in
                    CLSNSLogv("Conflict resolution block ran", getVaList([]))
                }, resultHandler: {[weak self] (result, error) in
                    if let error = error {
                        CLSNSLogv("Error setting team picked", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                    } else if let result = result {
                        self?.selectedEventRanking = result.data?.setTeamPicked?.fragments.eventRanking
                    }
                })
                
                completionHandler(true)
                
                //Reload that row
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.right)
            }
            
            //Check if it is picked yet
            let rankedTeam = self.selectedEventRanking?.rankedTeams?.first {$0!.teamKey == team.key}
            let isPicked = rankedTeam??.isPicked ?? false
            
            markAsPicked.backgroundColor = isPicked ? .purple : .red
            markAsPicked.title = isPicked ? "Mark As Picked" : "Unmark as Picked"
            
            let swipeConfig = UISwipeActionsConfiguration(actions: [markAsPicked])
            return swipeConfig
        } else {
            return nil
        }
    }
    

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        //Move the team in the array and in Core Data
        guard let eventKey = selectedEventKey else {
            return
        }
        
        //Get the team key
        let team = currentTeamsToDisplay[fromIndexPath.row]
        
        Globals.appDelegate.appSyncClient?.perform(mutation: MoveRankedTeamMutation(userID: AWSMobileClient.sharedInstance().username!, eventKey: eventKey, teamKey: team.key, toIndex: toIndexPath.row), optimisticUpdate: { (transaction) in
            //TODO: Optimistic
        }, conflictResolutionBlock: { (snapshot, source, result) in
            
        }, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "MoveRankedTeamMutation", result: result, error: error) {
                self?.selectedEventRanking = result?.data?.moveRankedTeam?.fragments.eventRanking
            } else {
                //TODO: Show Error
            }
        })
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return selectedEventKey != nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
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
        }
//        else if touch.tapCount == 0 {
//            //Long press
//            if let frcEvent = selectedEvent {
//                let clearPickListAlert = UIAlertController(title: "Reset Picked Teams", message: "Would you like to reset what teams are picked or not? This will not affect any scouting data, just the Xs next to teams that were marked as picked.", preferredStyle: .alert)
//                clearPickListAlert.addAction(UIAlertAction(title: "Reset", style: .default, handler: {_ in
//                    //Reset the picked teams
//                    let eventRanker = RealmController.realmController.getTeamRanker(forEvent: frcEvent)
//
//                    RealmController.realmController.genericWrite(onRealm: .Synced) {
//                        eventRanker?.pickedTeams.removeAll()
//                    }
//                }))
//                clearPickListAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                self.present(clearPickListAlert, animated: true, completion: nil)
//            }
//        }
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
    
    func sortList(withStat stat: Statistic<ScoutedTeam>?, isAscending ascending: Bool) {
        guard let selectedEventKey = selectedEventKey else {
            return
        }
        
        self.isSortingAscending = ascending
        
        statToSortBy = stat
        
        if let newStat = stat {
            //Grab the scouted teams
            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: selectedEventKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-StatSorting", result: result, error: error) {
                    let scoutedTeams = result?.data?.listScoutedTeams?.map {$0!.fragments.scoutedTeam} ?? []
                    
                    //Order the teams
                    self?.currentSortedTeams = self!.currentEventTeams.sorted {team1, team2 in
                        if let sTeam1 = scoutedTeams.first(where: {$0.teamKey == team1.key}), let sTeam2 = scoutedTeams.first(where: {$0.teamKey == team2.key}) {
                            //Use dispatch groups to wait for both values to be calculated
                            let group = DispatchGroup()
                            
                            group.enter()
                            
                            var value1: StatValue?
                            var value2: StatValue?
                            
                            newStat.calculate(forObject: sTeam1) {value in
                                value1 = value
                                //Check if finished
                                if value2 != nil {
                                    group.leave()
                                }
                            }
                            
                            newStat.calculate(forObject: sTeam2) {value in
                                value2 = value
                                if value1 != nil {
                                    group.leave()
                                }
                            }
                            
                            //Wait for the two values to be calculated
                            group.wait()
                            if let value1 = value1, let value2 = value2 {
                                let isBefore = value1 < value2
                                if ascending {
                                    return isBefore
                                } else {
                                    return !isBefore
                                }
                            } else {
                                //The values aren't there even though we waited for them to be calculated
                                assertionFailure()
                                Crashlytics.sharedInstance().recordCustomExceptionName("Calculated Stats Not There", reason: "Obviously i don't know why else would i be recording an exception", frameArray: [])
                                exit(1)
                            }
                        } else {
                            return false
                        }
                    }
                } else {
                    self?.currentSortedTeams = self!.currentEventTeams
                }
            })
        } else {
            currentSortedTeams = currentEventTeams
        }
        
        if statToSortBy != nil {
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
        if let eventKey = selectedEventKey {
            let eventStatGraphVC = storyboard?.instantiateViewController(withIdentifier: "eventStatsGraph") as! EventStatsGraphViewController
            let navVC = UINavigationController(rootViewController: eventStatGraphVC)
            
            navVC.modalPresentationStyle = .fullScreen
            
            eventStatGraphVC.setUp(forEventKey: eventKey)
            
            present(navVC, animated: true, completion: nil)
            
            Answers.logCustomEvent(withName: "Event Stats Grapher Button Pressed", customAttributes: nil)
        }
    }
    
    @IBAction func returnToTeamList(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returningWithSegue(_ segue: UIStoryboardSegue) {
        
    }
}

extension TeamListTableViewController: MatchOverviewMasterDataSource {
    func eventKey() -> String? {
        return selectedEventKey
    }
}

extension TeamListTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TeamListTableViewController: EventSelection {
    func eventSelected(_ eventKey: String?) {
        selectedEventKey = eventKey
    }
    
    func currentEventKey() -> String? {
        return selectedEventKey
    }
}

extension TeamListTableViewController: SortDelegate {
    func selectedStat(_ stat: Statistic<ScoutedTeam>?, isAscending: Bool) {
        sortList(withStat: stat, isAscending: isAscending)
    }
    
    func currentStat() -> Statistic<ScoutedTeam>? {
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
                        
                        //And for three number teams (like team 931)
                        var upperTeamNumLimit3 = inputtedNum
                        while upperTeamNumLimit3 < 100 {
                            upperTeamNumLimit3 = (upperTeamNumLimit3 * 10) + 9
                        }
                        
                        var lowerTeamNumLimit3 = inputtedNum
                        while lowerTeamNumLimit3 < 100 {
                            lowerTeamNumLimit3 = lowerTeamNumLimit3 * 10
                        }
                        
                        universalPredicates.append(NSPredicate(format: "teamNumber BETWEEN {%@,%@}", argumentArray: [lowerTeamNumLimit3, upperTeamNumLimit3]))
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
