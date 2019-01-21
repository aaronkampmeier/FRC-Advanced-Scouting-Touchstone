//
//  PitSwitchCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/4/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitButtonCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var key: String?
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        button.imageView?.contentMode = .scaleAspectFit
        label.text = parameter.label
        self.key = parameter.key
        
        if let value = parameter.currentValue() as? Bool {
            button.isSelected = value
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if let key = key {
            pitScoutingVC?.registerUpdate(forKey: key, value: sender.isSelected)
        }
    }
}
