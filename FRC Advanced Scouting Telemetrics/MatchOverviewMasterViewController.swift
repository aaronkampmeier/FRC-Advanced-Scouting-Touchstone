//
//  MatchOverviewMasterViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol MatchOverviewMasterDataSource {
    func eventKey() -> String?
}

class MatchOverviewMasterViewController: UIViewController {
    var dataSource: MatchOverviewMasterDataSource?

    var matchOverviewSplitVC: MatchOverviewSplitViewController {
        get {
            return self.splitViewController as! MatchOverviewSplitViewController
        }
    }
    var eventKey: String?
    var selectedMatch: Match?
    
    var matchesTableVC: MatchesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        matchOverviewSplitVC.matchesMaster = self
        
        self.load(withEventKey: dataSource?.eventKey())
        
        matchesTableVC = (self.childViewControllers.first as! MatchesTableViewController)
        matchesTableVC?.delegate = self
        matchesTableVC?.tableView.allowsSelection = true
    }
    
    private func load(withEventKey eventKey: String?) {
        matchesTableVC?.load(forEventKey: eventKey)
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
        matchOverviewSplitVC.matchesDetail?.load(forMatchKey: associatedMatch?.key ?? "", shouldShowExitButton: false)
    }

    func hasSelectionEnabled() -> Bool {
        return true
    }
}
