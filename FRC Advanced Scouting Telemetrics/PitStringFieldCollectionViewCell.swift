//
//  PitStringFieldCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/6/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitStringFieldCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var key: String?
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        self.label.text = parameter.label
        self.key = parameter.key
        
        if let value = parameter.currentValue() as? String {
            textField.text = value
        }
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        //TODO: Sanitize the data
        if let key = key {
            pitScoutingVC?.registerUpdate(forKey: key, value: sender.text)
        }
    }
}
