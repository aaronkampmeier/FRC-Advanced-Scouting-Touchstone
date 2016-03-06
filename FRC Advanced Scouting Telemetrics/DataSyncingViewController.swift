//
//  DataSyncingViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 3/3/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class DataSyncingViewController: UIViewController {
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var progressIndicator: UIProgressView!
	@IBOutlet weak var syncButton: UIButton!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var searchForDevices: UIBarButtonItem!
	
	var syncingManager: SyncingManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
	
	func addObservers(forManager syncManager: SyncingManager) {
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidChangeState", object: syncManager, queue: nil, usingBlock: didChangeState)
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidStartReceiving", object: syncManager, queue: nil, usingBlock: didStartReceiving)
		NSNotificationCenter.defaultCenter().addObserverForName("DataSyncing:DidFinishReceiving", object: syncManager, queue: nil, usingBlock: didFinishReceiving)
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
	}
	
	func didChangeState(notification: NSNotification) {
		let userInfo = (notification.userInfo as! [String:AnyObject])
		let state = SessionState.init(rawValue: userInfo["state"] as! Int)
		let peerName = userInfo["peer"] as! String
		
		switch state! {
		case .Connected:
			self.statusLabel.text = "Did connect to \(peerName)"
		case .Connecting:
			self.statusLabel.text = "Connecting to \(peerName)"
		case .NotConnected:
			self.statusLabel.text = "Not Connected"
		}
	}
	
	func didStartReceiving(notification: NSNotification) {
		syncButton.enabled = false
		
		let userInfo = (notification.userInfo as! [String:AnyObject])
		let progress = userInfo["progress"] as! NSProgress
		progressIndicator.observedProgress = progress
	}
	
	func didFinishReceiving(notification: NSNotification) {
		
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
