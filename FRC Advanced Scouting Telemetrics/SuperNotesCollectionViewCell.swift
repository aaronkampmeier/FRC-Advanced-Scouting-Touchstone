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
    
    var team: Team?
    var notesVC: TeamCommentsTableViewController!
    
    func setUp(forTeam team: Team) {
        notesVC.dataSource = self
        
        self.team = team
        teamLabel.text = "\(team.teamNumber)"
        
        notesVC.load()
    }
}

extension SuperNotesCollectionViewCell: NotesDataSource {
    func currentTeamContext() -> Team {
        return team!
    }
}
