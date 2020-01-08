//
//  SuperNotesCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/31/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class SuperNotesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var teamLabel: UILabel!
    
    var eventKey: String?
    var teamKey: String?
    var notesVC: TeamCommentsTableViewController!
    
    func setUp(inScoutTeam scoutTeam: String, forEventKey eventKey: String, teamKey: String) {
        
        self.eventKey = eventKey
        self.teamKey = teamKey
        teamLabel.text = teamKey.trimmingCharacters(in: CharacterSet.letters)
        
        notesVC.load(inScoutTeam: scoutTeam, forEventKey: eventKey, andTeamKey: teamKey)
    }
}
