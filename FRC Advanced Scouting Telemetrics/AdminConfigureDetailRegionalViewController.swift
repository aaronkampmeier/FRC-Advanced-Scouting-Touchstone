//
//  AdminConfigureDetailRegionalViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/16/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class AdminConfigureDetailRegionalViewController: UIViewController {
	@IBOutlet weak var nameField: UITextField!
	
	var selectedRegional: Regional?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.hidden = true
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewWillChange()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func nameChanged(sender: UITextField) {
		
	}
	
	func didSelectRegional(regional: Regional) {
		viewWillChange()
		view.hidden = false
		
		nameField.text = regional.name
		selectedRegional = regional
	}
	
	func viewWillChange() {
		//Chang the name and save it
		selectedRegional?.name = nameField.text
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
