//
//  PitSwitchCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/4/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitSwitchCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    var updateHandler: PitScoutingUpdateHandler?
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        label.text = parameter.label
        updateHandler = parameter.updateHandler
        
        //Set current value
        if let currentValue = parameter.currentValue() as? Bool {
            `switch`.isOn = currentValue
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        pitScoutingVC?.register(update: updateHandler, withValue: sender.isOn)
    }
}
