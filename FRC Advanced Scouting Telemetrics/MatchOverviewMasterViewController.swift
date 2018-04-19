//
//  MatchOverviewMasterViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol MatchOverviewMasterDataSource {
    func event() -> Event?
}

class MatchOverviewMasterViewController: UIViewController, MatchOverviewDetailDataSource {
    var dataSource: MatchOverviewMasterDataSource?

    var matchOverviewSplitVC: MatchOverviewSplitViewController {
        get {
            return self.splitViewController as! MatchOverviewSplitViewController
        }
    }
    var event: Event? {
        didSet {
            if let event = event {
                let unsortedMatches = event.matches
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
            matchOverviewSplitVC.matchesDetail?.reloadData()
        }
    }
    
    var matchesTableVC: MatchesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        matchOverviewSplitVC.matchesMaster = self
        
        self.load(withEvent: dataSource?.event())
        
        matchesTableVC = (self.childViewControllers.first as! MatchesTableViewController)
        matchesTableVC?.delegate = self
        matchesTableVC?.tableView.allowsSelection = true
        
        matchesTableVC?.load(withMatches: matchesInEvent)
    }
    
    private func load(withEvent event: Event?) {
        self.event = event
    }
    
    func match() -> Match? {
        return selectedMatch
    }
    
    func shouldShowExitButton() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        let splitVC = self.matchOverviewSplitVC
        splitVC.dismiss(animated: true, completion: nil)
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
    func matchesTableViewController(_ matchesTableViewController: MatchesTableViewController, selectedMatchCell: UITableViewCell?, withAssociatedMatch associatedMatch: Match?) {
        matchOverviewSplitVC.showDetailViewController(matchOverviewSplitVC.matchesDetail!, sender: self)
        self.selectedMatch = associatedMatch
    }

    func hasSelectionEnabled() -> Bool {
        if RealmController.isInSpectatorMode {
            return false
        } else {
            return true
        }
    }
}
