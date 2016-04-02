//
//  DataSyncingViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class DataSyncingViewController: UIViewController, ConflictManager {
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var progressIndicator: UIProgressView!
	@IBOutlet weak var syncButton: UIButton!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var searchForDevices: UIBarButtonItem!
	@IBOutlet weak var mergingLabel: UILabel!
	@IBOutlet weak var mergingActivityIndicator: UIActivityIndicatorView!
	
	var syncingManager: SyncingManager?
	let dataManager = TeamDataManager()
	
	var conflictManagerVC: SyncingConflictViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//Commit any unsaved changes
		dataManager.commitChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		syncingManager = SyncingManager()
		addObservers(forManager: syncingManager!)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		syncingManager = nil
	}
	
	var completionHandler: ([MergeManager.Conflict] -> Void)?
	func conflictManager(resolveConflicts conflicts: [MergeManager.Conflict], completionHandler: [MergeManager.Conflict] -> Void) {
		conflictManagerVC = storyboard?.instantiateViewControllerWithIdentifier("conflictManager") as! SyncingConflictViewController
		conflictManagerVC?.conflicts = conflicts
		presentViewController(conflictManagerVC!, animated: true, completion: nil)
		
		self.completionHandler = completionHandler
	}
	
	@IBAction func returningFromConflictResolution(segue: UIStoryboardSegue) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			self.completionHandler!((self.conflictManagerVC?.conflicts)!)
		}
	}
	
	func addObservers(forManager syncManager: SyncingManager) {
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidChangeState", object: syncManager, queue: nil, usingBlock: didChangeState)
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidStartReceiving", object: syncManager, queue: nil, usingBlock: didStartReceiving)
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidFinishReceiving", object: syncManager, queue: nil, usingBlock: didFinishReceiving)
		
		NSNotificationCenter.defaultCenter().addObserverForName("Registration needed for conflict manager", object: nil, queue: nil) {_ in
			NSNotificationCenter.defaultCenter().postNotificationName("Registering for conflict manager", object: self)
		}
		NSNotificationCenter.defaultCenter().addObserverForName("MergeManager:MergeFinished", object: nil, queue: nil) {notification in
			let alert = notification.userInfo!["alertToPresent"] as! UIAlertController
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
	
	@IBAction func donePressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func connectPressed(sender: UIBarButtonItem) {
		//Get a MCBrowserViewController
		let browserVC = syncingManager!.getServiceBrowserViewController()
		presentViewController(browserVC, animated: true, completion: nil)
	}
	
	@IBAction func syncPressed(sender: UIButton) {
		progressIndicator.observedProgress = syncingManager?.sync()
		syncButton.enabled = false
	}
	
	func didChangeState(notification: NSNotification) {
		let userInfo = (notification.userInfo as! [String:AnyObject])
		let state = SessionState.init(rawValue: userInfo["state"] as! Int)
		let peerName = userInfo["peer"] as! String
		
		switch state! {
		case .Connected:
			self.statusLabel.text = "Did connect to \(peerName)"
			syncButton.enabled = true
		case .Connecting:
			self.statusLabel.text = "Connecting to \(peerName)"
			syncButton.enabled = false
		case .NotConnected:
			self.statusLabel.text = "Not Connected"
			syncButton.enabled = false
		}
	}
	
	func didStartReceiving(notification: NSNotification) {
		syncButton.enabled = false
		
		let userInfo = (notification.userInfo as! [String:AnyObject])
		let progress = userInfo["progress"] as! NSProgress
		progressIndicator.observedProgress = progress
	}
	
	func didFinishReceiving(notification: NSNotification) {
		//Finished receiving, show merging label
		mergingLabel.hidden = false
		mergingActivityIndicator.startAnimating()
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
