//
//  GameStatsCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class GameStatsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
	@IBOutlet weak var button: UIButton!
	var tapDelegate: GameStatsCollectionViewCellTapDelegate?
	
	@IBAction func tapped(_ sender: UIButton) {
		tapDelegate?.gameStatsCellDidTap(onCell: self)
	}
}

protocol GameStatsCollectionViewCellTapDelegate {
	func gameStatsCellDidTap(onCell cell: UICollectionViewCell)
}
