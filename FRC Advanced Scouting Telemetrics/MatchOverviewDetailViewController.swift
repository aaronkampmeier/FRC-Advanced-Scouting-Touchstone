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
    
    private(set) var displayedMatch: Match?
    private var teamKeys = [String]()
    
    private var matchPerformanceDetail: MatchOverviewPerformanceDetailViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.segmentedControl.selectedSegmentIndex = -1
        
        matchPerformanceDetail = self.children.first! as? MatchOverviewPerformanceDetailViewController
        
        if let match = displayedMatch {
            self.setUpForMatch(match: match)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func load(forMatchKey matchKey: String, shouldShowExitButton: Bool, preSelectedTeamKey: String? = nil) {
        self.setUpForMatch(match: nil)
        
        let eventKey = matchKey.components(separatedBy: "_").first
        //Get the match
        Globals.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey ?? ""), cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, error) in
            if Globals.handleAppSyncErrors(forQuery: "GetMatchQuery-MatchOverview", result: result, error: error) {
                let matches = result?.data?.listMatches?.map({$0!.fragments.match}) ?? []
                let match = matches.first(where: {$0.key == matchKey})
                self.setUpForMatch(match: match, preselectedTeamKey: preSelectedTeamKey)
                
                //TODO: - Also update the apollo cache for ListMatchesQuery with this result
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
    
	private func setUpForMatch(match: Match?, preselectedTeamKey: String? = nil) {
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
            
            if segmentedControl.selectedSegmentIndex == -1 {
				//Set the segment with the preselected team
				if let teamKey = preselectedTeamKey {
					if let index = teamKeys.firstIndex(of: teamKey) {
						segmentedControl.selectedSegmentIndex = index
					} else {
						segmentedControl.selectedSegmentIndex = 0
					}
				} else {
					segmentedControl.selectedSegmentIndex = 0
				}
            }
            self.selectedDifferentTeam(segmentedControl)
        } else {
            matchTitleLabel.text = "Match"
            
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
        if let match = self.displayedMatch, let scoutTeam = Globals.dataManager.enrolledScoutingTeamID {
            matchPerformanceDetail.load(match: match, forTeamKey: teamKeys[sender.selectedSegmentIndex], inScoutTeam: scoutTeam)
        } else {
            matchPerformanceDetail.load(match: nil, forTeamKey: nil, inScoutTeam: nil)
        }
    }
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func presentNotes(_ sender: Any) {
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
