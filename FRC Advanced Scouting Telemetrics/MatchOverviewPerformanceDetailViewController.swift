//
//  MatchOverviewPerformanceDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/5/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol MatchOverviewPerformanceDetailDataSource {
    func teamMatchPerformance() -> TeamMatchPerformance?
}

class MatchOverviewPerformanceDetailViewController: UIViewController {
    @IBOutlet weak var timeMarkerTableView: UITableView!
    @IBOutlet weak var matchStatsCollectionView: UICollectionView!
    @IBOutlet weak var scoutIDSegmentedSelector: UISegmentedControl!
    @IBOutlet weak var scoutIDView: UIView!
    @IBOutlet weak var scoutIDViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hasNotBeenScoutedHeight: NSLayoutConstraint!
    @IBOutlet weak var matchContentView: UIView!
    @IBOutlet weak var fieldLocationDisplayerView: UIView!

    var dataSource: MatchOverviewPerformanceDetailDataSource?
    var displayedTeamMatchPerformance: TeamMatchPerformance? {
        didSet {
            scoutID = nil
            matchPerformanceStats = []
            if let matchPerformance = displayedTeamMatchPerformance {
                if matchPerformance.local.hasBeenScouted {
                    showMatchContentViews()
                } else {
                    hideMatchContentViews()
                }
                availableScoutIDs = matchPerformance.local.scoutIDs ?? ["default"]
                
                //Get all the stats
                let availableStats = TeamMatchPerformance.StatName.allValues
                
                for statName in availableStats {
                    matchPerformanceStats.append((statName.description, matchPerformance.statValue(forStat: statName).description))
                }
            } else {
                availableScoutIDs = []
                hideMatchContentViews()
            }
            
            matchStatsCollectionView.reloadData()
        }
    }
    var availableScoutIDs: [String] = [] {
        didSet {
            if availableScoutIDs.count == 1 {
                scoutIDViewHeight.constant = 0
                scoutIDView.isHidden = true
                scoutID = availableScoutIDs.first
            } else if availableScoutIDs.count > 1 {
                scoutIDViewHeight.constant = 50
                scoutIDView.isHidden = false
                scoutIDSegmentedSelector.removeAllSegments()
                for n in 0..<availableScoutIDs.count {
                    scoutIDSegmentedSelector.insertSegment(withTitle: "\(n)", at: n, animated: false)
                }
            } else {
                scoutIDViewHeight.constant = 0
                scoutIDView.isHidden = true
                scoutID = nil
            }
        }
    }
    var scoutID: String? {
        didSet {
            if let id = scoutID {
                timeMarkers = displayedTeamMatchPerformance?.local.timeMarkers(forScoutID: id) ?? []
                timeMarkers = timeMarkers.sorted {($0.time?.doubleValue ?? 0) < ($1.time?.doubleValue ?? 0)}
            }
            
            fieldLocationDisplay.reloadData()
            timeMarkerTableView.reloadData()
        }
    }
    
    func hideMatchContentViews() {
        hasNotBeenScoutedHeight.constant = 22
        fieldLocationDisplayerView.isHidden = true
        timeMarkerTableView.isHidden = true
        matchStatsCollectionView.isHidden = true
    }
    
    func showMatchContentViews() {
        hasNotBeenScoutedHeight.constant = 0
        fieldLocationDisplayerView.isHidden = false
        timeMarkerTableView.isHidden = false
        matchStatsCollectionView.isHidden = false
    }
    
    var timeMarkers: [TimeMarker] = []
    var matchPerformanceStats = [(String, String?)]()
    
    var fieldLocationDisplay: FieldLocationDisplayViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fieldLocationDisplay = self.childViewControllers.first as! FieldLocationDisplayViewController
        fieldLocationDisplay.dataSource = self
        
        timeMarkerTableView.dataSource = self
        timeMarkerTableView.delegate = self
        
        matchStatsCollectionView.dataSource = self
        matchStatsCollectionView.delegate = self
        
        displayedTeamMatchPerformance = nil
        hasNotBeenScoutedHeight.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        self.displayedTeamMatchPerformance = dataSource?.teamMatchPerformance()
    }
    
    @IBAction func scoutingIDSelected(_ sender: UISegmentedControl) {
        scoutID = availableScoutIDs[sender.selectedSegmentIndex]
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

extension MatchOverviewPerformanceDetailViewController: FieldLocationDisplayDataSource {
    func allowsMultiplePoints() -> Bool {
        return true
    }
    
    func allowsAddition() -> Bool {
        return false
    }
    
    func fieldImage(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> UIImage {
        if let teamMatchPerformance = displayedTeamMatchPerformance {
            switch teamMatchPerformance.alliance {
            case .Red:
                return #imageLiteral(resourceName: "Red Boiler Map")
            case .Blue:
                return #imageLiteral(resourceName: "Blue Boiler Map")
            }
        } else {
            return #imageLiteral(resourceName: "Red Boiler Map")
        }
    }
    
    func allPoints(forFieldLocationDisplayController fieldLocationDisplayVC: FieldLocationDisplayViewController) -> [CGPoint] {
        if let matchPerformance = displayedTeamMatchPerformance {
            let fuelShots = matchPerformance.local.fuelScorings(forScoutID: scoutID ?? "default")
            let highGoalShots = fuelShots.filter {$0.goal == BoilerGoal.HighGoal.rawValue}
            
            let points = highGoalShots.map {fuelScoring in
                return CGPoint(x: fuelScoring.xLocation?.doubleValue ?? 0, y: fuelScoring.yLocation?.doubleValue ?? 0)
            }
            
            return points
        } else {
            return []
        }
    }
}

extension MatchOverviewPerformanceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayedTeamMatchPerformance?.local.hasBeenScouted ?? false {
            return timeMarkers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if displayedTeamMatchPerformance?.local.hasBeenScouted ?? false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeMarker") as! MatchOverviewTimeMarkerTableViewCell
            let timeMarker = timeMarkers[indexPath.row]
            
            switch timeMarker.timeMarkerEventType {
            case .LoadedFuel:
                cell.iconImageView.image = #imageLiteral(resourceName: "Fuel")
            case .ScoredFuel:
                cell.iconImageView.image = #imageLiteral(resourceName: "Fuel")
            case .LoadedGear:
                cell.iconImageView.image = #imageLiteral(resourceName: "Gear")
            case .ScoredGear:
                cell.iconImageView.image = #imageLiteral(resourceName: "Gear")
            case .Defended:
                cell.iconImageView.image = #imageLiteral(resourceName: "Defensive Wood Wall")
            case .EndedAutonomous:
                cell.iconImageView.image = nil
            case .Error:
                cell.iconImageView.image = nil
            }
            
            cell.timeMarkerEventLabel.text = timeMarker.event
            let elapsedTime = timeMarker.time?.doubleValue ?? 0
            cell.timeLabel.text = String.init(format: "%02d:%02d", Int(elapsedTime / 60), Int(elapsedTime.truncatingRemainder(dividingBy: 60)))
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension MatchOverviewPerformanceDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeMarker = timeMarkers[indexPath.row]
        
        //Present a popover with a detail view on the time marker
        let timeMarkerDetailVC = storyboard?.instantiateViewController(withIdentifier: "timeMarkerDetail") as! TimeMarkerDetailViewController
        timeMarkerDetailVC.load(forTimeMarker: timeMarker)
        
        timeMarkerDetailVC.modalPresentationStyle = .popover
        timeMarkerDetailVC.popoverPresentationController?.sourceView = (tableView.cellForRow(at: indexPath) as! MatchOverviewTimeMarkerTableViewCell).iconImageView
        timeMarkerDetailVC.popoverPresentationController?.delegate = self
        
        present(timeMarkerDetailVC, animated: true, completion: nil)
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
        return matchPerformanceStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyValue", for: indexPath)
        let performanceStat = matchPerformanceStats[indexPath.item]
        
        (cell.viewWithTag(1) as! UILabel).text = performanceStat.0
        (cell.viewWithTag(2) as! UILabel).text = performanceStat.1
        
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
