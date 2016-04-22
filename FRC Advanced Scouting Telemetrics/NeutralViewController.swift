//
//  NeutralViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/26/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class NeutralViewController: UIViewController {
	@IBOutlet weak var lowBarButton: UIButton!
	@IBOutlet weak var defense4Button: UIButton!
	@IBOutlet weak var defense3Button: UIButton!
	@IBOutlet weak var defense2Button: UIButton!
	@IBOutlet weak var defense1Button: UIButton!
	@IBOutlet weak var elapsedTimeLabel: UILabel!
	
	var standsScoutingController: StandsScoutingViewController!
	let dataManager = TeamDataManager()
	var defenses: [Defense]?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		standsScoutingController = parentViewController as! StandsScoutingViewController
		//Get the defenses
		defenses = standsScoutingController.defenses
		
		//Set up all the buttons
		lowBarButton.imageView?.contentMode = .ScaleAspectFit
		defense4Button.imageView?.contentMode = .ScaleAspectFit
		defense3Button.imageView?.contentMode = .ScaleAspectFit
		defense2Button.imageView?.contentMode = .ScaleAspectFit
		defense1Button.imageView?.contentMode = .ScaleAspectFit
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if defenses?.count == 4 {
			//Set the buttons with the defenses images
			defense4Button.setImage(UIImage(named: defenses![0].defenseName!), forState: .Normal)
			defense3Button.setImage(UIImage(named: defenses![1].defenseName!), forState: .Normal)
			defense2Button.setImage(UIImage(named: defenses![2].defenseName!), forState: .Normal)
			defense1Button.setImage(UIImage(named: defenses![3].defenseName!), forState: .Normal)
		} else {
			let alert = UIAlertController(title: "No Defenses", message: "There are no defenses set for this match. You must set some in the admin console before tracking neutral times.", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func defensePressed(sender: UIButton) {
		let defense: Defense!
		switch sender {
		case lowBarButton:
			defense = dataManager.getLowBar()
		case defense4Button:
			defense = defenses![0]
		case defense3Button:
			defense = defenses![1]
		case defense2Button:
			defense = defenses![2]
		case defense1Button:
			defense = defenses![3]
		default:
			defense = nil
		}
		
		dataManager.addDefenseCrossTime(forMatchPerformance: standsScoutingController.matchPerformance!, inDefense: defense, withTime: 1)
		dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.FinishedCrossingDefense, atTime: standsScoutingController.stopwatch.elapsedTime, inMatchPerformance: standsScoutingController.matchPerformance!)
		
		//Switch to the offense courtyard
		standsScoutingController.segmentedControl.selectedSegmentIndex = 1
		standsScoutingController.selectedNewPart(standsScoutingController.segmentedControl)
	}
	
	@IBAction func breachedLowBar(sender: UISwitch) {
		switch sender.on {
		case true:
			dataManager.setDidBreachDefense(dataManager.getLowBar(), inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDidNotBreachDefense(dataManager.getLowBar(), inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense4(sender: UISwitch) {
		switch sender.on {
		case true:
			dataManager.setDidBreachDefense(defenses![0], inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDidNotBreachDefense(defenses![0], inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense3(sender: UISwitch) {
		switch sender.on {
		case true:
			dataManager.setDidBreachDefense(defenses![1], inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDidNotBreachDefense(defenses![1], inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense2(sender: UISwitch) {
		switch sender.on {
		case true:
			dataManager.setDidBreachDefense(defenses![2], inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDidNotBreachDefense(defenses![2], inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense1(sender: UISwitch) {
		switch sender.on {
		case true:
			dataManager.setDidBreachDefense(defenses![3], inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDidNotBreachDefense(defenses![3], inMatchPerformance: standsScoutingController.matchPerformance!)
		}
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
