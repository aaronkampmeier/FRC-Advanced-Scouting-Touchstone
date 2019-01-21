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
import RealmSwift
import SafariServices

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
    
    var teamListSplitVC: TeamListSplitViewController {
        get {
            if let teamSplit = splitViewController as? TeamListSplitViewController {
                return teamSplit
            } else {
                return TeamListSplitViewController.default
            }
        }
    }
    
    var detailCollectionVC: TeamDetailCollectionViewController?
    
    var dataSource: TeamListDetailDataSource?
    
    //Insets for the scroll view
    var contentViewInsets: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(frontImageHeightConstraint.constant, 0, 0, 0)
        }
    }
    var noContentInsets: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(0, 0, 0, 0)
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

        // Do any additional setup after loading the view.
        
        teamListSplitVC.teamListDetailVC = self
        
        self.dataSource = teamListSplitVC.teamListTableVC
        
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
        generalInfoTableView?.rowHeight = UITableViewAutomaticDimension
        generalInfoTableView?.estimatedRowHeight = 44
        
        //Watch for notifications requiring the collection view to resize it's height. This ensures that this object's container view is always the same height as it's child collection view forcing the user to use this scroll view and not the scroll view in the colleciton view.
        NotificationCenter.default.addObserver(forName: TeamDetailCollectionViewNeedsHeightResizing, object: nil, queue: nil) {_ in self.resizeDetailViewHeights()}
        
        //Load the data if a team was selected beforehand
        self.reloadData()
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
        
        self.resizeDetailViewHeights()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "standsScouting" {
            let destinationVC = segue.destination as! StandsScoutingViewController
            destinationVC.teamEventPerformance = teamEventPerformance
            
            Answers.logCustomEvent(withName: "Opened Stands Scouting", customAttributes: ["Source":"Team Detail Button"])
            CLSNSLogv("Opening Stands Scouting from Team Detail Button", getVaList([]))
        } else if segue.identifier == "pitScouting" {
            let pitScoutingVC = segue.destination as! PitScoutingViewController
            pitScoutingVC.scoutedTeam = selectedTeam
        } else if segue.identifier == "teamDetailCollection" {
            detailCollectionVC = (segue.destination as! TeamDetailCollectionViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func set(input: (team: Team, eventKey: String)?) {
        self.selectedEventKey = input?.eventKey
        self.selectedTeam = input?.team
        self.updateView()
        
        if let input = input {
            //Grab the scouted data
            Globals.appDelegate.appSyncClient?.fetch(query: GetScoutedTeamQuery(eventKey: self.selectedEventKey ?? "", teamKey: input.team.key), cachePolicy: .returnCacheDataAndFetch) {result, error in
                if Globals.handleAppSyncErrors(forQuery: "GetScoutedTeamQuery", result: result, error: error) {
                    self.scoutedTeam = result?.data?.getScoutedTeam?.fragments.scoutedTeam
                    
                    self.updateView()
                } else {
                    //TODO: Throw error
                }
            }
            
            //Status
            Globals.appDelegate.appSyncClient?.fetch(query: ListTeamEventStatusesQuery(eventKey: input.eventKey), cachePolicy: .returnCacheDataElseFetch) {result, error in
                if Globals.handleAppSyncErrors(forQuery: "TeamListDetail-ListTeamEventStatusesQuery", result: result, error: error) {
                    let statuses = result?.data?.listTeamEventStatuses
                    self.statusString = statuses?.first(where: {$0?.teamKey ?? "" == input.team.key})??.fragments.teamEventStatus.overallStatusStr
                    self.generalInfoTableView?.reloadData()
                } else {
                    //TODO: - Show error
                }
            }
        } else {
            self.scoutedTeam = nil
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TeamSelectedChanged"), object: self)
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
            if scoutedTeam.canBanana ?? false {
                bananaImageView.image = #imageLiteral(resourceName: "Banana Filled")
                bananaImageWidth.constant = 40
            } else {
                bananaImageView.image = nil
                bananaImageWidth.constant = 0
            }
            
            //TODO: - Fix images
//            Populate the images, if there are images
            if let image = scoutedTeam.frontImage {
                frontImage = TeamImagePhoto(image: image, attributedCaptionTitle: NSAttributedString(string: "Team \(self.selectedTeam?.teamNumber ?? 0): Front Image"))
                frontImageHeightConstraint.isActive = true

                contentScrollView.contentInset = contentViewInsets
                contentScrollView.scrollIndicatorInsets = contentViewInsets

                contentScrollView.contentOffset = CGPoint(x: 0, y: -frontImageHeightConstraint.constant)
            } else {
                frontImage = nil
                frontImageHeightConstraint.isActive = false

                contentScrollView.contentInset = noContentInsets
                contentScrollView.scrollIndicatorInsets = noContentInsets

                contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
        
        generalInfoTableView?.reloadData()
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
        //Reset the content insets
        coordinator.animate(alongsideTransition: {_ in
            if self.scoutedTeam?.frontImage != nil {
                self.contentScrollView.contentInset = self.contentViewInsets
                self.contentScrollView.scrollIndicatorInsets = self.contentViewInsets
                
                self.contentScrollView.contentOffset = CGPoint(x: 0, y: -self.frontImageHeightConstraint.constant)
            } else {
                self.frontImageHeightConstraint.isActive = false
                
                self.contentScrollView.contentInset = self.noContentInsets
                self.contentScrollView.scrollIndicatorInsets = self.noContentInsets
                
                self.contentScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
            
            self.resizeDetailViewHeights()
        }, completion: nil)
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
        Answers.logContentView(withName: "Login Promotional", contentType: nil, contentId: nil, customAttributes: ["Source":"Team Detail Notes/Scouting Buttons"])
    }
    
    @IBAction func notesButtonPressed(_ sender: UIButton) {
        let notesVC = storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as! TeamCommentsTableViewController
        
        let navVC = UINavigationController(rootViewController: notesVC)
        
        notesVC.dataSource = self
        
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
        
        Answers.logCustomEvent(withName: "Opened Team Matches View", customAttributes: nil)
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
        
        let showMatchDetail = {() -> Void in
            let matchDetailNav = self.storyboard?.instantiateViewController(withIdentifier: "matchDetailNav") as! UINavigationController
            let matchDetail = matchDetailNav.topViewController as! MatchOverviewDetailViewController
            
            matchDetail.dataSource = self
            
            matchesTableViewController.present(matchDetailNav, animated: true, completion: nil)
        }
        
        if Globals.isInSpectatorMode {
            showMatchDetail()
        } else {
            //Present an action sheet to see if the user wants to view it or scout it
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "View Match", style: .default) {action in
                showMatchDetail()
            })
            actionSheet.addAction(UIAlertAction(title: "Stands Scout", style: .default) {action in
                let standsScoutingVC = self.storyboard?.instantiateViewController(withIdentifier: "standsScouting") as! StandsScoutingViewController
                standsScoutingVC.teamEventPerformance = self.teamEventPerformance
                standsScoutingVC.matchPerformance = (associatedMatch?.teamPerformances)?.first {$0.teamEventPerformance == self.teamEventPerformance}
                
                matchesTableViewController.present(standsScoutingVC, animated: true, completion: nil)
                
                Answers.logCustomEvent(withName: "Opened Stands Scouting", customAttributes: ["Source":"Team Matches List"])
                
                CLSNSLogv("Opening Stands Scouting from Team Matches List", getVaList([]))
            })
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) {action in
                matchesTableViewController.tableView.deselectRow(at: matchesTableViewController.tableView.indexPathForSelectedRow ?? IndexPath(), animated: true)
            })
            
            
            matchesTableViewController.present(actionSheet, animated: true, completion: nil)
        }
    }
}

extension TeamListDetailViewController: MatchOverviewDetailDataSource {
    func match() -> Match? {
        return selectedMatch
    }
    
    func shouldShowExitButton() -> Bool {
        return true
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
            Answers.logContentView(withName: "Team Website View", contentType: "Website", contentId: "\(selectedTeam?.key ?? "unk")", customAttributes: nil)
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

extension TeamListDetailViewController: NotesDataSource {
    func currentTeamContext() -> Team {
        return selectedTeam!
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
        Answers.logShare(withMethod: activityType, contentName: "Team Photos", contentType: "Photo", contentId: nil, customAttributes: nil)
    }
}
