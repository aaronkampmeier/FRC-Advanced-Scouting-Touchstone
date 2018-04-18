//
//  TeamMatchesTableViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/17/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol MatchesTableViewControllerDelegate {
    func hasSelectionEnabled() -> Bool
    func matchesTableViewController(_ matchesTableViewController: MatchesTableViewController, selectedMatchCell: UITableViewCell?, withAssociatedMatch associatedMatch: Match?)
}

class MatchesTableViewController: UITableViewController {
    
    var delegate: MatchesTableViewControllerDelegate?
    
    var matches: [Match] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        
        //Scroll to the match that is up next according to the schedule, assuming they are in order by time
        var closestMatchAndTimeDistance: (match: Match, distance: TimeInterval)?
        for match in matches {
            guard let matchTime = match.time else {
                break
            }
            
            let timeDifference = abs(matchTime.timeIntervalSince(Date()))
            
            if timeDifference <= closestMatchAndTimeDistance?.distance ?? 0 || closestMatchAndTimeDistance == nil {
                closestMatchAndTimeDistance = (match, abs(timeDifference))
            }
        }
        
        if let closest = closestMatchAndTimeDistance {
            let index = matches.index(of: closest.match)!
            
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(withMatches matches: [Match]) {
        self.matches = matches
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
        
        cell.red1.text = match.teamMatchPerformance(forColor: .Red, andSlot: .One).teamEventPerformance?.team?.teamNumber.description
        cell.red2.text = match.teamMatchPerformance(forColor: .Red, andSlot: .Two).teamEventPerformance?.team?.teamNumber.description
        cell.red3.text = match.teamMatchPerformance(forColor: .Red, andSlot: .Three).teamEventPerformance?.team?.teamNumber.description
        
        cell.blue1.text = match.teamMatchPerformance(forColor: .Blue, andSlot: .One).teamEventPerformance?.team?.teamNumber.description
        cell.blue2.text = match.teamMatchPerformance(forColor: .Blue, andSlot: .Two).teamEventPerformance?.team?.teamNumber.description
        cell.blue3.text = match.teamMatchPerformance(forColor: .Blue, andSlot: .Three).teamEventPerformance?.team?.teamNumber.description
        
        
        if let date = match.time {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            
            dateFormatter.dateFormat = "EEE dd, HH:mm"
            cell.timeLabel.text = dateFormatter.string(from: date)
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
