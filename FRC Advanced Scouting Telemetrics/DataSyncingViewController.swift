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
	@IBOutlet weak var syncIDField: UITextField!
	@IBOutlet weak var transferNumberLabel: UILabel!
	@IBOutlet weak var transferInfoButton: UIButton!
	
	var connectedPeers = [FASTPeer]()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		connectedPeers = DataSyncer.sharedDataSyncer().connectedPeers()
		connectedDevicesTable.dataSource = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataSyncingViewController.peerChangedState(_:)), name:"DataSyncing:DidChangeState", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataSyncingViewController.numberOfTransfersChanged(_:)), name: DSTransferNumberChanged, object: nil)
		
		transferNumberLabel.text = "\(DataSyncer.sharedDataSyncer().multipeerConnection.currentFileTransfers.count)"
		
		//Retreive the sync secret add display it in the textfield
		syncIDField.placeholder = "FRC-4256-FAST-EnsembleSync"
		let syncSecret = NSUserDefaults.standardUserDefaults().stringForKey("SharedSyncSecret")
		if let secret = syncSecret {
			syncIDField.text = secret
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	@IBAction func returnToDataSyncing(unwindSegue: UIStoryboardSegue) {
		
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
	
	func numberOfTransfersChanged(notification: NSNotification) {
		transferNumberLabel.text = "\(DataSyncer.sharedDataSyncer().multipeerConnection.currentFileTransfers.count)"
	}

	@IBAction func syncPressed(sender: UIBarButtonItem) {
		sender.enabled = false
		//Start a data merge
		DataSyncer.sharedDataSyncer().syncWithCompletion() {error in
			sender.enabled = true
		}
	}
	
	@IBAction func transferInfoPressed(sender: UIButton) {
		let transferInfoVC = storyboard?.instantiateViewControllerWithIdentifier("transferInfoTable") as! TransferInfoTableViewController
		transferInfoVC.preferredContentSize = CGSize(width: 300, height: 300)
		transferInfoVC.modalPresentationStyle = .Popover
		transferInfoVC.popoverPresentationController?.sourceView = sender
		presentViewController(transferInfoVC, animated: true, completion: nil)
	}
	
	@IBAction func syncIDChanged(sender: UITextField) {
		let storedSecret = NSUserDefaults.standardUserDefaults().stringForKey("SharedSyncSecret")
		if sender.text != storedSecret && !(sender.text == "" && storedSecret == nil) {
			//Save the new sync secret in the user defaults
			let enteredSecret = sender.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "")
			if enteredSecret == nil || enteredSecret == "" {
				NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "SharedSyncSecret")
			} else {
				NSUserDefaults.standardUserDefaults().setValue(enteredSecret!, forKey: "SharedSyncSecret")
			}
			
			//Disconnect from the sync cloud
			DataSyncer.sharedDataSyncer().disconnectFromCloud()
			
			//Present an alert saying the user needs to restart the app
			let alert = UIAlertController(title: "Please Restart", message: "The app must be restarted in order for this change (updating the sync ID) to take hold.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "Quit", style: .Destructive) {action in
				TeamDataManager().commitChanges()
				
				exit(EXIT_SUCCESS)
			})
			presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func donePressed(sender: UITextField) {
		sender.resignFirstResponder()
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
