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
        
        if let match = displayedMatch {
            self.setUpForMatch(match: match)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(forMatchKey matchKey: String, shouldShowExitButton: Bool) {
        self.setUpForMatch(match: nil)
        
        //Get the match
        Globals.appDelegate.appSyncClient?.fetch(query: GetMatchQuery(matchKey: matchKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, error) in
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
        
        guard self.isViewLoaded else {
            return
        }
        
        if let match = match {
            matchTitleLabel.text = match.description
            
            redPointsLabel.text = "\(match.alliances?.red?.score.description ?? "-") Pts."
            bluePointsLabel.text = "\(match.alliances?.blue?.score.description ?? "-") Pts."
            
            //Set the teams in the segmented control
            teamKeys = match.alliances?.red?.teamKeys as? [String] ?? []
            teamKeys += match.alliances?.blue?.teamKeys as? [String] ?? []
            for key in teamKeys.enumerated() {
                segmentedControl.setTitle(key.element.trimmingCharacters(in: CharacterSet.letters), forSegmentAt: key.offset)
            }
            
            segmentedControl.selectedSegmentIndex = 0
            self.selectedDifferentTeam(segmentedControl)
        } else {
            matchTitleLabel.text = nil
            
            redPointsLabel.text = "- Pts."
            bluePointsLabel.text = "- Pts."
            
            for n in 0..<6 {
                segmentedControl.setTitle(nil, forSegmentAt: n)
            }
            
            segmentedControl.selectedSegmentIndex = -1
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
