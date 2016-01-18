//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var teamList: UITableView!
    @IBOutlet weak var teamNumberLabel: UILabel!
    @IBOutlet weak var driverExpLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    let teamManager = TeamDataManager()
    
    var teams = [Team]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add responder for notification about a new team
        NSNotificationCenter.defaultCenter().addObserverForName("New Team", object: nil, queue: nil, usingBlock: addTeamFromNotification)
        
        teamList.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        teams = teamManager.getTeams()
        
    }
    
    func addTeamFromNotification(notification:NSNotification) {
        teams = teamManager.getTeams()
        teamList.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = teamList.dequeueReusableCellWithIdentifier("Cell")
        
        cell!.textLabel?.text = "Team \(teams[indexPath.row].valueForKey("teamNumber") as! String)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let teamSelected = teams[indexPath.row]
        
        teamNumberLabel.text = teamSelected.teamNumber
        
        weightLabel.text = "Weight: \(teamSelected.robotWeight) lbs"
        
        driverExpLabel.text = "Driver Exp: \(teamSelected.driverExp) yrs"
    }
    
    
    //Two functions to allow deletion of Teams from the Table View
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //Remove the team and reload the table
            teamManager.deleteTeam(teams[indexPath.row])
            teams.removeAtIndex(indexPath.row)
            teamList.reloadData()
        }
    }
}