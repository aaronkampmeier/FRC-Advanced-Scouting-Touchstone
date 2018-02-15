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
    var notesVC: NotesViewController!
    
    func setUp(forTeam team: Team) {
        notesVC.dataSource = self
        
        self.team = team
        teamLabel.text = "\(team.teamNumber)"
        
        notesVC.reload()
    }
    
}

extension SuperNotesCollectionViewCell: NotesDataSource {
    func currentTeamContext() -> Team {
        return team!
    }
    
    func notesShouldSave() -> Bool {
        //TODO: Hmm figure this out with realm writes
        return false
    }
}
