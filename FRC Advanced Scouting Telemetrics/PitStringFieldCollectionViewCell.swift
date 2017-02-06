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
    
    var updateHandler: PitScoutingUpdateHandler?
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        self.label.text = parameter.label
        self.updateHandler = parameter.updateHandler
        
        if let value = parameter.currentValue() as? String {
            textField.text = value
        }
    }
    
    @IBAction func textEditingEnded(_ sender: UITextField) {
        //TODO: Sanitize the data
        updateHandler?(sender.text)
    }
}
