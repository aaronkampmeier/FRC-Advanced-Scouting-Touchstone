//
//  MatchOverviewMasterViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewMasterViewController: UIViewController, MatchOverviewDetailDataSource {

    var teamListSplitVC: TeamListSplitViewController {
        get {
            if let teamSplit = self.splitViewController as? TeamListSplitViewController {
                return teamSplit
            } else {
                return TeamListSplitViewController.default
            }
        }
    }
    var event: Event? {
        didSet {
            if let event = event {
                let unsortedMatches = event.matches?.allObjects as! [Match]
                let sortedMatches = unsortedMatches.sorted() {(firstMatch, secondMatch) in
                    return firstMatch < secondMatch
                }
                
                matchesInEvent = sortedMatches
            } else {
                matchesInEvent = []
            }
        }
    }
    var matchesInEvent: [Match] = [] {
        didSet {
            matchesTableVC?.load(withMatches: matchesInEvent)
        }
    }
    var selectedMatch: Match? {
        didSet {
            teamListSplitVC.matchesDetail?.reloadData()
        }
    }
    
    var matchesTableVC: MatchesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        teamListSplitVC.matchesMaster = self
        
        matchesTableVC = self.childViewControllers.first as! MatchesTableViewController
        matchesTableVC?.delegate = self
        matchesTableVC?.tableView.allowsSelection = true
        
        matchesTableVC?.load(withMatches: matchesInEvent)
    }
    
    func load(withEvent event: Event?) {
        self.event = event
    }
    
    func match() -> Match? {
        return selectedMatch
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        let teamSplitVC = self.teamListSplitVC
        teamSplitVC.isInMatchOverview = false
        teamSplitVC.show(teamSplitVC.teamListTableVC.navigationController!, sender: self)
        teamSplitVC.showDetailViewController(teamSplitVC.teamListDetailVC, sender: self)
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

extension MatchOverviewMasterViewController: MatchesTableViewControllerDelegate {
    func hasSelectionEnabled() -> Bool {
        return true
    }
    
    func selected(match: Match) {
        teamListSplitVC.showDetailViewController(teamListSplitVC.matchesDetail!, sender: self)
        self.selectedMatch = match
    }
}
