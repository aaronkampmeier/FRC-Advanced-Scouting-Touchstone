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
        teamList.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        teamManager.saveTeamNumber("3354")
        teamManager.saveTeamNumber("23")
        teamManager.saveTeamNumber("254")
        
        teams = teamManager.getTeams()
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
    
}