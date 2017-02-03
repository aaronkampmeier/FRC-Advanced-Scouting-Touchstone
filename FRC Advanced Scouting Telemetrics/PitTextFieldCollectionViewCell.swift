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
    
    override func setUp(label: String, options: [String]?, updateHandler: @escaping PitScoutingUpdateHandler) {
        self.label.text = label
        self.updateHandler = updateHandler
    }
    
    override func setValue(value: Any?) {
        if let value = value as? Int {
            textField.text = value.description
        }
        NSLog("")
    }
    
    @IBAction func textFieldEditingEnded(_ sender: UITextField) {
        //TODO: Sanitize the data
        updateHandler?(Int(sender.text ?? ""))
    }
}
