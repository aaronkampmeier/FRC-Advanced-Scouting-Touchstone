//
//  PitScoutingTableViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/12/20.
//  Copyright © 2020 Kampfire Technologies. All rights reserved.
//

import UIKit

class PitScoutingTableViewCell: UITableViewCell {
    private var label: UILabel?
    private var controlItem: UIControl?
    
    private var input: PitScoutingInput?
    private var updateHandler: ((Any?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.label = contentView.viewWithTag(1) as? UILabel
        self.controlItem = contentView.viewWithTag(2) as? UIControl
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setUp(forInput input: PitScoutingInput, currentValue: Any?, andUpdateHandler updateHandler: @escaping (Any?) -> Void) {
        self.updateHandler = updateHandler
        self.input = input
        label?.text = input.label
        
        controlItem?.removeTarget(nil, action: nil, for: .allEvents)
        //Put in the current value
        switch input.type {
        case .selectString:
            let segmentedControl = controlItem as? UISegmentedControl
            segmentedControl?.removeAllSegments()
            if let options = input.options {
                for (index, option) in options.enumerated() {
                    segmentedControl?.insertSegment(withTitle: option, at: index, animated: false)
                }
            }
            
            //Select the current value
            if let currentValue = currentValue as? String {
                if let index = input.options?.firstIndex(of: currentValue) {
                    segmentedControl?.selectedSegmentIndex = index
                } else {
                    segmentedControl?.selectedSegmentIndex = -1
                }
            } else {
                segmentedControl?.selectedSegmentIndex = -1
            }
            break
        case .button:
            controlItem?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            controlItem?.isSelected = currentValue as? Bool ?? false
            break
        case .binary:
            (controlItem as? UISwitch)?.isOn = currentValue as? Bool ?? false
            break
        case .string:
            let textField: UITextField? = controlItem as? UITextField
            (textField)?.text = currentValue as? String
            textField?.keyboardType = .asciiCapable
            textField?.autocapitalizationType = .sentences
            break
        case .double:
            let textField: UITextField? = controlItem as? UITextField
            (textField)?.text = (currentValue as? Double)?.description
            textField?.keyboardType = .asciiCapableNumberPad
            break
        }
        
        controlItem?.addTarget(self, action: #selector(controlUpdated(_:)), for: .allEvents)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func controlUpdated(_ sender: UIControl) {
        if let controlItem = controlItem {
            switch controlItem {
            case let textField as UITextField:
                if input?.type == .double {
                    updateHandler?(Double(textField.text ?? ""))
                } else {
                    updateHandler?(textField.text)
                }
                break
            case let button as UIButton:
                updateHandler?(button.isSelected)
                break
            case let switchControl as UISwitch:
                updateHandler?(switchControl.isOn)
                break
            case let segmentSelector as UISegmentedControl:
                updateHandler?(segmentSelector.titleForSegment(at: segmentSelector.selectedSegmentIndex))
                break
            default:
                break
            }
        }
    }

}
