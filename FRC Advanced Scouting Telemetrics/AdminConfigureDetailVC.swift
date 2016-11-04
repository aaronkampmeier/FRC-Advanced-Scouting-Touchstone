//
//  AdminConfigureDetailVC.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/12/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import Foundation
import UIKit

class AdminConfigureDetailVC: UIViewController {
    var detailViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Perform segue only works after the view has appeared
    }
    
    func presentMatchDetailView() {
        performSegue(withIdentifier: "configureMatchDetailSegue", sender: nil)
    }
	
	func presentRegionalDetailView() {
		performSegue(withIdentifier: "configureRegionalDetailSegue", sender: nil)
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "configureMatchDetailSegue" || segue.identifier == "configureRegionalDetailSegue" {
            detailViewController = segue.destination
        }
    }
}
