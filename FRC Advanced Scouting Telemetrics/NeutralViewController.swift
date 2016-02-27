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
	let stopwatch = Stopwatch()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		standsScoutingController = parentViewController as! StandsScoutingViewController
		//Get the defenses
		defenses = standsScoutingController.matchPerformance?.match?.defenses?.allObjects as? [Defense]
		
		//Set up all the buttons
		lowBarButton.imageView?.contentMode = .ScaleAspectFit
		defense4Button.imageView?.contentMode = .ScaleAspectFit
		defense3Button.imageView?.contentMode = .ScaleAspectFit
		defense2Button.imageView?.contentMode = .ScaleAspectFit
		defense1Button.imageView?.contentMode = .ScaleAspectFit
		
		//Set the buttons with the defenses images
		defense4Button.setImage(UIImage(named: defenses![0].defenseName!), forState: .Normal)
		defense3Button.setImage(UIImage(named: defenses![1].defenseName!), forState: .Normal)
		defense2Button.setImage(UIImage(named: defenses![2].defenseName!), forState: .Normal)
		defense1Button.setImage(UIImage(named: defenses![3].defenseName!), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func startedHoldingDownDefense(sender: UIButton) {
		stopwatch.start()
		NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
	}
	
	@IBAction func stoppedHoldingDefense(sender: UIButton) {
		stopwatch.stop()
		
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
		
		dataManager.addDefenseCrossTime(forMatchPerformance: standsScoutingController.matchPerformance!, inDefense: defense, withTime: stopwatch.elapsedTime)
	}
	
	func updateTimeLabel(sender: NSTimer) {
		if stopwatch.isRunning {
			elapsedTimeLabel.text = stopwatch.elapsedTimeAsString
		} else {
			sender.invalidate()
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
