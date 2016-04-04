//
//  DataSyncingViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class DataSyncingViewController: UIViewController, UITableViewDataSource{
	@IBOutlet weak var connectedDevicesTable: UITableView!

	var connectedPeers = [FASTPeer]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		connectedPeers = DataSyncer.sharedDataSyncer().connectedPeers()
		connectedDevicesTable.dataSource = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataSyncingViewController.peerChangedState(_:)), name:"DataSyncing:DidChangeState", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	func peerChangedState(notification: NSNotification) {
		let peer = notification.userInfo!["peer"] as! FASTPeer
		let state = SessionState.init(rawValue: notification.userInfo!["state"] as! Int)!
		
		switch state {
		case .Connected:
			connectedPeers.append(peer)
			connectedDevicesTable.beginUpdates()
			connectedDevicesTable.insertRowsAtIndexPaths([NSIndexPath.init(forRow: connectedPeers.indexOf(peer)!, inSection: 0)], withRowAnimation: .Automatic)
			connectedDevicesTable.endUpdates()
		case .Connecting, .NotConnected:
			if connectedPeers.contains(peer) {
				let index = connectedPeers.indexOf(peer)!
				connectedPeers.removeAtIndex(index)
				connectedDevicesTable.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
			}
		}
	}

	@IBAction func syncPressed(sender: UIBarButtonItem) {
		sender.enabled = false
		//Start a data merge
		TeamDataManager().commitChanges()
		DataSyncer.sharedDataSyncer().syncWithCompletion() {error in
			sender.enabled = true
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return connectedPeers.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
		cell.textLabel!.text = connectedPeers[indexPath.row].displayName
		return cell
	}
}
