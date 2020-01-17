//
//  TeamListDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import Crashlytics
import SafariServices
import AWSAppSync
import AWSMobileClient
import Firebase

protocol TeamListDetailDataSource {
    func team() -> Team?
    func inEventKey() -> String?
}

class TeamListDetailViewController: UIViewController {
    @IBOutlet weak var frontImageButton: UIButton!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var standsScoutingButton: UIBarButtonItem!
    @IBOutlet weak var pitScoutingButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var frontImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var generalInfoTableView: UITableView?
    @IBOutlet weak var contentScrollView: TeamInfoScrollView!
    @IBOutlet weak var detailTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var detailCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var matchesButton: UIButton!
    @IBOutlet weak var bananaImageView: UIImageView!
    @IBOutlet weak var bananaImageWidth: NSLayoutConstraint!
    
    private var detailCollectionVC: TeamDetailCollectionViewController?
    
    var dataSource: TeamListDetailDataSource?
    
    //Insets for the scroll view
    private var contentViewInsets: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(frontImageHeightConstraint.constant, 0, 0, 0)
        }
    }
    private var noContentInsets: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    private var frontImage: TeamImagePhoto? {
        didSet {
            frontImageButton.setImage(frontImage?.image, for: .normal)
        }
    }
    
    private(set) var selectedTeam: Team?
    private var scoutedTeam: ScoutedTeam?
    private var selectedEventKey: String?
    
    private var statusString: String?
    
    private let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        generalInfoTableView?.translatesAutoresizingMaskIntoConstraints = false
        generalInfoTableView?.isScrollEnabled = false
        
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        
        //Set the stands scouting button to not selectable since there is no team selected
        standsScoutingButton.isEnabled = false
        pitScoutingButton.isEnabled = false
        matchesButton.isEnabled = false
        
        if Globals.isInSpectatorMode {
            standsScoutingButton.tintColor = UIColor.purple
            pitScoutingButton.tintColor = UIColor.purple
            notesButton.tintColor = UIColor.purple
            
            let selector = #selector(showLoginPromotional)
            
            notesButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
            standsScoutingButton.target = self
            standsScoutingButton.action = selector
            pitScoutingButton.target = self
            pitScoutingButton.action = selector
        }
        
        //Set the images(buttons) content sizing property
        frontImageButton.imageView?.contentMode = .scaleAspectFill
        frontImageButton.setTitle(nil, for: .normal)
        
        contentScrollView.delegate = self
        
        if let displayModeButtonItem = splitViewController?.displayModeButtonItem {
            if navigationItem.leftBarButtonItems?.isEmpty ?? true {
                navigationItem.leftBarButtonItems = [displayModeButtonItem]
            } else {
                navigationItem.leftBarButtonItems?.insert(displayModeButtonItem, at: 0)
            }
        }
        
        generalInfoTableView?.delegate = self
        generalInfoTableView?.dataSource = self
        generalInfoTableView?.rowHeight = UITableViewAutomaticDimension
        generalInfoTableView?.estimatedRowHeight = 44
        
        NotificationCenter.default.addObserver(forName: .FASTAWSDataManagerCurrentScoutingTeamChanged, object: nil, queue: OperationQueue.main) {[weak self] (notification) in
            //Discard any shared data
            self?.load(forInput: nil)
        }
        viewIsLoadedSemaphore.signal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "standsScouting" {
            let destinationVC = segue.destination as! StandsScoutingViewController
            destinationVC.setUp(inScoutTeam: scoutedTeam?.scoutTeam ?? "", forTeamKey: self.selectedTeam?.key ?? "", andEventKey: self.selectedEventKey ?? "")
            
            Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["Source":"team_detail_button", "content_type":"screen", "item_id":"stands_scouting"])
        } else if segue.identifier == "teamDetailCollection" {
            detailCollectionVC = (segue.destination as! TeamDetailCollectionViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private var updateTeamSubcription: AWSAppSyncSubscriptionWatcher<OnUpdateScoutedTeamSubscription>?
    private var listScoutedTeamsWatcher: GraphQLQueryWatcher<ListScoutedTeamsQuery>?
    private var listStatusesWatcher: GraphQLQueryWatcher<ListTeamEventStatusesQuery>?
    
    /// Sets the team detail to display info on the specified team in the specified event
    /// - Parameter input: The input parameters
    internal func load(forInput input: (teamKey: String, eventKey: String)?) {
        if input?.teamKey != self.selectedTeam?.key || input?.eventKey != self.selectedEventKey {
            
            listScoutedTeamsWatcher?.cancel()
            listStatusesWatcher?.cancel()
            
            
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                if let input = input, let scoutingTeam = Globals.dataManager.enrolledScoutingTeamID {

                    DispatchQueue.main.async {
                        let activity = NSUserActivity(activityType: Globals.UserActivity.viewTeamDetail)
                        activity.title = "View Team \(input.teamKey) in \(input.eventKey)"
                        activity.isEligibleForHandoff = true
                        activity.isEligibleForSearch = true
                        activity.addUserInfoEntries(from: ["teamKey":input.teamKey, "eventKey":input.eventKey, "scoutingTeam":scoutingTeam])
                        activity.requiredUserInfoKeys = Set(arrayLiteral: "teamKey", "eventKey")
                        activity.becomeCurrent()
                        if #available(iOS 13.0, *) {
                            self?.view.window?.windowScene?.userActivity = activity
                        }
                    }
                    
                    //Get the team data
                    Globals.appSyncClient?.fetch(query: ListTeamsQuery(eventKey: input.eventKey), cachePolicy: .returnCacheDataDontFetch, queue: DispatchQueue.global(qos: .userInitiated), resultHandler: { (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "ListTeams-TeamDetail", result: result, error: error) {
                            if let team = result?.data?.listTeams?.first(where: {$0?.key == input.teamKey})??.fragments.team {
                                self?.selectedTeam = team
                                self?.updateView()
                                
                            }
                        }
                    })
                    //Grab the scouted data
                    self?.listScoutedTeamsWatcher = Globals.appSyncClient?.watch(query: ListScoutedTeamsQuery(scoutTeam: scoutingTeam, eventKey: input.eventKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                        if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListDetail", result: result, error: error) {
                            let sTeams = result?.data?.listScoutedTeams?.map({$0!.fragments.scoutedTeam}) ?? []
                            
                            self?.scoutedTeam = sTeams.first(where: {$0.teamKey == input.teamKey})
                            
                            self?.updateView()
                        } else {
                            
                        }
                    })
                    
                    //Status
                    self?.listStatusesWatcher = Globals.appSyncClient?.watch(query: ListTeamEventStatusesQuery(eventKey: input.eventKey), cachePolicy: .returnCacheDataElseFetch) {[weak self] result, error in
                        if Globals.handleAppSyncErrors(forQuery: "TeamListDetail-ListTeamEventStatusesQuery", result: result, error: error) {
                            let statuses = result?.data?.listTeamEventStatuses
                            let str = statuses?.first(where: {$0?.teamKey ?? "" == input.teamKey})??.fragments.teamEventStatus.overallStatusStr
                            if str != self?.statusString {
                                self?.statusString = str
                                self?.generalInfoTableView?.reloadData()
                                self?.resizeDetailViewHeights()
                            }
                        } else {
                            //TODO: - Show error
                        }
                    }
                }
                
                self?.viewIsLoadedSemaphore.wait()
                self?.viewIsLoadedSemaphore.signal()
                
                //Preform work with the view in this
                DispatchQueue.main.async {
                    self?.generalInfoTableView?.reloadData()
                    self?.updateView()
                    self?.setImage(image: nil)
                }
                
                Globals.recordAnalyticsEvent(eventType: AnalyticsEventViewItem, attributes: [AnalyticsParameterItemCategory:"team", AnalyticsParameterItemID:"\(String(describing: input?.eventKey))_\(String(describing: input?.teamKey))"])
            }
            
            self.selectedEventKey = input?.eventKey
            self.scoutedTeam = nil
            self.statusString = nil
        }
    }
    
    private func setImage(image: UIImage?) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.viewIsLoadedSemaphore.wait()
            self.viewIsLoadedSemaphore.signal()
            DispatchQueue.main.sync {
                if let image = image {
                    self.frontImage = TeamImagePhoto(image: image, attributedCaptionTitle: NSAttributedString(string: "Team \(self.selectedTeam?.teamNumber ?? 0): Front Image"))
                    self.frontImageHeightConstraint.isActive = true
                    
                    self.contentScrollView.contentInset = self.contentViewInsets
                    self.contentScrollView.scrollIndicatorInsets = self.contentViewInsets
                    
                    self.contentScrollView.contentOffset = CGPoint(x: 0, y: -self.frontImageHeightConstraint.constant)
                } else {
                    self.frontImage = nil
                    self.frontImageHeightConstraint.isActive = false
                    
                    self.contentScrollView.contentInset = self.noContentInsets
                    self.contentScrollView.scrollIndicatorInsets = self.noContentInsets
                    
                    self.contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
    private func updateView() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewIsLoadedSemaphore.wait()
            self.viewIsLoadedSemaphore.signal()
            DispatchQueue.main.async {
                if let team = self.selectedTeam {
                    self.navBar.title = team.teamNumber.description
                    self.teamLabel.text = team.nickname
                    
                    if let _ = self.selectedEventKey {
                        self.standsScoutingButton.isEnabled = true
                        self.matchesButton.isEnabled = true
                    } else {
                        self.standsScoutingButton.isEnabled = false
                        self.matchesButton.isEnabled = false
                    }
                    
                    self.pitScoutingButton.isEnabled = true
                    if !Globals.isInSpectatorMode {
                        self.notesButton.isEnabled = true
                    }
                } else {
                    self.navBar.title = "Select Team"
                    self.teamLabel.text = "Select Team"
                    
                    self.frontImage = nil
                    
                    self.standsScoutingButton.isEnabled = false
                    
                    self.pitScoutingButton.isEnabled = false
                    
                    self.notesButton.isEnabled = false
                }
                
                if let scoutedTeam = self.scoutedTeam {
                    if scoutedTeam.decodedAttributes?.canBanana ?? false {
                        self.bananaImageView.image = #imageLiteral(resourceName: "Banana Filled")
                        self.bananaImageWidth.constant = 40
                    } else {
                        self.bananaImageView.image = nil
                        self.bananaImageWidth.constant = 0
                    }
                    
                    //Get the team image
                    if let imageInfo = scoutedTeam.image {
                        TeamImageLoader.default.loadImage(withAttributes: imageInfo, progressBlock: { (progress) in
                            
                        }) { (image, error) in
                            DispatchQueue.main.async {
                                self.setImage(image: image)
                            }
                        }
                    }
                }
                
                self.detailCollectionVC?.loadStats(forScoutedTeam: self.scoutedTeam)
                
                self.resizeDetailViewHeights()
            }
        }
    }
    
    private func resizeDetailViewHeights() {
        DispatchQueue.main.async {
            self.generalInfoTableView?.layoutIfNeeded()
            
            self.detailCollectionViewHeight.constant = self.detailCollectionVC?.collectionView?.collectionViewLayout.collectionViewContentSize.height ?? 10
            self.detailTableViewHeight.constant = self.generalInfoTableView?.contentSize.height ?? 10
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Reset the content insets
        coordinator.animate(alongsideTransition: {_ in
            if self.scoutedTeam?.image != nil {
                self.contentScrollView.contentInset = self.contentViewInsets
                self.contentScrollView.scrollIndicatorInsets = self.contentViewInsets

                self.contentScrollView.contentOffset = CGPoint(x: 0, y: -self.frontImageHeightConstraint.constant)
            } else {
                self.frontImageHeightConstraint.isActive = false

                self.contentScrollView.contentInset = self.noContentInsets
                self.contentScrollView.scrollIndicatorInsets = self.noContentInsets

                self.contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }

        }, completion: {transitionContext in

            self.resizeDetailViewHeights()
        })
    }
    
    func reloadData() {
        if self.isViewLoaded {
            if let team = dataSource?.team(), let eventKey = dataSource?.inEventKey() {
                self.set(input: (team, eventKey))
            } else {
                self.set(input: nil)
            }
        }
    }
    
    @objc func showLoginPromotional() {
        let loginPromotional = storyboard!.instantiateViewController(withIdentifier: "loginPromotional")
        self.present(loginPromotional, animated: true, completion: nil)
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventPresentOffer, attributes: ["Source":"team_detail", "item_id":"login_promotional", "item_name":"Login Promotional"])
    }
    
    @IBAction func notesButtonPressed(_ sender: UIButton) {
        guard let eventKey = self.selectedEventKey, let teamkey = self.selectedTeam?.key, let scoutTeam = self.scoutedTeam?.scoutTeam else {
            return
        }
        
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
        
        let navVC = UINavigationController(rootViewController: notesVC)
        
        notesVC.load(inScoutTeam: scoutTeam, forEventKey: eventKey, andTeamKey: teamkey)
        
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController?.sourceView = sender
        
        present(navVC, animated: true, completion: nil)
    }
    
    var selectedMatch: Match?
    @IBAction func matchesButtonPressed(_ sender: UIButton) {
        let matchListNav = storyboard?.instantiateViewController(withIdentifier: "matchesListNav") as! UINavigationController
        (matchListNav.topViewController as! MatchesTableViewController).delegate = self
        
        (matchListNav.topViewController as! MatchesTableViewController).load(forEventKey: self.selectedEventKey, specifyingTeam: self.selectedTeam?.key)
        
        matchListNav.modalPresentationStyle = .popover
        matchListNav.preferredContentSize = CGSize(width: 350, height: 500)
        matchListNav.popoverPresentationController?.sourceView = sender
        matchListNav.popoverPresentationController?.canOverlapSourceViewRect = false
        
        present(matchListNav, animated: true, completion: nil)
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"screen","item_id":"team_matches_view"])
    }
    
    @IBAction func pitScoutingButtonPressed(_ sender: UIBarButtonItem) {
        if let teamKey = selectedTeam?.key, let eventKey = selectedEventKey {
            let pitScoutingController = storyboard?.instantiateViewController(withIdentifier: "pitScouting") as! PitScoutingTableViewController
            let navController = UINavigationController(rootViewController: pitScoutingController)
            
            pitScoutingController.load(forTeamKey: teamKey, inEvent: eventKey)
            
            navController.modalPresentationStyle = .popover
            navController.popoverPresentationController?.barButtonItem = sender
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    //MARK: Displaying full screen photos
    @IBAction func selectedImage(_ sender: UIButton) {
        let photo: NYTPhoto
        var photosArray: [NYTPhoto] = []
        switch sender {
        case frontImageButton:
            if let image = frontImage {
                photo = image
            } else {return}
//        case sideImageButton:
//            if let image = sideImage {
//                photo = image
//            } else {return}
        default:
            return
        }
        
        if let image = frontImage {
            photosArray.append(image)
        }
        
        let source = NYTPhotoViewerSinglePhotoDataSource(photo: photo)
        let photoVC = NYTPhotosViewController(dataSource: source, initialPhotoIndex: 0, delegate: self)
        present(photoVC, animated: true, completion: nil)
    }
}

extension TeamListDetailViewController: MatchesTableViewControllerDelegate {
    func hasSelectionEnabled() -> Bool {
        return true
    }
    
    func matchesTableViewController(_ matchesTableViewController: MatchesTableViewController, selectedMatchCell: UITableViewCell?, withAssociatedMatch associatedMatch: Match?) {
        selectedMatch = associatedMatch
        
        let showMatchDetail = {[weak self]() -> Void in
            let matchDetailNav = self?.storyboard?.instantiateViewController(withIdentifier: "matchDetailNav") as! UINavigationController
            let matchDetail = matchDetailNav.topViewController as! MatchOverviewDetailViewController
            
            matchDetail.load(forMatchKey: self?.selectedMatch?.key ?? "", shouldShowExitButton: true, preSelectedTeamKey: self?.selectedTeam?.key)
            
            matchesTableViewController.present(matchDetailNav, animated: true, completion: nil)
        }
        
        if Globals.isInSpectatorMode {
            showMatchDetail()
        } else {
			showMatchDetail()
        }
    }
}

extension TeamListDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let team = selectedTeam {
            var numOfRows = 2
            if let _ = team.website {
                numOfRows += 1
            }
            
            if statusString != nil && statusString != "--" { //TBA puts a -- in for empty status strings
                numOfRows += 1
            }
            
            return numOfRows
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameValue")
            let keyLabel = cell?.contentView.viewWithTag(1) as! UILabel
            
            keyLabel.text = "Location"
            let textWidth = keyLabel.intrinsicContentSize.width
            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = textWidth
            
            (cell?.contentView.viewWithTag(2) as! UILabel).text = selectedTeam?.city
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameValue")
            let keyLabel = cell?.contentView.viewWithTag(1) as! UILabel
            
            keyLabel.text = "Rookie Year"
            let textWidth = keyLabel.intrinsicContentSize.width
            keyLabel.constraints.filter({$0.identifier == "keyWidth"}).first?.constant = textWidth
            
            (cell?.contentView.viewWithTag(2) as! UILabel).text = selectedTeam?.rookieYear?.description
            
            return cell!
        case 2,3:
            
            if let statusString = statusString {
                if statusString != "--" {
                    if indexPath.row == 2 {
                        //Status
                        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell")
                        
                        let statusLabel = cell?.viewWithTag(1) as! UILabel
                        statusLabel.setHTMLFromString(htmlText: statusString)
                        statusLabel.textAlignment = .center
                        
                        return cell!
                    }
                }
            }
            
            //Website
            let cell = tableView.dequeueReusableCell(withIdentifier: "websiteButton")
            
            (cell?.contentView.viewWithTag(1) as! UIButton).addTarget(self, action: #selector(websiteButtonPressed(_:)), for: .touchUpInside)
            
            return cell!
            
        default:
            return UITableViewCell()
        }
    }
    
    @objc func websiteButtonPressed(_ sender: UIButton) {
        if let url = URL(string: selectedTeam?.website ?? "") {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
            Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["item_id":"\(selectedTeam?.key ?? "unk")", "content_type":"team_website"])
        }
    }
}

//MARK: - String Helper function from https://stackoverflow.com/questions/19921972/parsing-html-into-nsattributedtext-how-to-set-font
extension UILabel {
    func setHTMLFromString(htmlText: String) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system'; font-size: \(self.font!.pointSize); text-align:center\">%@</span>", htmlText)
        
        
        //process collection values
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        
        self.attributedText = attrStr
    }
}

class TeamImagePhoto: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    
    init(image: UIImage?, imageData: Data? = nil, attributedCaptionTitle: NSAttributedString) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
    }
}

extension TeamListDetailViewController: NYTPhotosViewControllerDelegate {
    func photosViewController(_ photosViewController: NYTPhotosViewController, captionViewFor photo: NYTPhoto) -> UIView? {
        return nil
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, referenceViewFor photo: NYTPhoto) -> UIView? {
        if let photo = photo as? TeamImagePhoto {
            if photo == frontImage {
                return frontImageButton
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func photosViewController(_ photosViewController: NYTPhotosViewController, titleFor photo: NYTPhoto, at photoIndex: UInt, totalPhotoCount: UInt) -> String? {
        return nil
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, maximumZoomScaleFor photo: NYTPhoto) -> CGFloat {
        return CGFloat(2)
    }
    
    func photosViewController(_ photosViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
        NSLog("Completed Action: \(activityType ?? "Unknown")")
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventShare, attributes: [AnalyticsParameterMethod:activityType ?? "?", AnalyticsParameterContentType:"team_photo", AnalyticsParameterItemID:self.selectedTeam?.key ?? ""])
    }
}
