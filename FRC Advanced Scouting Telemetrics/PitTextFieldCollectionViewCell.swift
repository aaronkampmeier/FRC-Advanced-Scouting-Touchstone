//
//  PitTextFieldCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/2/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitTextFieldCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var updateHandler: ((Any?)->Void)?
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        self.label.text = parameter.label
        self.updateHandler = parameter.updateHandler
        
        if let value = parameter.currentValue() as? Double {
            textField.text = value.description
        }
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        //TODO: Sanitize the data
        pitScoutingVC?.register(update: updateHandler, withValue: Double(sender.text ?? ""))
    }
}
