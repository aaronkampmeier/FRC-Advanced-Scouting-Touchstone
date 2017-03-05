//
//  MatchOverviewViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol MatchOverviewDetailDataSource {
    func match() -> Match?
}

class MatchOverviewDetailViewController: UIViewController {
    @IBOutlet weak var matchTitleLabel: UILabel!
    @IBOutlet weak var redPointsLabel: UILabel!
    @IBOutlet weak var redRankingPointsLabel: UILabel!
    @IBOutlet weak var bluePointsLabel: UILabel!
    @IBOutlet weak var blueRankingPointsLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var dataSource: MatchOverviewDetailDataSource?
    
    var teamListSplitVC: TeamListSplitViewController {
        get {
            if let teamSplit = self.splitViewController as? TeamListSplitViewController {
                return teamSplit
            } else {
                return TeamListSplitViewController.default
            }
        }
    }
    var displayedMatch: Match? {
        didSet {
            if let match = displayedMatch {
                if let setNumber = match.setNumber?.intValue {
                    if match.competitionLevelEnum == .QuarterFinal || match.competitionLevelEnum == .SemiFinal {
                        matchTitleLabel.text = "\(match.competitionLevelEnum) \(setNumber) Match \(match.matchNumber!)"
                    } else {
                        matchTitleLabel.text = "\(match.competitionLevelEnum) \(match.matchNumber!)"
                    }
                } else {
                    matchTitleLabel.text = "\(match.competitionLevelEnum) \(match.matchNumber!)"
                }
                
                redPointsLabel.text = match.local.redFinalScore?.description
                redRankingPointsLabel.text = match.local.redRankingPoints?.description
                bluePointsLabel.text = match.local.blueFinalScore?.description
                blueRankingPointsLabel.text = match.local.blueRankingPoints?.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        teamListSplitVC.matchesDetail = self
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = teamListSplitVC.displayModeButtonItem
        
        self.dataSource = teamListSplitVC.matchesMaster
        
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        self.displayedMatch = dataSource?.match()
    }
    
    @IBAction func selectedDifferentTeam(_ sender: UISegmentedControl) {
        
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
