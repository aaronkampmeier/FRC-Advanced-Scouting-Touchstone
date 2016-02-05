//
//  StatsVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class StatsVC: UIViewController {
    @IBOutlet weak var statsLabel: UILabel!
    let dataManager = TeamDataManager()
    var team: Team?
    
    override func viewDidLoad() {
        loadStats()
        NSNotificationCenter.defaultCenter().addObserverForName("New Stat", object: nil, queue: nil, usingBlock: {(notification) in self.loadStats()})
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "addStatSegue" {
            let destinationVC = segue.destinationViewController as! AddStatVC
            
            destinationVC.team = team!
        }
    }
    
    func loadStats() {
        if let currentTeam = team {
            let stats = dataManager.getStatsForTeam(currentTeam)
            
            var statsString = ""
            
            for stat in stats {
                let statType = (stat.statType as! StatType).name
                
                statsString.appendContentsOf("\(statType!): \(stat.value!)")
            }
            
            statsLabel.text = statsString
        }
    }
}