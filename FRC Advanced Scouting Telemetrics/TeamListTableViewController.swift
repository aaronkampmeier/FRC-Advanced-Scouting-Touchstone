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
import Firebase

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
    var stashedStats: [String: StatValue] = [:] {
        didSet {
            //Order the teams
            currentSortedTeams = currentEventTeams.sorted {team1, team2 in
                
                let value1 = stashedStats[team1.key] ?? .NoValue
                let value2 = stashedStats[team2.key] ?? .NoValue
                
                let isBefore = value1 < value2
                if self.isSortingAscending {
                    return isBefore
                } else {
                    return !isBefore
                }
            }
        }
    }
    var isSortingAscending: Bool = false
    
    var isSearching = false
    
    var unorderedTeamsInEvent: [Team] = []
    
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
    var selectedEventKey: String?
    
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
        
        self.resetSubscriptions()
    }
    
    func autoChooseEvent() {
        //Get the tracked events
        Globals.appDelegate.appSyncClient?.fetch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "ListTrackedEvents-TeamList", result: result, error: error) {
                let eventKeys = result?.data?.listTrackedEvents?.map({$0!.eventKey}) ?? []
                //Check if there is a selected event saved
                if let selectedKey = UserDefaults.standard.value(forKey: self?.lastSelectedEventStorageKey ?? "") as? String {
                    //Check if it is tracked
                    if eventKeys.contains(selectedKey) {
                        //Set it
                        self?.eventSelected(selectedKey)
                    } else {
                        //Not tracked
                        UserDefaults.standard.set(nil, forKey: self?.lastSelectedEventStorageKey ?? "")
                        self?.eventSelected(eventKeys.first)
                    }
                } else {
                    self?.eventSelected(eventKeys.first)
                }
            } else {
                //TODO: Show error
            }
        })
    }
    
    //For some reason this is called when moving the app to the background during stands scouting, not sure if this a beta issue or what but it does cause crash
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //If no event is selected, select one
        if selectedEventKey == nil {
            //Select one
            autoChooseEvent()
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
    
    let teamLoadingQueue = DispatchQueue(label: "Team List Loading", qos: .userInteractive)
    fileprivate func setUpForEvent() {
        //Set to nil, because the selected team might not be in the new event
        selectedTeam = nil
        statToSortBy = nil
        unorderedTeamsInEvent = []
        teamImages.removeAll()
        //If we are moving to a different event then clear the table otherwise leave it
        if selectedEventRanking?.eventKey != selectedEventKey {
            currentEventTeams = []
        }
        
        if let eventKey = selectedEventKey {
            UserDefaults.standard.set(eventKey, forKey: lastSelectedEventStorageKey)
            
            //As a hold over until the event ranking loads
            eventSelectionButton.setTitle(eventKey, for: UIControlState())
            
            //Get the scouted teams in the cache
            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListHydrateCache", result: result, error: error) {
                }
            })
            
            Globals.appDelegate.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataAndFetch, queue: teamLoadingQueue) { result, error in
                
                if Globals.handleAppSyncErrors(forQuery: "ListTeams", result: result, error: error) {
                    
                    //Get all of the info on teams in an event
                    self.unorderedTeamsInEvent = result?.data?.listTeams?.map {return $0!.fragments.team} ?? []
                    
                    //Now, go get the ranking of them
                    Globals.appDelegate.appSyncClient?.fetch(query: GetEventRankingQuery(key: eventKey), cachePolicy: .returnCacheDataAndFetch, queue: self.teamLoadingQueue) {[weak self] result, error in
                        if Globals.handleAppSyncErrors(forQuery: "GetEventRanking", result: result, error: error) {
                            self?.selectedEventRanking = result?.data?.getEventRanking?.fragments.eventRanking
                            
                            DispatchQueue.main.async {
                                if self?.eventSelectionButton.titleLabel?.text != self?.selectedEventRanking?.eventName {
                                    self?.eventSelectionButton.setTitle(self?.selectedEventRanking?.eventName, for: UIControlState())
                                }
                            }
                            
                            self?.orderTeamsUsingRanking()
                        } else {
                            DispatchQueue.main.async {
                                //Show error
                                let alert = UIAlertController(title: "Unable to Load Team Rank", message: "There was an error loading the team rankings for this event. Please connect to the internet. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        //Show error
                        let alert = UIAlertController(title: "Unable to Load Teams", message: "There was an error loading the teams for this event. Please connect to the internet and re-load. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            matchesButton.isEnabled = true
            graphButton.isEnabled = true
        } else {
            currentEventTeams = []
            selectedEventRanking = nil
            
            eventSelectionButton.setTitle("Select Event", for: UIControlState())
            
            matchesButton.isEnabled = false
            graphButton.isEnabled = false
        }
        
        self.resetSubscriptions()
        teamListSplitVC.teamListDetailVC.reloadData()
        
        if selectedEventRanking?.eventKey != selectedEventKey {
            Globals.asyncLoadingManager?.setGeneralUpdaters(forEventKey: selectedEventKey)
        }
    }
    
    func orderTeamsUsingRanking() {
        //Orders the teams into the currentEventTeams using the selectedEventRanking
        if let eventRanking = selectedEventRanking {
            teamLoadingQueue.async {
                //Now order the teams according to the ranking
                var shouldReloadRanking = false
                let orderedTeams = self.unorderedTeamsInEvent.sorted {team1, team2 in
                    let firstIndex = eventRanking.rankedTeams?.firstIndex(where: {$0!.teamKey == team1.key})
                    let secondIndex = eventRanking.rankedTeams?.firstIndex(where: {$0!.teamKey == team2.key})
                    if let firstIndex = firstIndex , let secondIndex = secondIndex {
                        return firstIndex < secondIndex
                    } else {
                        //One of the teams does not exist in the ranking, reload the ranking
                        shouldReloadRanking = true
                        return false
                    }
                }
                
                
                ///Check if the order is actually different
                //First if there are any new teams
                var existsNewTeams = false
                for team in orderedTeams {
                    if !self.currentEventTeams.contains(where: {$0.key == team.key}) {
                        existsNewTeams = true
                    }
                }
                for team in self.currentEventTeams {
                    if !orderedTeams.contains(where: {$0.key == team.key}) {
                        existsNewTeams = true
                    }
                }
                
                //Then, check if the order is the same
                var isNewOrder = false
                if !existsNewTeams {
                    for (index,team) in orderedTeams.enumerated() {
                        if self.currentEventTeams[index].key != team.key {
                            isNewOrder = true
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    //If it is all the same then don't bother with reloading the table view
                    if existsNewTeams || isNewOrder {
                        self.currentEventTeams = orderedTeams
                    } else {
                        if self.selectedEventKey != nil {
                            //Just reload visible rows
                            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .automatic)
                        }
                    }
                    
                    if shouldReloadRanking {
                        self.reloadEvent(eventKey: eventRanking.eventKey)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.currentEventTeams = []
            }
        }
    }
    
    ///Reloads the teams in an event in the cloud, use if a team does not exist in the ranking
    func reloadEvent(eventKey: String) {
        Globals.appDelegate.appSyncClient?.perform(mutation: AddTrackedEventMutation(eventKey: eventKey), optimisticUpdate: {transaction in
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
    
    deinit {
        trackedEventsWatcher?.cancel()
        changeTeamRankSubscriber?.cancel()
        pickedTeamSubscriber?.cancel()
        updateScoutedTeamSubscriber?.cancel()
    }
    
    var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    var changeTeamRankSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnUpdateTeamRankSubscription>?
    var pickedTeamSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnSetTeamPickedSubscription>?
    var updateScoutedTeamSubscriber: AWSAppSyncSubscriptionWatcher<OnUpdateScoutedTeamsSubscription>?
    func resetSubscriptions() {
        CLSNSLogv("Resetting Team List Subscriptions", getVaList([]))
        
        trackedEventsWatcher?.cancel()
        changeTeamRankSubscriber?.cancel()
        pickedTeamSubscriber?.cancel()
        updateScoutedTeamSubscriber?.cancel()
        
        //Set up a watcher to event deletions
        do {
            trackedEventsWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTrackedEventsQuery(), cachePolicy: .returnCacheDataDontFetch, resultHandler: {[weak self] (result, error) in
                DispatchQueue.main.async {
                    let trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
                    
                    if let selectedEventKey = self?.selectedEventKey {
                        if !trackedEvents.contains(where: {$0.eventKey == selectedEventKey}) {
                            //Event was removed
                            self?.eventSelected(nil)
                        }
                    } else {
                        if let newEventKey = trackedEvents.first?.eventKey {
                            self?.eventSelected(newEventKey)
                        }
                    }
                }
            })
        } catch {
            CLSNSLogv("Error starting subscriptions: \(error)", getVaList([]))
            Crashlytics.sharedInstance().recordError(error)
        }
        
        if let eventKey = self.selectedEventKey {
            //Set up subscribers for event specifics
            do {
                changeTeamRankSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnUpdateTeamRankSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey)) {[weak self] result, transaction, error in
                    if Globals.handleAppSyncErrors(forQuery: "OnUpdateTeamRankSubscription", result: result, error: error) {
                        self?.selectedEventRanking = result?.data?.onUpdateTeamRank?.fragments.eventRanking
                        self?.orderTeamsUsingRanking()
                        
                        //TODO: Edit the transaction cache
                    } else {
                        if let error = error as? AWSAppSyncSubscriptionError {
                            if error.recoverySuggestion != nil {
                                self?.resetSubscriptions()
                            }
                        }
                    }
                }
                
                pickedTeamSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnSetTeamPickedSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey)) {[weak self] result, transaction, error in
                    if Globals.handleAppSyncErrors(forQuery: "OnSetTeamPickedSubscription", result: result, error: error) {
                        //TODO: Update the cache
                        
                        self?.selectedEventRanking = result?.data?.onSetTeamPicked?.fragments.eventRanking
                        
                        //Reload the cell
                        if let visibleRows = self?.tableView.indexPathsForVisibleRows {
                            self?.tableView.reloadRows(at: visibleRows, with: UITableViewRowAnimation.none)
                        }
                    } else {
                        if let error = error as? AWSAppSyncSubscriptionError {
                            if error.recoverySuggestion != nil {
                                self?.resetSubscriptions()
                            }
                        }
                    }
                }
                
                updateScoutedTeamSubscriber = try Globals.appDelegate.appSyncClient?.subscribe(subscription: OnUpdateScoutedTeamsSubscription(userID: AWSMobileClient.sharedInstance().username ?? "", eventKey: eventKey), resultHandler: {[weak self] (result, transaction, error) in
                    if Globals.handleAppSyncErrors(forQuery: "OnUpdateScoutedTeamGeneral-TeamList", result: result, error: error) {
                        try? transaction?.update(query: ListScoutedTeamsQuery(eventKey: eventKey), { (selectionSet) in
                            if let index = selectionSet.listScoutedTeams?.firstIndex(where: {$0?.teamKey == result?.data?.onUpdateScoutedTeam?.teamKey}) {
                                selectionSet.listScoutedTeams?.remove(at: index)
                            }
                            if let newTeam = result?.data?.onUpdateScoutedTeam {
                                selectionSet.listScoutedTeams?.append(try! ListScoutedTeamsQuery.Data.ListScoutedTeam(newTeam))
                            }
                        })
                        
                        //Reload row
                        if let index = self?.currentTeamsToDisplay.firstIndex(where: {$0.key == result?.data?.onUpdateScoutedTeam?.teamKey}) {
                            self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        }
                    } else {
                        if let error = error as? AWSAppSyncSubscriptionError {
                            if error.recoverySuggestion != nil {
                                self?.resetSubscriptions()
                            }
                        }
                    }
                })
            } catch {
                CLSNSLogv("Error starting subcriptions: \(error)", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
                //TODO: Handle this error
            }
        } else {
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
        
        //Show the Deep Space welcome if it has not been shown
        if !(UserDefaults.standard.value(forKey: "HasShownDeepSpaceWelcome") as? Bool ?? false) {
            let deepSpaceWelcome = storyboard!.instantiateViewController(withIdentifier: "deepSpaceWelcome")
            self.present(deepSpaceWelcome, animated: true, completion: nil)
        }
        
        let hasShownInstructionalAlertKey = "FAST-HasShownInstructionalAlert"
        //Show an instructional alert about the event ranks
        if !Globals.isInSpectatorMode && !(UserDefaults.standard.value(forKey: hasShownInstructionalAlertKey) as? Bool ?? false) {
            //Wait until the user has finished adding the first event
            if selectedEventKey != nil {
                //Now show it
                let alert = UIAlertController(title: "Important Tip", message: "The edit button on the bottom left allows you to reorder the team list however you would like in order to bring your favorite teams to the top. The rank numbers on the left correspond to this order and not the event qualification ranking. To find the qualification ranking of a team, click into that team's detail page or use the sort menu.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                    UserDefaults.standard.set(true, forKey: hasShownInstructionalAlertKey)
                }))
                self.present(alert, animated: true, completion: nil)
                
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
            //Get the stat value
            let value = stashedStats[team.key]
            cell.statLabel.text = value?.description
        }
        
        if let index = selectedEventRanking?.rankedTeams?.index(where: {$0?.teamKey == team.key}) {
            cell.rankLabel.text = "\(index as Int + 1)"
        } else {
            cell.rankLabel.text = "?"
            Crashlytics.sharedInstance().recordCustomExceptionName("Team Event Rank Failed", reason: "Team is not in currentEventTeams.", frameArray: [])
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
        
        //Image functionality
        if let image = teamImages["\(selectedEventKey ?? "")-\(team.key)"] {
            cell.frontImage.image = image
        } else {
            cell.frontImage.image = UIImage(named: "FRC-Logo")
            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: selectedEventKey ?? ""), cachePolicy: .returnCacheDataDontFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListCellForRowAt", result: result, error: error) {
                    if let scoutedTeam = result?.data?.listScoutedTeams?.first(where: {$0?.teamKey == team.key})??.fragments.scoutedTeam {
                        if let imageInfo = scoutedTeam.image {
                            TeamImageLoader.default.loadImage(withAttributes: imageInfo, progressBlock: { (progress) in
                                
                            }, completionHandler: { (image, error) in
                                if let image = image {
                                    if cell.stateID == stateID {
                                        cell.frontImage.image = image
                                    }
                                    self?.teamImages["\(self?.selectedEventKey ?? "")-\(team.key)"] = image
                                } else {
                                }
                            })
                        } else {
                        }
                    } else {
                    }
                }
            })
        }
        
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
        
        guard !Globals.isInSpectatorMode else {
            return nil
        }
        
        if let eventKey = selectedEventKey {
            let team = self.currentTeamsToDisplay[indexPath.row]
            
            let markAsPicked = UIContextualAction(style: .normal, title: "Mark Picked") {(contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                //Check if it is picked yet
                let rankedTeam = self.selectedEventRanking?.rankedTeams?.first {$0!.teamKey == team.key}
                let isPicked = rankedTeam??.isPicked ?? false
                
                Globals.appDelegate.appSyncClient?.perform(mutation: SetTeamPickedMutation(eventKey: eventKey, teamKey: team.key, isPicked: !isPicked), optimisticUpdate: { (transaction) in
                    //TODO: Optimistic update
                }, conflictResolutionBlock: { (snapshot, source, result) in
                    CLSNSLogv("Conflict resolution block ran", getVaList([]))
                }, resultHandler: {[weak self] (result, error) in
                    if let error = error {
                        CLSNSLogv("Error setting team picked", getVaList([]))
                        Crashlytics.sharedInstance().recordError(error)
                        //TODO: - Show Error
                    } else if let result = result {
                        self?.selectedEventRanking = result.data?.setTeamPicked?.fragments.eventRanking
                    }
                    //Reload that row
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                })
                
                completionHandler(true)
            }
            
            //Check if it is picked yet
            let rankedTeam = self.selectedEventRanking?.rankedTeams?.first {$0!.teamKey == team.key}
            let isPicked = rankedTeam??.isPicked ?? false
            
            markAsPicked.backgroundColor = isPicked ? .red : .purple
            markAsPicked.title = isPicked ?  "Unmark as Picked" : "Mark As Picked"
            
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
        let previousRanking = selectedEventRanking
        
        Globals.appDelegate.appSyncClient?.perform(mutation: MoveRankedTeamMutation(eventKey: eventKey, teamKey: team.key, toIndex: toIndexPath.row), optimisticUpdate: { (transaction) in
            do {
                try transaction?.updateObject(ofType: EventRanking.self, withKey: "ranking_\(eventKey)", { (selectionSet) in
                    if let movedTeam = selectionSet.rankedTeams?.remove(at: fromIndexPath.row) {
                        selectionSet.rankedTeams?.insert(movedTeam, at: toIndexPath.row)
                    } else {
                        
                    }
                    
                    self.selectedEventRanking = selectionSet
                })
                
                DispatchQueue.main.async {
                    self.currentEventTeams.insert(self.currentEventTeams.remove(at: fromIndexPath.row), at: toIndexPath.row)
                }
            } catch {
                CLSNSLogv("Error performing optimistic update for MoveRankedTeamMutation", getVaList([]))
                Crashlytics.sharedInstance().recordError(error)
            }
        }, conflictResolutionBlock: { (snapshot, source, result) in
            
        }, resultHandler: {[weak self] (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "MoveRankedTeamMutation", result: result, error: error) {
                self?.selectedEventRanking = result?.data?.moveRankedTeam?.fragments.eventRanking
                
                let _ = Globals.appDelegate.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Any in
                    try? transaction.updateObject(ofType: EventRanking.self, withKey: "ranking_\(eventKey)", { (selectionSet) in
                        if let ranking = result?.data?.moveRankedTeam?.fragments.eventRanking {
                            selectionSet = ranking
                        }
                    }) as Any
                })
            } else {
                self?.selectedEventRanking = previousRanking
                let alert = UIAlertController(title: "Error Moving Team", message: "There was an error moving the team. Make sure you are connected to the Internet and try again. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            
            DispatchQueue.main.async {
                self?.orderTeamsUsingRanking()
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
    
    let statsOrderingQueue = DispatchQueue(label: "StatsOrderingTeamList", qos: .utility, target: nil)
    func sortList(withStat stat: Statistic<ScoutedTeam>?, isAscending ascending: Bool) {
        guard let selectedEventKey = selectedEventKey else {
            return
        }
        
        self.isSortingAscending = ascending
        
        statToSortBy = stat
        
        if let newStat = stat {
            //Grab the scouted teams
            Globals.appDelegate.appSyncClient?.fetch(query: ListScoutedTeamsQuery(eventKey: selectedEventKey), cachePolicy: .returnCacheDataElseFetch, queue: statsOrderingQueue, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-StatSorting", result: result, error: error) {
                    let scoutedTeams = result?.data?.listScoutedTeams?.map {$0!.fragments.scoutedTeam} ?? []
                    
                    //Order the teams
                    DispatchQueue.main.async {
                        self?.stashedStats = [String:StatValue]()
                    }
                    //Calculate all of the stats
                    for team in scoutedTeams {
                        newStat.calculate(forObject: team, callback: { (value) in
                            if self?.statToSortBy == newStat {
                                DispatchQueue.main.async {
                                    //Setting the stashed stats, reloads the order of the teams
                                    self?.stashedStats[team.teamKey] = value
                                }
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.currentSortedTeams = self!.currentEventTeams
                    }
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
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"screen", "item_id":"matches_overview"])
    }
    
    @IBAction func chartButtonPressed(_ sender: UIBarButtonItem) {
        if let eventKey = selectedEventKey {
            let eventStatGraphVC = storyboard?.instantiateViewController(withIdentifier: "eventStatsGraph") as! EventStatsGraphViewController
            let navVC = UINavigationController(rootViewController: eventStatGraphVC)
            
            navVC.modalPresentationStyle = .fullScreen
            
            eventStatGraphVC.setUp(forEventKey: eventKey)
            
            present(navVC, animated: true, completion: nil)
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
        setUpForEvent()
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
                
                let filteredTeams = self.currentSortedTeams.filter { (team) -> Bool in
                    var isIncluded = false
                    isIncluded = team.address?.contains(searchText) ?? false || isIncluded
                    isIncluded = team.stateProv?.contains(searchText) ?? false || isIncluded
                    isIncluded = team.city?.contains(searchText) ?? false || isIncluded
                    isIncluded = team.name.contains(searchText) || isIncluded
                    isIncluded = team.nickname.contains(searchText) || isIncluded
                    isIncluded = team.rookieYear?.description.contains(searchText) ?? false || isIncluded
                    isIncluded = team.teamNumber.description.contains(searchText) || isIncluded
                    isIncluded = team.website?.contains(searchText) ?? false || isIncluded
                    
                    return isIncluded
                }
                
                currentTeamsToDisplay = filteredTeams
                
                tableView.reloadData()
                Globals.recordAnalyticsEvent(eventType: AnalyticsEventSearch, attributes: ["search_term":searchText], metrics: ["results":Double(filteredTeams.count)])
            }
        } else {
            currentTeamsToDisplay = currentSortedTeams
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
        self.navigationController?.setToolbarHidden(true, animated: true)
        Globals.recordAnalyticsEvent(eventType: "began_searching")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //Set the current teams to display back
        currentTeamsToDisplay = currentSortedTeams
        isSearching = false
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
}
