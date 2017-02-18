//
//  MatchListTableViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/17/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchListTableViewCell: UITableViewCell {
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var red1: UILabel!
    @IBOutlet weak var red2: UILabel!
    @IBOutlet weak var red3: UILabel!
    @IBOutlet weak var blue1: UILabel!
    @IBOutlet weak var blue2: UILabel!
    @IBOutlet weak var blue3: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet var teamLabels: [UILabel]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
