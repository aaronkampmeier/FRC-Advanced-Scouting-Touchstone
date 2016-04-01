//
//  ConflictTableViewCell.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/26/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class ConflictTableViewCell: UITableViewCell {
	@IBOutlet weak var mainTitle: UILabel!
	@IBOutlet weak var firstTitle: UILabel!
	@IBOutlet weak var firstDetail: UILabel!
	@IBOutlet weak var secondTitle: UILabel!
	@IBOutlet weak var secondDetail: UILabel!
	@IBOutlet weak var resolutionPicker: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
