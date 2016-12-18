//
//  AdminConsoleController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/17/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AdminConsoleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var navigationBar: UINavigationItem!
    
    let dataManager = TeamDataManager()
    
    override func viewDidLoad() {
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		<#code#>
	}
	
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
		dataManager.commitChanges()
        dismiss(animated: true, completion: nil)
    }
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dataManager.discardChanges()
		dismiss(animated: true, completion: nil)
	}
    
    func comingBackFromConfigure() {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
		
    }
}
