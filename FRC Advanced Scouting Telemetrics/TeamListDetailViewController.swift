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
    
    var teamListSplitVC: TeamListSplitViewController {
        get {
            splitViewController as! TeamListSplitViewController
        }
    }
    
    var detailCollectionVC: TeamDetailCollectionViewController?
    
    //Insets for the scroll view
    var contentViewInsets: UIEdgeInsets {
        get {
            return UIEdgeInsets.init(top: frontImageHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        }
    }
    var noContentInsets: UIEdgeInsets {
        get {
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var frontImage: TeamImagePhoto? {
        didSet {
            frontImageButton.setImage(frontImage?.image, for: .normal)
        }
    }
    
    var selectedTeam: Team?
    var scoutedTeam: ScoutedTeam?
    var selectedEventKey: String?
    
    var statusString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        generalInfoTableView?.translatesAutoresizingMaskIntoConstraints = false
        generalInfoTableView?.isScrollEnabled = false
        
        navigationItem.leftItemsSupplementBackButton = true
        
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
        
        let displayModeButtonItem = teamListSplitVC.displayModeButtonItem
        
        if navigationItem.leftBarButtonItems?.isEmpty ?? true {
            navigationItem.leftBarButtonItems = [displayModeButtonItem]
        } else {
            navigationItem.leftBarButtonItems?.insert(displayModeButtonItem, at: 0)
        }
        
        generalInfoTableView?.delegate = self
        generalInfoTableView?.dataSource = self
        generalInfoTableView?.rowHeight = UITableView.automaticDimension
        generalInfoTableView?.estimatedRowHeight = 44
        
        //Set up observer to get team change notifications
        if #available(iOS 13.0, *) {
            NotificationCenter.default.publisher(for: .FASTSelectedTeamDidChange, object: teamListSplitVC.teamListTableVC)
                .map { (notification: Notification) -> (team: Team, eventKey: String)? in
                    if let team = notification.userInfo?["team"] as? Team, let eventKey = notification.userInfo?["eventKey"] as? String {
                        return (team, eventKey)
                    } else {
                        return nil
                    }
            }
            .sink {[weak self] (tuple) in
                self?.set(input: tuple)
                
                if let (team, eventKey) = tuple {
                    let activity = NSUserActivity(activityType: Globals.UserActivity.viewTeamDetail)
                    activity.title = "View Team \(team.teamNumber): \(team.nickname) in \(eventKey)"
                    activity.isEligibleForHandoff = true
                    activity.isEligibleForSearch = true
                    activity.addUserInfoEntries(from: ["teamKey":team.key, "eventKey":eventKey])
                    activity.requiredUserInfoKeys = Set(arrayLiteral: "teamKey", "eventKey")
                    activity.becomeCurrent()
                    if #available(iOS 13.0, *) {
                        self?.view.window?.windowScene?.userActivity = activity
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            NotificationCenter.default.addObserver(forName: .FASTSelectedTeamDidChange, object: teamListSplitVC.teamListTableVC, queue: nil) { (notification) in
                if let team = notification.userInfo?["team"] as? Team, let eventKey = notification.userInfo?["eventKey"] as? String {
                    self.set(input: (team, eventKey))
                } else {
                    self.set(input: nil)
                }
            }
        }
        
        //Load the data if a team was selected beforehand
        NotificationCenter.default.post(name: .FASTSelectedTeamDidChange, object: teamListSplitVC.teamListTableVC, userInfo: ["team": teamListSplitVC.teamListTableVC.selectedTeam, "eventKey":teamListSplitVC.teamListTableVC.selectedEventRanking?.eventKey])
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
            destinationVC.setUp(forTeamKey: self.selectedTeam?.key ?? "", andEventKey: self.selectedEventKey ?? "")
            
            Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["Source":"team_detail_button", "content_type":"screen", "item_id":"stands_scouting"])
        } else if segue.identifier == "pitScouting" {
            let pitScoutingVC = segue.destination as! PitScoutingViewController
            pitScoutingVC.setUp(forTeamKey: self.selectedTeam?.key ?? "", inEvent: self.selectedEventKey ?? "")
        } else if segue.identifier == "teamDetailCollection" {
            detailCollectionVC = (segue.destination as! TeamDetailCollectionViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var updateTeamSubcription: AWSAppSyncSubscriptionWatcher<OnUpdateScoutedTeamSubscription>?
    var listScoutedTeamsWatcher: GraphQLQueryWatcher<ListScoutedTeamsQuery>?
    var listStatusesWatcher: GraphQLQueryWatcher<ListTeamEventStatusesQuery>?
    func set(input: (team: Team, eventKey: String)?) {
        listScoutedTeamsWatcher?.cancel()
        listStatusesWatcher?.cancel()
        
        self.selectedEventKey = input?.eventKey
        self.selectedTeam = input?.team
        self.scoutedTeam = nil
        self.statusString = nil
        generalInfoTableView?.reloadData()
        self.updateView()
        setImage(image: nil)
        
        if let input = input {
            //Grab the scouted data
            listScoutedTeamsWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListScoutedTeamsQuery(eventKey: self.selectedEventKey ?? ""), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListScoutedTeams-TeamListDetail", result: result, error: error) {
                    let sTeams = result?.data?.listScoutedTeams?.map({$0!.fragments.scoutedTeam}) ?? []
                    
                    self?.scoutedTeam = sTeams.first(where: {$0.teamKey == input.team.key})
                    
                    self?.updateView()
                } else {
                    
                }
            })
            
            //Status
            listStatusesWatcher = Globals.appDelegate.appSyncClient?.watch(query: ListTeamEventStatusesQuery(eventKey: input.eventKey), cachePolicy: .returnCacheDataElseFetch) {[weak self] result, error in
                if Globals.handleAppSyncErrors(forQuery: "TeamListDetail-ListTeamEventStatusesQuery", result: result, error: error) {
                    let statuses = result?.data?.listTeamEventStatuses
                    let str = statuses?.first(where: {$0?.teamKey ?? "" == input.team.key})??.fragments.teamEventStatus.overallStatusStr
                    if str != self?.statusString {
                        self?.statusString = str
                        self?.generalInfoTableView?.reloadData()
                        self?.resizeDetailViewHeights()
                    }
                } else {
                    //TODO: - Show error
                }
            }
        } else {
            self.scoutedTeam = nil
        }
        
        self.resetSubscriptions()
    }
    
    func resetSubscriptions() {
    }
    
    private func setImage(image: UIImage?) {
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
    
    private func updateView() {
        if let team = self.selectedTeam {
            navBar.title = team.teamNumber.description
            teamLabel.text = team.nickname
            
            if let _ = selectedEventKey {
                standsScoutingButton.isEnabled = true
                matchesButton.isEnabled = true
            } else {
                standsScoutingButton.isEnabled = false
                matchesButton.isEnabled = false
            }
            
            pitScoutingButton.isEnabled = true
            if !Globals.isInSpectatorMode {
                notesButton.isEnabled = true
            }
        } else {
            navBar.title = "Select Team"
            teamLabel.text = "Select Team"
            
            frontImage = nil
            
            standsScoutingButton.isEnabled = false
            
            pitScoutingButton.isEnabled = false
            
            notesButton.isEnabled = false
        }
        
        if let scoutedTeam = scoutedTeam {
            if scoutedTeam.decodedAttributes?.canBanana ?? false {
                bananaImageView.image = #imageLiteral(resourceName: "Banana Filled")
                bananaImageWidth.constant = 40
            } else {
                bananaImageView.image = nil
                bananaImageWidth.constant = 0
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
        
        detailCollectionVC?.loadStats(forScoutedTeam: self.scoutedTeam)
        
        resizeDetailViewHeights()
    }
    
    func resizeDetailViewHeights() {
        generalInfoTableView?.layoutIfNeeded()
        
        self.detailCollectionViewHeight.constant = self.detailCollectionVC?.collectionView?.collectionViewLayout.collectionViewContentSize.height ?? 10
        self.detailTableViewHeight.constant = self.generalInfoTableView?.contentSize.height ?? 10
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.isViewLoaded {
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
    }
    
    @objc func showLoginPromotional() {
        let loginPromotional = storyboard!.instantiateViewController(withIdentifier: "loginPromotional")
        self.present(loginPromotional, animated: true, completion: nil)
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventPresentOffer, attributes: ["Source":"team_detail", "item_id":"login_promotional", "item_name":"Login Promotional"])
    }
    
    @IBAction func notesButtonPressed(_ sender: UIButton) {
        guard let eventKey = self.selectedEventKey, let teamkey = self.selectedTeam?.key else {
            return
        }
        
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
        
        let navVC = UINavigationController(rootViewController: notesVC)
        
        notesVC.load(forEventKey: eventKey, andTeamKey: teamkey)
        
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
        if #available(iOS 13.0, *) {
            self.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
        }
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
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventShare, attributes: ["share_method":activityType ?? "?", "content_type":"team_photo","content_id":self.selectedTeam?.key ?? ""])
    }
}
