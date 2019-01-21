//
//  PitSegmentedSelectorCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitSegmentedSelectorCollectionViewCell: PitScoutingCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var key: String?
    var options = [String]() {
        didSet {
            //Remove all the segments to reset it
            segmentedControl.removeAllSegments()
            //Add in the segments for the options
            for (index, option) in options.enumerated() {
                segmentedControl.insertSegment(withTitle: option, at: index, animated: false)
            }
        }
    }
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        label.text = parameter.label
        self.key = parameter.key
        options = parameter.options!
        
        
        //Set the initial value
        if let initValue = parameter.currentValue() as? String {
            if let index = options.index(of: initValue) {
                segmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        if let key = key {
            pitScoutingVC?.registerUpdate(forKey: key, value: options[sender.selectedSegmentIndex])
        }
    }
}
