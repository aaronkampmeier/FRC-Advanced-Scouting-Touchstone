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
	@IBOutlet weak var transferNumberLabel: UILabel!
	@IBOutlet weak var transferInfoButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

	@IBAction func syncPressed(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		//Start a data merge
		
        
	}
	
	@IBAction func transferInfoPressed(_ sender: UIButton) {
        let transferNavVC = storyboard?.instantiateViewController(withIdentifier: "transferInfoNav") as! UINavigationController
		transferNavVC.preferredContentSize = CGSize(width: 300, height: 300)
		transferNavVC.modalPresentationStyle = .popover
		transferNavVC.popoverPresentationController?.sourceView = sender
        transferNavVC.popoverPresentationController?.delegate = self
		present(transferNavVC, animated: true, completion: nil)
	}
	
	@IBAction func donePressed(_ sender: UITextField) {
		sender.resignFirstResponder()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
		return cell
	}
}

extension DataSyncingViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
