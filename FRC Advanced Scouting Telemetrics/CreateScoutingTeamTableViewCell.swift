//
//  CreateScoutingTeamTableViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/6/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit

class CreateScoutingTeamTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var updateHandler: ((String?) -> Bool)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerTextFieldHandler(updateHandler: @escaping (String?) -> Bool) {
        self.updateHandler = updateHandler
    }

    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if updateHandler?(sender.text) ?? false {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
}
