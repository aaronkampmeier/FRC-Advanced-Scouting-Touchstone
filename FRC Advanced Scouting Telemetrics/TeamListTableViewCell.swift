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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
