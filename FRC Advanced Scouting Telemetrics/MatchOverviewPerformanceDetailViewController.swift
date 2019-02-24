//
//  MatchOverviewPerformanceDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/5/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase

class MatchOverviewPerformanceDetailViewController: UIViewController {
    @IBOutlet weak var timeMarkerTableView: UITableView!
    @IBOutlet weak var matchStatsCollectionView: UICollectionView!
    @IBOutlet weak var scoutIDSegmentedSelector: UISegmentedControl!
    @IBOutlet weak var scoutIDView: UIView!
    @IBOutlet weak var scoutIDViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hasNotBeenScoutedHeight: NSLayoutConstraint!
    @IBOutlet weak var matchContentView: UIView!
    @IBOutlet weak var standsScoutButton: UIButton!
    
    var match: Match?
    var teamKey: String?
    
    var model: StandsScoutingModel?
    
    var availableScoutSessions: [ScoutSession] = [] {
        didSet {
            if availableScoutSessions.count <= 1 {
                scoutIDViewHeight.constant = 0
                scoutIDView.isHidden = true
            } else {
                scoutIDViewHeight.constant = 50
                scoutIDView.isHidden = false
                scoutIDSegmentedSelector.removeAllSegments()
                for (index,session) in availableScoutSessions.enumerated() {
                    if let date = session.recordedDate {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale.current
                        
                        dateFormatter.dateFormat = "EEE dd, HH:mm"
                        scoutIDSegmentedSelector.insertSegment(withTitle: "\(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date))))", at: index, animated: false)
                    } else {
                        scoutIDSegmentedSelector.insertSegment(withTitle: "\(index)", at: index, animated: false)
                    }
                }
                scoutIDSegmentedSelector.selectedSegmentIndex = 0
            }
        }
    }
    var selectedScoutSession: ScoutSession?
    var statistics: [Statistic<ScoutSession>] = []
    
//    var scoutID: String? {
//        didSet {
//            if let id = scoutID {
//                timeMarkers = displayedTeamMatchPerformance?.scouted?.timeMarkers(forScoutID: id) ?? []
//                timeMarkers = timeMarkers.sorted {($0.time) < ($1.time)}
//            }
//
//            timeMarkerTableView.reloadData()
//        }
//    }
    
    func hideEverything() {
        hasNotBeenScoutedHeight.constant = 0
        standsScoutButton.isHidden = true
        timeMarkerTableView.isHidden = true
        matchStatsCollectionView.isHidden = true
    }
    
    func hideMatchContentViews() {
        hasNotBeenScoutedHeight.constant = 22
        standsScoutButton.isHidden = false
        timeMarkerTableView.isHidden = true
        matchStatsCollectionView.isHidden = true
    }
    
    func showMatchContentViews() {
        hasNotBeenScoutedHeight.constant = 0
        standsScoutButton.isHidden = true
        timeMarkerTableView.isHidden = false
        matchStatsCollectionView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        timeMarkerTableView.dataSource = self
        timeMarkerTableView.delegate = self
        timeMarkerTableView.estimatedRowHeight = 55
        timeMarkerTableView.allowsSelection = false
        
        matchStatsCollectionView.dataSource = self
        matchStatsCollectionView.delegate = self
        
        hasNotBeenScoutedHeight.constant = 0
        standsScoutButton.isHidden = true
        
        if Globals.isInSpectatorMode {
            standsScoutButton.tintColor = UIColor.purple
        }
        
        StandsScoutingModelLoader().getModel { (model) in
            self.model = model
            self.timeMarkerTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(match: Match?, forTeamKey teamKey: String?) {
        if let match = match {
            self.match = match
            self.teamKey = teamKey
            
            availableScoutSessions = []
            selectScoutSession(scoutSession: nil)
            
            if let teamKey = teamKey {
                //Get the scout sessions
                Globals.appDelegate.appSyncClient?.fetch(query: ListScoutSessionsQuery(eventKey: match.eventKey, teamKey: teamKey, matchKey: match.key), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                    if Globals.handleAppSyncErrors(forQuery: "ListScoutSessions", result: result, error: error) {
                        self?.availableScoutSessions = result?.data?.listScoutSessions?.map({$0!.fragments.scoutSession}) ?? []
                        self?.selectScoutSession(scoutSession: self?.availableScoutSessions.first)
                    } else {
                        //Uh oh
                    }
                })
            }
        } else {
            hideEverything()
        }
    }
    
    
    func selectScoutSession(scoutSession: ScoutSession?) {
        self.selectedScoutSession = scoutSession
        statistics = []
        if let _ = scoutSession {
            showMatchContentViews()
            
            //Get the stats
            self.statistics = StatisticsDataSource().getStats(forType: ScoutSession.self)
        } else {
            hideMatchContentViews()
        }
        
        timeMarkerTableView.reloadData()
        matchStatsCollectionView.reloadData()
    }
    
    @IBAction func scoutingIDSelected(_ sender: UISegmentedControl) {
        selectScoutSession(scoutSession: availableScoutSessions[sender.selectedSegmentIndex])
    }
    
    @IBAction func standsScoutPressed(_ sender: UIButton) {
        if Globals.isInSpectatorMode {
            //Show the sign up thing
            let loginPromotional = storyboard!.instantiateViewController(withIdentifier: "loginPromotional")
            self.present(loginPromotional, animated: true, completion: nil)
            Globals.recordAnalyticsEvent(eventType: AnalyticsEventPresentOffer, attributes: ["source":"match_overview_scout_button", "item_id":"login_promotional","item_name":"Login Promotional"])
        } else {
            //Pull up the stands scouting page
            let standsScoutVC = storyboard?.instantiateViewController(withIdentifier: "standsScouting") as! StandsScoutingViewController
            
            if let teamKey = teamKey, let match = match {
                standsScoutVC.setUp(forTeamKey: teamKey, andMatchKey: match.key, inEventKey: match.eventKey)
                
                present(standsScoutVC, animated: true, completion: nil)
                
                Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["source":"match_overview_detail", "content_type":"screen","item_id":"stands_scouting"])
                CLSNSLogv("Opening Stands Scouting from Match Overview Detail", getVaList([]))
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MatchOverviewPerformanceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let timeMarkers = selectedScoutSession?.timeMarkers {
            return timeMarkers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeMarker") as! MatchOverviewTimeMarkerTableViewCell
        if let scoutSession = selectedScoutSession {
            let timeMarker = scoutSession.timeMarkers?[indexPath.row]?.fragments.timeMarkerFragment
            
            if let model = model {
                let gameAction = model.gameActions.first(where: {$0.key == timeMarker?.event})
                
                if let action = gameAction {
                    cell.timeMarkerEventLabel.text = action.name
                } else if timeMarker?.event == "end_autonomous_period" {
                    cell.timeMarkerEventLabel.text = "Ended Autonomous Period"
                } else {
                    cell.timeMarkerEventLabel.text = timeMarker?.event
                }
                
                if let subOption = timeMarker?.subOption {
                    if let option = gameAction?.subOptions?.first(where: {$0.key == subOption})?.name {
                        cell.subOptionLabel.text = option
                    } else {
                        cell.subOptionLabel.text = timeMarker?.subOption
                    }
                } else {
                    cell.subOptionLabel.text = timeMarker?.subOption
                }
            } else {
                cell.timeMarkerEventLabel.text = timeMarker?.event
                cell.subOptionLabel.text = timeMarker?.subOption
            }
            
            if timeMarker?.subOption == nil {
                cell.timeMarkerVerticalCenterConstraint.constant = 0
            } else {
                cell.timeMarkerVerticalCenterConstraint.constant = -7
            }
            
            let elapsedTime = timeMarker?.time ?? 0
            cell.timeLabel.text = String.init(format: "%02d:%02d", Int(elapsedTime / 60), Int(elapsedTime.truncatingRemainder(dividingBy: 60)))
            
            cell.imageViewWidthConstraint.constant = 0
        }
        
        return cell
    }
}

extension MatchOverviewPerformanceDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let timeMarker = selectedScoutSession?.timeMarkers?[indexPath.row]?.fragments.timeMarkerFragment {
            
            //Present a popover with a detail view on the time marker
            let timeMarkerDetailVC = storyboard?.instantiateViewController(withIdentifier: "timeMarkerDetail") as! TimeMarkerDetailViewController
            timeMarkerDetailVC.load(forTimeMarker: timeMarker)
            
            timeMarkerDetailVC.modalPresentationStyle = .popover
            timeMarkerDetailVC.popoverPresentationController?.sourceView = (tableView.cellForRow(at: indexPath) as! MatchOverviewTimeMarkerTableViewCell).iconImageView
            timeMarkerDetailVC.popoverPresentationController?.delegate = self
            
            present(timeMarkerDetailVC, animated: true, completion: nil)
        }
    }
}

extension MatchOverviewPerformanceDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        timeMarkerTableView.deselectRow(at: timeMarkerTableView.indexPathForSelectedRow ?? IndexPath(), animated: true)
    }
}

extension MatchOverviewPerformanceDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyValue", for: indexPath)
        
        if let scoutSession = selectedScoutSession {
            let performanceStat = statistics[indexPath.item]
            
            let nameLabel = cell.viewWithTag(1) as! UILabel
            let valueLabel = cell.viewWithTag(2) as! UILabel
            nameLabel.text = performanceStat.name
            valueLabel.text = "Loading"
            
            //Calculate the stat
            let tk = self.teamKey
            let mk = self.match?.key
            performanceStat.calculate(forObject: scoutSession) {[weak self] (value) in
                //Check if it is still the same cell
                if self?.teamKey == tk && self?.match?.key == mk && nameLabel.text == performanceStat.name {
                    //It is the same, write the value
                    valueLabel.text = value.description
                }
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        (headerView.viewWithTag(1) as! UILabel).text = "Match Performance Stats"
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 65)
    }
}
