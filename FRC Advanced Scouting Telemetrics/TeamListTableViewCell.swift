//
//  TeamListTableViewCell.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListTableViewCell: UITableViewCell {
	@IBOutlet weak var rankLabel: UILabel!
	@IBOutlet weak var frontImage: UIImageView!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var statLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var myTeamIndicatorImageView: UIImageView!
    
    //Used to keep track of the state of this cell (what team it is for and what stat it is displaying)
    var stateID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
