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
		
		NotificationCenter.default.addObserver(self, selector: #selector(DataSyncingViewController.peerChangedState(_:)), name:"DataSyncing:DidChangeState" as NSNotification.Name, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(DataSyncingViewController.numberOfTransfersChanged(_:)), name: NSNotification.Name(rawValue: DSTransferNumberChanged), object: nil)
		
		transferNumberLabel.text = "\(DataSyncer.sharedDataSyncer().multipeerConnection.currentFileTransfers.count)"
		
		//Retreive the sync secret add display it in the textfield
		syncIDField.placeholder = "FRC-4256-FAST-EnsembleSync"
		let syncSecret = UserDefaults.standard.string(forKey: "SharedSyncSecret")
		if let secret = syncSecret {
			syncIDField.text = secret
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	@IBAction func returnToDataSyncing(_ unwindSegue: UIStoryboardSegue) {
		
	}
	
	func peerChangedState(_ notification: Notification) {
		let peer = (notification as NSNotification).userInfo!["peer"] as! FASTPeer
		let state = SessionState.init(rawValue: (notification as NSNotification).userInfo!["state"] as! Int)!
		
		switch state {
		case .connected:
			connectedPeers.append(peer)
			connectedDevicesTable.beginUpdates()
			connectedDevicesTable.insertRows(at: [IndexPath.init(row: connectedPeers.index(of: peer)!, section: 0)], with: .automatic)
			connectedDevicesTable.endUpdates()
		case .connecting, .notConnected:
			if connectedPeers.contains(peer) {
				let index = connectedPeers.index(of: peer)!
				connectedPeers.remove(at: index)
				connectedDevicesTable.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
			}
		}
	}
	
	func numberOfTransfersChanged(_ notification: Notification) {
		DispatchQueue.main.async {
			self.transferNumberLabel.text = "\(DataSyncer.sharedDataSyncer().multipeerConnection.currentFileTransfers.count)"
		}
	}

	@IBAction func syncPressed(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		//Start a data merge
		DataSyncer.sharedDataSyncer().syncWithCompletion() {error in
			sender.isEnabled = true
		}
	}
	
	@IBAction func transferInfoPressed(_ sender: UIButton) {
		let transferInfoVC = storyboard?.instantiateViewController(withIdentifier: "transferInfoTable") as! TransferInfoTableViewController
		transferInfoVC.preferredContentSize = CGSize(width: 300, height: 300)
		transferInfoVC.modalPresentationStyle = .popover
		transferInfoVC.popoverPresentationController?.sourceView = sender
		present(transferInfoVC, animated: true, completion: nil)
	}
	
	@IBAction func syncIDChanged(_ sender: UITextField) {
		let storedSecret = UserDefaults.standard.string(forKey: "SharedSyncSecret")
		if sender.text != storedSecret && !(sender.text == "" && storedSecret == nil) {
			//Save the new sync secret in the user defaults
			let enteredSecret = sender.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
			if enteredSecret == nil || enteredSecret == "" {
				UserDefaults.standard.setValue(nil, forKey: "SharedSyncSecret")
			} else {
				UserDefaults.standard.setValue(enteredSecret!, forKey: "SharedSyncSecret")
			}
			
			//Disconnect from the sync cloud
			DataSyncer.sharedDataSyncer().disconnectFromCloud()
			
			//Present an alert saying the user needs to restart the app
			let alert = UIAlertController(title: "Please Restart", message: "The app must be restarted in order for this change (updating the sync ID) to take hold.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Quit", style: .destructive) {action in
				TeamDataManager().commitChanges()
				
				exit(EXIT_SUCCESS)
			})
			present(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func donePressed(_ sender: UITextField) {
		sender.resignFirstResponder()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return connectedPeers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		cell.textLabel!.text = connectedPeers[(indexPath as NSIndexPath).row].displayName
		return cell
	}
}
