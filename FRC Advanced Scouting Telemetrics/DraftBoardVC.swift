//
//  DraftBoardVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/30/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class DraftBoardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var teamListTableView: UITableView!
    
    let dataManager = TeamDataManager()
    var teamsArray = [Team]()
    
    override func viewDidLoad() {
        do {
            teamsArray = try dataManager.getDraftBoard()
        } catch {
            NSLog("Unable to retrieve the saved draft board: \(error)")
        }
        teamListTableView.delegate = self
        teamListTableView.dataSource = self
        
        teamListTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        teamListTableView.setEditing(true, animated: true)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamListTableView.dequeueReusableCellWithIdentifier("Cell")
        
        cell!.textLabel?.text = "Team \(teamsArray[indexPath.row].teamNumber! as String)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        //Move the team in the array and in Core Data
        let movedTeam = teamsArray[sourceIndexPath.row]
        teamsArray.removeAtIndex(sourceIndexPath.row)
        teamsArray.insert(movedTeam, atIndex: destinationIndexPath.row)
        
        do {
            try dataManager.moveTeam(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        } catch {
            NSLog("Unable to save team move: \(error)")
        }
    }
}