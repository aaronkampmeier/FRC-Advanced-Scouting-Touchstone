//
//  TeamDetailTableCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamDetailTableCollectionViewCell: UICollectionViewCell, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var values: [String:String?] = [:]
    
    func load(withValues values: [String:String?]) {
        tableView.dataSource = self
        
        self.values = values
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail")
        
        let key = Array(values.keys)[indexPath.row]
        
        cell?.textLabel?.text = key
        cell?.detailTextLabel?.text = values[key] ?? "No Value"
        
        return cell!
    }
}
