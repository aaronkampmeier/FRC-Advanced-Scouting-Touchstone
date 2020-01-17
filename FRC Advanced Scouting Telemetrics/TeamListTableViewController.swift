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

class TeamListTableViewController: UITableViewController, TeamListDetailDataSource {
    @IBOutlet weak var incompleteEventView: UIView!
    @IBOutlet weak var graphButton: UIBarButtonItem!
    @IBOutlet weak var eventSelectionButton: EventSelectionTitleButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var matchesButton: UIBarButtonItem!
    
    private var searchController: UISearchController!
    #warning("Redo team images")
	private var teamImageCache = NSCache<NSString, UIImage>()
    private var teamListSplitVC: FASTMainSplitViewController? {
        get {
            return splitViewController as? FASTMainSplitViewController
        }
    }
    
    private var statToSortBy: Statistic<ScoutedTeam>?
    private var stashedStats: [String: StatValue] = [:] {
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
    private var isSortingAscending: Bool = false
    
    private var isSearching = false
    
    private var unorderedTeamsInEvent: [Team] = []
    
    //MARK: Team List State Storage
    ///These are a hieracrhy of more and increasingly filtered and sorted teams
    private var currentEventTeams: [Team] = [Team]() {
        didSet {
            sortList(withStat: statToSortBy, isAscending: isSortingAscending)
        }
    }
    private var currentSortedTeams: [Team] = [] {
        didSet {
            self.updateSearchResults(for: searchController)
        }
    }
    //Searching would happen right in between these two
    ///This is always exaclty what the table view will display
    private var currentTeamsToDisplay = [Team]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var selectedTeam: Team? {
        didSet {
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
    private let lastSelectedEventStorageKey = "Last-Selected-Event"
    private var selectedEventRanking: EventRanking?
    ///The currently selected event, ONLY to be set by the selectedEvent(_:) method
    private var selectedEventKey: String?
    ///The Event key that is preferred to be displayed, set by calling the preferSelection(ofEvent:) method. Usually associated with restoring a user activity. Will prefer this event key over the one stored in UserDefaults
    private var preferredEventKey: String?
    
    //MARK: - View Did Load
    private let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        tableView.allowsSelectionDuringEditing = true
       
        //Set up the nav bar buttons
        let settingsButton: UIBarButtonItem
        let eventSelectionDisclosureIndicator: UIBarButtonItem
        if #available(iOS 13.0, *) {
            graphButton = UIBarButtonItem(image: UIImage(systemName: "chart.bar.fill"), style: .plain, target: self, action: #selector(chartButtonPressed(_:)))
            settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsPressed(_:)))
            eventSelectionDisclosureIndicator = UIBarButtonItem(image: UIImage(systemName: "arrowtriangle.down.circle.fill"), style: .plain, target: self, action: #selector(eventSelectionIndicatorPressed(_:)))
        } else {
            // Fallback on earlier versions
            graphButton = UIBarButtonItem(image: UIImage(named: "Chart"), style: .plain, target: self, action: #selector(chartButtonPressed(_:)))
            settingsButton = UIBarButtonItem(image: UIImage(named: "Settings-50"), style: .plain, target: self, action: #selector(settingsPressed(_:)))
            eventSelectionDisclosureIndicator = UIBarButtonItem(title: "Switch Events", style: .plain, target: self, action: #selector(eventSelectionIndicatorPressed(_:)))
        }
        navigationItem.setLeftBarButton(eventSelectionDisclosureIndicator, animated: false)
        navigationItem.setRightBarButtonItems([settingsButton, graphButton], animated: false)
        
        //Set up the searching capabilities and the search bar. At the time of coding, Storyboards do not support the new UISearchController, so this is done programatically.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            tableView.tableHeaderView = searchController.searchBar
        }
        
        navigationItem.largeTitleDisplayMode = .always
        if #available(iOS 13.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navAppearance.backgroundColor = .systemBlue
            navAppearance.buttonAppearance = UIBarButtonItemAppearance()
            navAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationItem.standardAppearance = navAppearance
            navigationItem.scrollEdgeAppearance = navAppearance
            navigationItem.compactAppearance = navAppearance
            
            //Make the bar button items white
            graphButton.tintColor = .white
            settingsButton.tintColor = .white
            eventSelectionDisclosureIndicator.tintColor = .white
            
            //Set the search bar appearance
            let searchTextField = searchController.searchBar.searchTextField
            searchTextField.borderStyle = .roundedRect
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.secondaryLabel])
            searchTextField.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
        
        
        //Set background view of table view
        let noEventView = NoEventSelectedView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height))
        tableView.backgroundView = noEventView
        
        //Add a watcher for when the event switches
        NotificationCenter.default.addObserver(forName: .FASTSelectedEventChanged, object: nil, queue: nil) {[weak self] (notification) in
            if #available(iOS 13.0, *) {
                // Check that this event change happened in this scene
                if notification.userInfo?["sceneId"] as? String == self?.view.window?.windowScene?.session.persistentIdentifier {
                    self?.eventSelected(notification.userInfo?["eventKey"] as? String)
                }
            } else {
                self?.eventSelected(notification.userInfo?["eventKey"] as? String)
            }
        }
        
        //Handle switching scouting teams
        NotificationCenter.default.addObserver(forName: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            self?.stashedStats = [:]
            self?.eventSelected(nil)
            self?.autoChooseEvent()
        }
        
        //If no event is selected, select one
        if selectedEventKey == nil {
            //Select one
            autoChooseEvent()
        }
        
        viewIsLoadedSemaphore.signal()
    }
    
    internal func preferSelection(ofEvent eventKey: String) {
        self.preferredEventKey = eventKey
        if selectedEventKey != preferredEventKey {
            autoChooseEvent()
        }
    }
    
    private func autoChooseEvent() {
        //Get the tracked events
        if let scoutTeam = Globals.dataManager.enrolledScoutingTeamID {
            Globals.appSyncClient?.fetch(query: ListTrackedEventsQuery(scoutTeam: scoutTeam), cachePolicy: .returnCacheDataElseFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListTrackedEvents-TeamList", result: result, error: error) {
                    let eventKeys = result?.data?.listTrackedEvents?.map({$0!.eventKey}) ?? []
                    
                    let useUserDefaultsStoredEvent = {() -> Void in
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
                        
                    }
                    
                    //Check if there is a selected event saved or preferred
                    if let preferredEventKey = self?.preferredEventKey {
                        //Check if it is tracked
                        if eventKeys.contains(preferredEventKey) {
                            //Set it
                            self?.eventSelected(preferredEventKey)
                        } else {
                            //Not tracked
                            useUserDefaultsStoredEvent()
                        }
                    } else {
                        useUserDefaultsStoredEvent()
                    }
                }
            })
        } else {
            self.eventSelected(nil)
        }
    }
    
    //For some reason this is called when moving the app to the background during stands scouting, not sure if this a beta issue or what but it does cause crash
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    //MARK: - Set Up For Event
    //AppSync Cancellable Calls
    private var listScoutedTeamsQuery: Cancellable? {
        willSet {
            listScoutedTeamsQuery?.cancel()
        }
    }
    private var listTeamsQuery: Cancellable? {
        willSet {
            listTeamsQuery?.cancel()
        }
    }
    private var getEventRankingQuery: Cancellable? {
        willSet {
            getEventRankingQuery?.cancel()
        }
    }
    private var eventInterest: FASTInterestToken? {
        didSet {
            oldValue?.cancel()
        }
    }
    private let teamLoadingQueue = DispatchQueue(label: "Team List Loading", qos: .userInteractive)
    
    fileprivate func eventSelected(_ eventKey: String?) {
        selectedEventKey = eventKey
        setUpForEvent()
    }
    private func setUpForEvent() {
        //Set to nil, because the selected team might not be in the new event
        selectedTeam = nil
        teamListSplitVC?.teamDetailVC.load(forInput: nil)
        statToSortBy = nil
        unorderedTeamsInEvent = []
		teamImageCache.removeAllObjects()
        listScoutedTeamsQuery = nil
        listTeamsQuery = nil
        getEventRankingQuery = nil
        //If we are moving to a different event then clear the table otherwise leave it
        if selectedEventRanking?.eventKey != selectedEventKey || selectedEventKey == nil {
            currentEventTeams = []
        }
        
        if let eventKey = selectedEventKey {
            UserDefaults.standard.set(eventKey, forKey: lastSelectedEventStorageKey)
            
            eventInterest = Globals.dataManager.asyncLoadingManager.registerInterest(inEvent: eventKey)
            
            //As a hold over until the event ranking loads
            eventSelectionButton.setTitle(eventKey, for: UIControlState())
            
            if let scoutingTeam = Globals.dataManager.enrolledScoutingTeamID {
                //Get the scouted teams in the cache
                listScoutedTeamsQuery = Globals.appSyncClient?.fetch(query: ListScoutedTeamsQuery(scoutTeam: scoutingTeam, eventKey: eventKey), cachePolicy: .fetchIgnoringCacheData, resultHandler: { (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListHydrateCache", result: result, error: error) {
                    }
                })
                
                listTeamsQuery = Globals.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: eventKey), cachePolicy: .returnCacheDataAndFetch, queue: teamLoadingQueue) {[weak self] result, error in
                    
                    if Globals.handleAppSyncErrors(forQuery: "ListTeams", result: result, error: error) {
                        
                        //Get all of the info on teams in an event
                        self?.unorderedTeamsInEvent = result?.data?.listTeams?.map {return $0!.fragments.team} ?? []
                        
                        //Now, go get the ranking of them
                        self?.getEventRankingQuery = Globals.appSyncClient?.fetch(query: GetEventRankingQuery(scoutTeam: scoutingTeam, key: eventKey), cachePolicy: .returnCacheDataAndFetch, queue: self!.teamLoadingQueue) {[weak self] result, error in
                            if Globals.handleAppSyncErrors(forQuery: "GetEventRanking", result: result, error: error) {
                                self?.selectedEventRanking = result?.data?.getEventRanking?.fragments.eventRanking
                                
                                DispatchQueue.main.async {
                                    if let year = self?.selectedEventRanking?.eventKey.prefix(4) {
                                        //If the event is not in the current year then display the year in front of it to signify it
                                        if year != Calendar.current.component(.year, from: Date()).description {
                                            self?.navigationItem.title = "\(year) \(self?.selectedEventRanking?.eventName ?? "")"
                                        } else {
                                            self?.navigationItem.title = self?.selectedEventRanking?.eventName
                                        }
                                        
                                        //Set a user activity for event selection
                                        let activity = NSUserActivity(activityType: Globals.UserActivity.eventSelection)
                                        activity.title = "View \(self?.navigationItem.title ?? "?")"
                                        activity.userInfo = ["eventKey":eventKey]
                                        activity.requiredUserInfoKeys = Set(arrayLiteral: "eventKey")
                                        activity.isEligibleForSearch = true
                                        activity.isEligibleForHandoff = true
                                        activity.keywords = Set(arrayLiteral: self?.navigationItem.title ?? "event")
                                        activity.becomeCurrent()
                                        if #available(iOS 13.0, *) {
                                            self?.view.window?.windowScene?.userActivity = activity
                                        }
                                    }
                                }
                                
                                self?.orderTeamsUsingRanking()
                            } else {
                                DispatchQueue.main.async {
                                    //Show error
//                                    Globals.presentError(error: error, andResult: result, withTitle: "Unable to Load Team Rank")
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            //Show error
//                            Globals.presentError(error: error, andResult: result, withTitle: "Unable to Load Teams")
                        }
                    }
                }
            }
            
            matchesButton.isEnabled = true
            graphButton.isEnabled = true
            
            Globals.recordAnalyticsEvent(eventType: AnalyticsEventViewItemList, attributes: [AnalyticsParameterItemList:eventKey])
        } else {
            currentEventTeams = []
            selectedEventRanking = nil
            
            eventSelectionButton.setTitle("Select Event", for: UIControlState())
            
            matchesButton.isEnabled = false
            graphButton.isEnabled = false
            
            eventInterest = nil
        }
        
        self.resetSubscriptions()
    }
    
    private func orderTeamsUsingRanking() {
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
    private func reloadEvent(eventKey: String) {
        if let scoutingTeam = Globals.dataManager.enrolledScoutingTeamID {
            Globals.appSyncClient?.perform(mutation: AddTrackedEventMutation(scoutTeam: scoutingTeam, eventKey: eventKey), optimisticUpdate: {transaction in
                
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
    }
    
    deinit {
        trackedEventsWatcher?.cancel()
        changeTeamRankSubscriber?.cancel()
        pickedTeamSubscriber?.cancel()
    }
    
    private var trackedEventsWatcher: GraphQLQueryWatcher<ListTrackedEventsQuery>?
    private var changeTeamRankSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnUpdateTeamRankSubscription>?
    private var pickedTeamSubscriber: AWSAppSync.AWSAppSyncSubscriptionWatcher<OnSetTeamPickedSubscription>?
    private func resetSubscriptions() {
        CLSNSLogv("Resetting Team List Subscriptions", getVaList([]))
        
        trackedEventsWatcher?.cancel()
        changeTeamRankSubscriber?.cancel()
        pickedTeamSubscriber?.cancel()
        
        //Set up a watcher to event deletions
        if let scoutingTeam = Globals.dataManager.enrolledScoutingTeamID {
            trackedEventsWatcher = Globals.appSyncClient?.watch(query: ListTrackedEventsQuery(scoutTeam: scoutingTeam), cachePolicy: .returnCacheDataDontFetch, resultHandler: {[weak self] (result, error) in
                DispatchQueue.main.async {
                    let trackedEvents = result?.data?.listTrackedEvents?.map({$0!}) ?? []
                    
                    if let selectedEventKey = self?.selectedEventKey {
                        if !trackedEvents.contains(where: {$0.eventKey == selectedEventKey}) {
                            //Event was removed
                            //TODO: Bette handle event removals, because if this is uncommented state restoration with nsuseractivities will not work
                            //                        self?.eventSelected(nil)
                        }
                    } else {
                        if let newEventKey = trackedEvents.first?.eventKey {
                            self?.eventSelected(newEventKey)
                        }
                    }
                }
            })
            
            if let eventKey = self.selectedEventKey {
                //Set up subscribers for event specifics
                do {
//                    changeTeamRankSubscriber = try Globals.appSyncClient?.subscribe(subscription: OnUpdateTeamRankSubscription(scoutTeam: scoutingTeam, eventKey: eventKey), queue: DispatchQueue.global(qos: .utility)) {[weak self] result, transaction, error in
//                        if Globals.handleAppSyncErrors(forQuery: "OnUpdateTeamRankSubscription", result: result, error: error) {
//                            DispatchQueue.main.async {
//                                self?.selectedEventRanking = result?.data?.onUpdateTeamRank?.fragments.eventRanking
//                                self?.orderTeamsUsingRanking()
//                            }
//
//                            //TODO: Edit the transaction cache
//                        } else {
//                            if let error = error as? AWSAppSyncSubscriptionError {
//                                if error.recoverySuggestion != nil {
//                                    self?.resetSubscriptions()
//                                }
//                            }
//                        }
//                    }
//
//                    pickedTeamSubscriber = try Globals.appSyncClient?.subscribe(subscription: OnSetTeamPickedSubscription(scoutTeam: scoutingTeam, eventKey: eventKey), queue: DispatchQueue.global(qos: .utility)) {[weak self] result, transaction, error in
//                        if Globals.handleAppSyncErrors(forQuery: "OnSetTeamPickedSubscription", result: result, error: error) {
//                            //TODO: Update the cache
//                            DispatchQueue.main.async {
//                                self?.selectedEventRanking = result?.data?.onSetTeamPicked?.fragments.eventRanking
//
//                                //Reload the cell
//                                if let visibleRows = self?.tableView.indexPathsForVisibleRows {
//                                    self?.tableView.reloadRows(at: visibleRows, with: UITableView.RowAnimation.none)
//                                }
//                            }
//                        } else {
//                            if let error = error as? AWSAppSyncSubscriptionError {
//                                if error.recoverySuggestion != nil {
//                                    self?.resetSubscriptions()
//                                }
//                            }
//                        }
//                    }
                } catch {
                    CLSNSLogv("Error starting subcriptions: \(error)", getVaList([]))
                    Crashlytics.sharedInstance().recordError(error)
                    //TODO: Handle this error
                }
            } else {
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
        
        //TODO: Move this to a generic "updates" screen whose presentation is controlled by cloud config
        //Show the Deep Space welcome if it has not been shown
//        if !(UserDefaults.standard.value(forKey: "HasShownDeepSpaceWelcome") as? Bool ?? false) {
//            let deepSpaceWelcome = storyboard!.instantiateViewController(withIdentifier: "deepSpaceWelcome")
//            self.present(deepSpaceWelcome, animated: true, completion: nil)
//        }
        
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
		
		teamImageCache.removeAllObjects()
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

    //MARK: Cell for Row at
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
		let cacheKey = "\(selectedEventKey ?? "")-\(team.key)"
		if let image = teamImageCache.object(forKey: cacheKey as NSString) {
            cell.frontImage.image = image
        } else {
            cell.frontImage.image = UIImage(named: "FRC-Logo")
            //TODO: Redo this implementation of images in cells
//            Globals.appSyncClient?.fetch(query: ListScoutedTeamsQuery(scoutTeam: Globals.dataManager.enrolledScoutingTeamID ?? "", eventKey: selectedEventKey ?? ""), cachePolicy: .returnCacheDataDontFetch, resultHandler: {[weak self] (result, error) in
//                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListCellForRowAt", result: result, error: error) {
//					if let scoutedTeam = result?.data?.listScoutedTeams?.first(where: {$0?.teamKey == team.key})??.fragments.scoutedTeam {
//						if let imageInfo = scoutedTeam.image {
//							TeamImageLoader.default.loadImage(withAttributes: imageInfo, progressBlock: { (progress) in
//
//							}, completionHandler: { (image, error) in
//								if let image = image {
//									if cell.stateID == stateID {
//										DispatchQueue.main.async {
//											cell.frontImage.image = image
//										}
//									}
//									self?.teamImageCache.setObject(image, forKey: cacheKey as NSString)
//								} else {
//								}
//							})
//						} else {
//                        }
//                    } else {
//                    }
//                }
//            })
        }
        
        //Show the indicator if this is the team that is currently logged in
        cell.myTeamIndicatorImageView.isHidden = true
        if let loggedInTeam = AWSMobileClient.default().username {
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
        
        //Set the selected team (and alert the delegate)
        selectedTeam = pressedTeam
        
        //Show the detail vc
        if let teamKey = selectedTeam?.key, let eventKey = selectedEventKey {
            teamListSplitVC?.teamDetailVC.load(forInput: (teamKey,eventKey))
        }
        if let vc = teamListSplitVC?.teamDetailVC {
            splitViewController?.showDetailViewController(vc, sender: self)
        }
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
        
        if let eventKey = selectedEventKey, let scoutTeam = selectedEventRanking?.scoutTeam {
            let team = self.currentTeamsToDisplay[indexPath.row]
            
            let markAsPicked = UIContextualAction(style: .normal, title: "Mark Picked") {(contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                
                //Check if it is picked yet
                let rankedTeam = self.selectedEventRanking?.rankedTeams?.first {$0!.teamKey == team.key}
                let isPicked = rankedTeam??.isPicked ?? false
                
                Globals.appSyncClient?.perform(mutation: SetTeamPickedMutation(scoutTeam: scoutTeam, eventKey: eventKey, teamKey: team.key, isPicked: !isPicked), optimisticUpdate: { (transaction) in
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
        guard let eventKey = selectedEventKey, let scoutTeam = selectedEventRanking?.scoutTeam else {
            return
        }
        
        //Get the team key
        let team = currentTeamsToDisplay[fromIndexPath.row]
        let previousRanking = selectedEventRanking
        
        Globals.appSyncClient?.perform(mutation: MoveRankedTeamMutation(scoutTeam: scoutTeam, eventKey: eventKey, teamKey: team.key, toIndex: toIndexPath.row), queue: DispatchQueue.global(qos: .userInitiated), optimisticUpdate: { (transaction) in
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
                
                let _ = Globals.appSyncClient?.store?.withinReadWriteTransaction({ (transaction) -> Any in
                    try? transaction.updateObject(ofType: EventRanking.self, withKey: "ranking_\(eventKey)", { (selectionSet) in
                        if let ranking = result?.data?.moveRankedTeam?.fragments.eventRanking {
                            selectionSet = ranking
                        }
                    }) as Any
                })
            } else {
                self?.selectedEventRanking = previousRanking
//                let alert = UIAlertController(title: "Error Moving Team", message: "There was an error moving the team. Make sure you are connected to the Internet and try again. \(Globals.descriptions(ofError: error, andResult: result))", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
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
        guard let selectedEventKey = selectedEventKey, let eventRanking = selectedEventRanking else {
            currentSortedTeams = currentEventTeams
            return
        }
        
        self.isSortingAscending = ascending
        
        statToSortBy = stat
        
        if let newStat = stat {
            //Grab the scouted teams
            Globals.appSyncClient?.fetch(query: ListScoutedTeamsQuery(scoutTeam: eventRanking.scoutTeam, eventKey: selectedEventKey), cachePolicy: .returnCacheDataElseFetch, queue: statsOrderingQueue, resultHandler: {[weak self] (result, error) in
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
    
    //MARK: - Button Presses
    let slideInTransitionDelegate = TeamListSlideInTransitioningDelegate()
    @objc func eventSelectionIndicatorPressed(_ sender: UIBarButtonItem) {
        //Slide down the event selector
        let eventSelectorVC = storyboard?.instantiateViewController(withIdentifier: "eventSelector")
        eventSelectorVC?.modalPresentationStyle = .custom
        eventSelectorVC?.transitioningDelegate = slideInTransitionDelegate
        self.present(eventSelectorVC!, animated: true, completion: nil)
    }
    
    @IBAction func matchesButtonPressed(_ sender: UIBarButtonItem) {
        teamListSplitVC?.matchOverviewMasterVC.load(forEventKey: selectedEventKey)
        teamListSplitVC?.switchToContentMode(.Matches)
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"screen", "item_id":"matches_overview"])
    }
    
    @objc func settingsPressed(_ sender: UIBarButtonItem) {
        guard let adminConsoleNavController = storyboard?.instantiateViewController(withIdentifier: "adminConsoleNav") else { return }
        present(adminConsoleNavController, animated: true, completion: nil)
    }
    
    @objc func chartButtonPressed(_ sender: UIBarButtonItem) {
        if let eventKey = selectedEventKey, let scoutTeam = selectedEventRanking?.scoutTeam {
            let eventStatGraphVC = storyboard?.instantiateViewController(withIdentifier: "eventStatsGraph") as! EventStatsGraphViewController
            let navVC = UINavigationController(rootViewController: eventStatGraphVC)
            
//            navVC.modalPresentationStyle = .fullScreen
            
            eventStatGraphVC.setUp(forScoutTeam: scoutTeam, withEventKey: eventKey)
            
            present(navVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnToTeamList(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returningWithSegue(_ segue: UIStoryboardSegue) {
        
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
    
    func eventKey() -> String? {
        return self.selectedEventKey
    }
}

//MARK: - Searching
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
                Globals.recordAnalyticsEvent(eventType: AnalyticsEventSearch, attributes: [AnalyticsParameterSearchTerm:searchText], metrics: ["results":Double(filteredTeams.count)])
            }
        } else {
            currentTeamsToDisplay = currentSortedTeams
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
//        if #available(iOS 13.0, *) {
//            searchController.transitionCoordinator?.animate(alongsideTransition: { (transitionCoordinatorContext) in
//
//                self.searchController.searchBar.backgroundColor = UIColor.systemBackground
//
//            }, completion: nil)
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                searchController.transitionCoordinator?.animate(alongsideTransition: { (context) in
                    
                    self.searchController.searchBar.backgroundColor = self.navigationItem.standardAppearance?.backgroundColor
                    
                }, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
        if #available(iOS 13.0, *) {
            self.searchController.searchBar.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.setToolbarHidden(true, animated: true)
        Globals.recordAnalyticsEvent(eventType: "began_team_list_searching")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //Set the current teams to display back
        currentTeamsToDisplay = currentSortedTeams
        isSearching = false
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
}


//MARK: - Slide In Transition Animation
class TeamListSlideInTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is EventSelectorTableViewController {
            return EventSelectionSlideInPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is SortVC {
            return SortStatSelectionSlideInPresentationController(presentedViewController: presented, presenting: presenting)
        } else {
            fatalError()
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = TeamListSlideInAnimationController()
        controller.isPresenting = true
        return controller
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = TeamListSlideInAnimationController()
        controller.isPresenting = false
        return controller
    }
}
class TeamListSlideInPresentationController: UIPresentationController {
    let dimView: UIVisualEffectView
    var coverSnapshot: UIView?
    var tapGestureRecognizer: UITapGestureRecognizer!
    var teamListTableViewController: TeamListTableViewController?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        if #available(iOS 13.0, *) {
            dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        } else {
            // Fallback on earlier versions
            dimView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        }
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.isUserInteractionEnabled = true
        dimView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        let teamListSplitViewController = (presentingViewController as? FASTMainSplitViewController)
        teamListTableViewController = teamListSplitViewController?.teamListTableVC
        
        //Create a dimming view
        dimView.alpha = 0
        dimView.frame = containerView?.frame ?? .zero
        containerView?.addSubview(dimView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (transitionCoordinatorContext) in
            self.dimView.alpha = 1
        }, completion: { (coordinatorContext) in
            
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (coordinatorContext) in
            self.dimView.alpha = 0
        }, completion: { (coordinatorContext) in
            self.dimView.removeFromSuperview()
            self.coverSnapshot?.removeFromSuperview()
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
//        self.dimView.removeFromSuperview()
//        self.coverSnapshot?.removeFromSuperview()
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
    }
    
    @objc func dismiss(_ sender: Any) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

class EventSelectionSlideInPresentationController: TeamListSlideInPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        //First for the origin: the view is going to slide in right below the nav bar
        let yCoord = (teamListTableViewController?.navigationController?.navigationBar.frame.origin.y ?? CGFloat.zero) + (teamListTableViewController?.navigationController?.navigationBar.frame.height ?? CGFloat.zero) //- (teamListTableViewController?.searchController.searchBar.frame.height ?? CGFloat.zero)
        //            let yCoord = teamListTableViewController?.navigationController?.navigationBar.frame.height ?? .zero
        let origin = CGPoint(x: CGFloat.zero, y: yCoord)
        
        //Now add the size to it
        let width = teamListTableViewController?.tableView.frame.width ?? CGFloat.zero
        //            let height = (presentedViewController as? UITableViewController)?.tableView.contentSize.height ?? CGFloat(250)
        //            let height = presentedViewController.view.intrinsicContentSize.height
        let height = CGFloat(300)
        
        let size = CGSize(width: width, height: height)
        
        let rect = CGRect(origin: origin, size: size)
        return rect
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        //Create a cover snapshot
        coverSnapshot = teamListTableViewController?.navigationController?.navigationBar.snapshotView(afterScreenUpdates: false)
        coverSnapshot?.frame = teamListTableViewController?.navigationController?.navigationBar.frame ?? CGRect.zero
        coverSnapshot?.backgroundColor = presentedView?.backgroundColor
        coverSnapshot?.isUserInteractionEnabled = false
        coverSnapshot?.tag = 1
        
        //Add a white view to the cover snapshot that covers the status bar portion
        let size = CGSize(width: teamListTableViewController?.tableView.frame.width ?? .zero, height: coverSnapshot?.frame.origin.y ?? .zero)
        let frame = CGRect(origin: CGPoint(x: 0, y: -size.height), size: size)
        let whiteCoverView = UIView(frame: frame)
        if #available(iOS 13.0, *) {
            whiteCoverView.backgroundColor = teamListTableViewController?.navigationItem.standardAppearance?.backgroundColor
        } else {
            whiteCoverView.backgroundColor = coverSnapshot?.backgroundColor
        }
        coverSnapshot?.addSubview(whiteCoverView)
        
        if let snap = coverSnapshot {
            containerView?.addSubview(snap)
        }
    }
}

class SortStatSelectionSlideInPresentationController: TeamListSlideInPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let height = CGFloat(300)
        let width = teamListTableViewController?.tableView.frame.width ?? .zero
        
        let xCoord: CGFloat
        if #available(iOS 11.0, *) {
            xCoord = teamListTableViewController?.tableView.safeAreaInsets.left ?? .zero
        } else {
            // Fallback on earlier versions
            xCoord = 0
        }
        
        let yCoord = (teamListTableViewController?.navigationController?.toolbar.frame.origin.y ?? .zero) - height
        
        return CGRect(x: xCoord, y: yCoord, width: width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        //Create the toolbar cover snapshot
        coverSnapshot = teamListTableViewController?.navigationController?.toolbar.snapshotView(afterScreenUpdates: false)
        coverSnapshot?.frame = teamListTableViewController?.navigationController?.toolbar.frame ?? .zero
        coverSnapshot?.backgroundColor = presentedView?.backgroundColor
        
        //Add a cover view to cover the bottom part of the screen
        if #available(iOS 11.0, *) {
            let size = CGSize(width: teamListTableViewController?.tableView.frame.width ?? .zero, height: teamListTableViewController?.tableView.safeAreaInsets.bottom ?? .zero)
            let frame = CGRect(origin: CGPoint(x: teamListTableViewController?.tableView.safeAreaInsets.left ?? .zero, y: coverSnapshot?.frame.height ?? .zero), size: size)
            let additionalCover = UIView(frame: frame)
            additionalCover.backgroundColor = coverSnapshot?.backgroundColor
            coverSnapshot?.addSubview(additionalCover)
        } else {
            // Fallback on earlier versions
        }
        
        coverSnapshot?.isUserInteractionEnabled = false
        coverSnapshot?.tag = 1
        
        if let snap = coverSnapshot {
            containerView?.addSubview(snap)
        }
    }
}

class TeamListSlideInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresenting = true
    let duration: TimeInterval = 0.35
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
//        let containerView = transitionContext.containerView
        guard let toView = toVC?.view, let fromView = fromVC?.view else {
            assertionFailure()
            return
        }
        
        if isPresenting {
            //Add the toView behind the navBar cover snapshot which has a tag of 1, declared in the TeamListSlideInPresentationController
            if let coverSnap = transitionContext.containerView.viewWithTag(1) {
                transitionContext.containerView.insertSubview(toView, belowSubview: coverSnap)
            } else {
                transitionContext.containerView.addSubview(toView)
            }
            
            //Start State
            toView.alpha = 0.5
            let finalFrame: CGRect = transitionContext.finalFrame(for: toVC!)
            //Figure out the start frame
            if toVC is EventSelectorTableViewController {
                let startOrigin = CGPoint(x: 0, y: finalFrame.origin.y - finalFrame.height)
                let startFrame = CGRect(origin: startOrigin, size: finalFrame.size)
                toView.frame = startFrame
            } else if toVC is SortVC {
                let startOrigin = CGPoint(x: 0, y: finalFrame.origin.y + finalFrame.height)
                toView.frame = CGRect(origin: startOrigin, size: finalFrame.size)
            }
            
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(1), initialSpringVelocity: CGFloat(0.5), options: [.curveEaseOut], animations: {
                toView.alpha = 1
                toView.frame = finalFrame
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        } else {
            //Dismissing
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(1), initialSpringVelocity: CGFloat(1), options: [.curveEaseIn], animations: {
                fromView.alpha = 1
                
                //Get endFrame for the slide in list
                if fromVC is EventSelectorTableViewController {
                    let endOrigin = CGPoint(x: 0, y: fromView.frame.origin.y - fromView.frame.height - 50)
                    fromView.frame = CGRect(origin: endOrigin, size: fromView.frame.size)
                } else if fromVC is SortVC {
                    let endOrigin = CGPoint(x: fromView.frame.origin.x, y: fromView.frame.origin.y + fromView.frame.height + 50)
                    fromView.frame = CGRect(origin: endOrigin, size: fromView.frame.size)
                }
            }) { (completed) in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(completed)
            }
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
}
