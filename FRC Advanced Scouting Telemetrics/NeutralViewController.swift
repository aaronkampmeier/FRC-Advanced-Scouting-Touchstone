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
		standsScoutingController = parent as! StandsScoutingViewController
		//Get the defenses
		defenses = standsScoutingController.defenses
		
		//Set up all the buttons
		lowBarButton.imageView?.contentMode = .scaleAspectFit
		defense4Button.imageView?.contentMode = .scaleAspectFit
		defense3Button.imageView?.contentMode = .scaleAspectFit
		defense2Button.imageView?.contentMode = .scaleAspectFit
		defense1Button.imageView?.contentMode = .scaleAspectFit
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if defenses?.count == 4 {
			//Set the buttons with the defenses images
			defense4Button.setImage(UIImage(named: defenses![0].description), for: UIControlState())
			defense3Button.setImage(UIImage(named: defenses![1].description), for: UIControlState())
			defense2Button.setImage(UIImage(named: defenses![2].description), for: UIControlState())
			defense1Button.setImage(UIImage(named: defenses![3].description), for: UIControlState())
		} else {
			let alert = UIAlertController(title: "No Defenses", message: "There are no defenses set for this match. You must set some in the admin console before tracking neutral times.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func defensePressed(_ sender: UIButton) {
		let defense: Defense!
		switch sender {
		case lowBarButton:
			defense = Defense.LowBar
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
		
		dataManager.addDefenseCrossTime(forMatchPerformance: standsScoutingController.matchPerformance!, inDefense: defense, atTime: standsScoutingController.stopwatch.elapsedTime)
		dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.crossedDefense, atTime: standsScoutingController.stopwatch.elapsedTime, inMatchPerformance: standsScoutingController.matchPerformance!)
		
		//Switch to the offense courtyard
		standsScoutingController.segmentedControl.selectedSegmentIndex = 1
		standsScoutingController.selectedNewPart(standsScoutingController.segmentedControl)
	}
	
	@IBAction func breachedLowBar(_ sender: UISwitch) {
		switch sender.isOn {
		case true:
			dataManager.setDefense(Defense.LowBar, state: TeamDataManager.DefenseState.breached, inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDefense(Defense.LowBar, state: TeamDataManager.DefenseState.notBreached, inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense4(_ sender: UISwitch) {
		switch sender.isOn {
		case true:
			dataManager.setDefense(defenses![0], state: TeamDataManager.DefenseState.breached, inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDefense(defenses![0], state: TeamDataManager.DefenseState.notBreached, inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense3(_ sender: UISwitch) {
		switch sender.isOn {
		case true:
			dataManager.setDefense(defenses![1], state: TeamDataManager.DefenseState.breached, inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDefense(defenses![1], state: TeamDataManager.DefenseState.notBreached, inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense2(_ sender: UISwitch) {
		switch sender.isOn {
		case true:
			dataManager.setDefense(defenses![2], state: TeamDataManager.DefenseState.breached, inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDefense(defenses![2], state: TeamDataManager.DefenseState.notBreached, inMatchPerformance: standsScoutingController.matchPerformance!)
		}
	}
	@IBAction func breachedDefense1(_ sender: UISwitch) {
		switch sender.isOn {
		case true:
			dataManager.setDefense(defenses![3], state: TeamDataManager.DefenseState.breached, inMatchPerformance: standsScoutingController.matchPerformance!)
		case false:
			dataManager.setDefense(defenses![3], state: TeamDataManager.DefenseState.notBreached, inMatchPerformance: standsScoutingController.matchPerformance!)
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
