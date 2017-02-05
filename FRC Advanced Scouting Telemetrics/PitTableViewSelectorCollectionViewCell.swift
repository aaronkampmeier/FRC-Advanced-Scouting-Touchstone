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
    
    var updateHandler: PitScoutingUpdateHandler?
    var options: [String] = []
    var selectedOptions = [String]() {
        didSet {
            updateHandler?(selectedOptions)
        }
    }
    
    override func setUp(_ parameter: PitScoutingViewController.PitScoutingParameter) {
        label.text = parameter.label
        updateHandler = parameter.updateHandler
        options = parameter.options!
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        tableView.allowsMultipleSelection = true
        
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
        //Set current values
        if let currentValues = parameter.currentValue() as? [String] {
            for value in currentValues {
                if let index = options.index(of: value) {
                    tableView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .none)
                    tableView.cellForRow(at: IndexPath.init(row: index, section: 0))?.accessoryType = .checkmark
                }
            }
            selectedOptions = currentValues
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
        if selectedOptions.contains(options[indexPath.row]) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOptions.append(options[indexPath.row])
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedOptions.remove(at: selectedOptions.index(of: options[indexPath.row])!)
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
