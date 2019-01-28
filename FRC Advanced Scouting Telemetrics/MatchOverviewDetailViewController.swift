//
//  MatchOverviewViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewDetailViewController: UIViewController {
    @IBOutlet weak var matchTitleLabel: UILabel!
    @IBOutlet weak var redPointsLabel: UILabel!
    @IBOutlet weak var bluePointsLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var matchOverviewSplitVC: MatchOverviewSplitViewController? {
        get {
            if let matchSplit = self.splitViewController as? MatchOverviewSplitViewController {
                return matchSplit
            } else {
                return MatchOverviewSplitViewController.default
            }
        }
    }
    var displayedMatch: Match?
    var teamKeys = [String]()
    
    var matchPerformanceDetail: MatchOverviewPerformanceDetailViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        matchOverviewSplitVC?.matchesDetail = self
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = matchOverviewSplitVC?.displayModeButtonItem
        
        matchPerformanceDetail = self.childViewControllers.first! as? MatchOverviewPerformanceDetailViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(forMatchKey matchKey: String, shouldShowExitButton: Bool) {
        //Get the match
        Globals.appDelegate.appSyncClient?.fetch(query: GetMatchQuery(matchKey: matchKey), cachePolicy: .returnCacheDataElseFetch, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "GetMatchQuery-MatchOverview", result: result, error: error) {
                self.setUpForMatch(match: result?.data?.getMatch?.fragments.match)
                
                //TODO: - Also update the apollo cache for ListMatchesQuery with this result
            } else {
                //TODO: - Show error
            }
        })
        
        if shouldShowExitButton {
            self.navigationItem.setRightBarButtonItems([], animated: false)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
            self.navigationItem.setRightBarButtonItems([doneButton], animated: false)
        } else {
            self.navigationItem.setRightBarButtonItems([], animated: false)
        }
    }
    
    private func setUpForMatch(match: Match?) {
        self.displayedMatch = match
        
        if let match = match {
            matchTitleLabel.text = match.description
            
            redPointsLabel.text = "\(match.redAlliance?.score.description ?? "-") Pts."
            bluePointsLabel.text = "\(match.blueAlliance?.score.description ?? "-") Pts."
            
            //Set the teams in the segmented control
            teamKeys = match.redAlliance?.teamKeys as? [String] ?? []
            teamKeys += match.blueAlliance?.teamKeys as? [String] ?? []
            for key in teamKeys.enumerated() {
                segmentedControl.setTitle(key.element, forSegmentAt: key.offset)
            }
            
            segmentedControl.selectedSegmentIndex = 0
            self.selectedDifferentTeam(segmentedControl)
        }
    }
    
    @IBAction func selectedDifferentTeam(_ sender: UISegmentedControl) {
        //Set the selected match performance
        if let match = self.displayedMatch {
            matchPerformanceDetail.load(match: match, forTeamKey: teamKeys[sender.selectedSegmentIndex])
        }
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentNotes(_ sender: Any) {
        let superNotesVC = storyboard?.instantiateViewController(withIdentifier: "superNotes") as! SuperNotesCollectionViewController
        let navVC = UINavigationController(rootViewController: superNotesVC)
        
        navVC.modalPresentationStyle = .pageSheet
        
        
        present(navVC, animated: true, completion: nil)
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
