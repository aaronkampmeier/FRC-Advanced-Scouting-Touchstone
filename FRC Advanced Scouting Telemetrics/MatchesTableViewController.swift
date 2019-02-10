//
//  TeamMatchesTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/17/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

protocol MatchesTableViewControllerDelegate {
    func hasSelectionEnabled() -> Bool
    func matchesTableViewController(_ matchesTableViewController: MatchesTableViewController, selectedMatchCell: UITableViewCell?, withAssociatedMatch associatedMatch: Match?)
}

class MatchesTableViewController: UITableViewController {
    
    var delegate: MatchesTableViewControllerDelegate?
    
    var matches: [Match] = []
    
    var noMatchesView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        tableView.allowsSelection = delegate?.hasSelectionEnabled() ?? false
        
        noMatchesView = UIView()
        noMatchesView.isHidden = true
        let labelView = UILabel()
        noMatchesView.addSubview(labelView)
        labelView.text = "There are no matches currently loaded. This could be because the match schedule was not published yet. Try having you or one of your scouts reload the event by clicking the gear on the main screen and then swiping left on an event."
        labelView.numberOfLines = 0
        labelView.textAlignment = NSTextAlignment.center
        labelView.textColor = UIColor.lightGray
        labelView.font = labelView.font.withSize(20)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.centerXAnchor.constraint(equalTo: noMatchesView.centerXAnchor).isActive = true
        labelView.centerYAnchor.constraint(equalTo: noMatchesView.centerYAnchor).isActive = true
        if #available(iOS 11.0, *) {
            labelView.leadingAnchor.constraint(greaterThanOrEqualTo: noMatchesView.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
            labelView.trailingAnchor.constraint(lessThanOrEqualTo: noMatchesView.safeAreaLayoutGuide.trailingAnchor, constant: 10).isActive = true
        } else {
            // Fallback on earlier versions
            labelView.leadingAnchor.constraint(greaterThanOrEqualTo: noMatchesView.leadingAnchor, constant: 10).isActive = true
            labelView.trailingAnchor.constraint(lessThanOrEqualTo: noMatchesView.trailingAnchor, constant: 10).isActive = true
        }
        
        tableView.backgroundView = noMatchesView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(forEventKey eventKey: String?, specifyingTeam teamKey: String? = nil) {
        self.matches = []
        tableView.reloadData()
        
        if let eventKey = eventKey {
            //Get the matches
            Globals.appDelegate.appSyncClient?.fetch(query: ListMatchesQuery(eventKey: eventKey), cachePolicy: .returnCacheDataAndFetch, resultHandler: {[weak self] (result, error) in
                if Globals.handleAppSyncErrors(forQuery: "ListMatchesQuery", result: result, error: error) {
                    let returnedMatches = (result?.data?.listMatches?.map {$0!.fragments.match} ?? []).sorted(by: { (match1, match2) -> Bool in
                        return match1 < match2
                    })
                    if let teamKey = teamKey {
                        self?.matches = returnedMatches.filter {match in
                            if match.alliances?.blue?.teamKeys?.contains(teamKey) ?? false || match.alliances?.red?.teamKeys?.contains(teamKey) ?? false {
                                return true
                            } else {
                                return false
                            }
                        }
                    } else {
                        self?.matches = returnedMatches
                    }
                    
                    self?.tableView.reloadData()
                    self?.scrollToSoonest()
                } else {
                    //TODO: Throw error
                    
                }
            })
        }
    }
    
    func scrollToSoonest() {
        //Scroll to the match that is up next according to the schedule, assuming they are in order by time
        var closestMatchAndTimeDistance: (match: Match, distance: TimeInterval)?
        for match in matches {
            guard let t = match.time else {
                return
            }
            let matchTime = Double(t) as TimeInterval
            let matchDate = Date(timeIntervalSince1970: matchTime)
            
            let timeDifference = abs(matchDate.timeIntervalSince(Date()))
            
            if timeDifference <= closestMatchAndTimeDistance?.distance ?? 0 || closestMatchAndTimeDistance == nil {
                closestMatchAndTimeDistance = (match, abs(timeDifference))
            }
        }
        
        if let closest = closestMatchAndTimeDistance {
            let index = matches.firstIndex {$0.key == closest.match.key} ?? 0
            
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.preferredContentSize = tableView.contentSize
        noMatchesView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if matches.count > 0 {
            noMatchesView.isHidden = true
            tableView.separatorStyle = .singleLine
            return 1
        } else {
            noMatchesView.isHidden = false
            tableView.separatorStyle = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell") as! MatchListTableViewCell
        
        let match = matches[indexPath.row]
        cell.matchLabel.text = match.description
        
        for teamLabel in cell.teamLabels {
            teamLabel.layer.borderColor = nil
        }
        
        //Get the team numbers
        if match.alliances?.red?.teamKeys?.count ?? 0 >= 3 && match.alliances?.blue?.teamKeys?.count ?? 0 >= 3 {
            cell.red1.text = match.alliances?.red?.teamKeys?[0]?.trimmingCharacters(in: CharacterSet.letters)
            cell.red2.text = match.alliances?.red?.teamKeys?[1]?.trimmingCharacters(in: CharacterSet.letters)
            cell.red3.text = match.alliances?.red?.teamKeys?[2]?.trimmingCharacters(in: CharacterSet.letters)
            
            cell.blue1.text = match.alliances?.blue?.teamKeys?[0]?.trimmingCharacters(in: CharacterSet.letters)
            cell.blue2.text = match.alliances?.blue?.teamKeys?[1]?.trimmingCharacters(in: CharacterSet.letters)
            cell.blue3.text = match.alliances?.blue?.teamKeys?[2]?.trimmingCharacters(in: CharacterSet.letters)
        }
        
        
        if let date = match.time {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            
            dateFormatter.dateFormat = "EEE dd, HH:mm"
            cell.timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
        } else {
            cell.timeLabel.text = ""
        }
        cell.timeLabelWidth.constant = cell.timeLabel.intrinsicContentSize.width
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.matchesTableViewController(self, selectedMatchCell: tableView.cellForRow(at: indexPath), withAssociatedMatch: matches[indexPath.row])
    }
}
