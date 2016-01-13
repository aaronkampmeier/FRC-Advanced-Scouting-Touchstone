//
//  TeamListController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/5/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import CoreData

class TeamListController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var teamList: UITableView!
    let teamManager = TeamDataManager()
    
    var teams = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamList.dataSource = self
        teamList.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        teams.append(teamManager.saveTeamNumber("2312"))
        teams.append(teamManager.saveTeamNumber("4256"))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Team")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            teams = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = teamList.dequeueReusableCellWithIdentifier("Cell")
        
        cell!.textLabel?.text = "Team \(teams[indexPath.row].valueForKey("teamNumber") as! String)"
        
        return cell!
    }
    
    @IBAction func addTeam(sender: UIButton) {
        teams.append(teamManager.saveTeamNumber("132"))
    }
    
}