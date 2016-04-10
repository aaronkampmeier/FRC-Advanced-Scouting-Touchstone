//
//  MatchOverviewViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 4/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewViewController: UIViewController, UITableViewDataSource {
	@IBOutlet weak var matchOverviewTable: UITableView!
	
	var teamListController: TeamListController!
	var matchTimeMarkers: [[TeamDataManager.TimeMarkerEvent]] = Array<Array<TeamDataManager.TimeMarkerEvent>>()
	
	enum MatchPerformance {
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamListController = parentViewController as! TeamListController
		for performance in teamListController.teamRegionalPerformance?.matchPerformances ?? NSSet() {
			
		}
		
		matchOverviewTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchTimeMarkers[section].count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return teamListController.teamRegionalPerformance?.matchPerformances?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return UITableViewCell()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
