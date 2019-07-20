//
//  PitTableViewSelectorCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

//Used for multiple selections
class PitTableViewSelectorCollectionViewCell: PitScoutingCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var key: String?
    var options: [String] = []
//    var selectedOptions = [String]() {
//        didSet {
//            pitScoutingVC?.register(update: updateHandler, withValue: selectedOptions)
//        }
//    }
    var selectedOption: String? {
        didSet {
            if let key = key {
                pitScoutingVC?.registerUpdate(forKey: key, value: selectedOption)
            }
        }
    }
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        label.text = parameter.label
        self.key = parameter.key
        options = parameter.options!
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.layer.cornerRadius = 9
        tableView.reloadData()
        tableView.allowsMultipleSelection = false
        
        selectedOption = parameter.currentValue() as? String
        if let index = options.firstIndex(of: selectedOption ?? "") {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .bottom)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = options[indexPath.row]
        if options[indexPath.row] == selectedOption {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = options[indexPath.row]
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedOption = nil
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Single Select List"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
}
