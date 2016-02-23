//
//  StandsScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class StandsScoutingViewController: UIViewController {
	@IBOutlet weak var ballView: UIView!
	@IBOutlet weak var timerButton: UIButton!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var matchAndRegionalLabel: UILabel!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	var teamPerformance: TeamRegionalPerformance?
	var matchPerformance: TeamMatchPerformance? {
		willSet {
		matchAndRegionalLabel.text = "Regional: \(teamPerformance!.regional!.name!)  Match: \(newValue!.match!.matchNumber!)"
		}
	}
	
	let stopwatch = Stopwatch()
	
	var currentDetailViewController: StandsScoutingDetailProtocol?
	var currentVC: UIViewController?
	var autonomousVC: AutonomousViewController?
	var defenseVC: DefenseViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamLabel.text = "Team \(teamPerformance!.team!.teamNumber!)"
		
		//Get all the view controllers
		autonomousVC = storyboard?.instantiateViewControllerWithIdentifier("standsAutonomous") as? AutonomousViewController
		defenseVC = storyboard?.instantiateViewControllerWithIdentifier("standsDefense") as? DefenseViewController
		
		//Make it look nice
		timerButton.layer.cornerRadius = 10
		ballView.layer.borderWidth = 4
		ballView.layer.cornerRadius = 3
		ballView.layer.borderColor = UIColor.grayColor().CGColor
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = UIBezierPath(roundedRect: ballView.frame, byRoundingCorners: .TopLeft, cornerRadii: CGSize(width: 3, height: 3)).CGPath
		//ballView.layer.mask = shapeLayer
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//Ask for the match to use
		let askAction = UIAlertController(title: "Select Match", message: "Select the match for team \(teamPerformance!.team!.teamNumber!) in the regional \(teamPerformance!.regional!.name!) for stands scouting.", preferredStyle: .Alert)
		for match in (teamPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]) {
			askAction.addAction(UIAlertAction(title: "Match \(match.match!.matchNumber!)", style: .Default, handler: {(alert: UIAlertAction) in self.matchPerformance = match; /*Initially go to autonomous*/ let initialChild = self.childViewControllers.first; self.cycleFromViewController(initialChild!, toViewController: self.autonomousVC!)}))
		}
		presentViewController(askAction, animated: true, completion: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func selectedNewPart(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			cycleFromViewController(currentVC!, toViewController: autonomousVC!)
		case 1:
			break
		case 2:
			break
		case 3:
			cycleFromViewController(currentVC!, toViewController: defenseVC!)
		default:
			break
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
	}
	
	func cycleFromViewController(oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMoveToParentViewController(nil)
		addChildViewController(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transitionFromViewController(oldVC, toViewController: newVC, duration: 0, options: .TransitionNone, animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMoveToParentViewController(self); self.currentVC = newVC})
	}
	
	//Timer
	@IBAction func timerButtonTapped(sender: UIButton) {
		if !stopwatch.isRunning {
			NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
			stopwatch.start()
			
			//Update the button
			sender.setTitle("Stop", forState: .Normal)
			sender.backgroundColor = UIColor.redColor()
		} else {
			stopwatch.stop()
			
			//Update the button
			sender.setTitle("Start", forState: .Normal)
			sender.backgroundColor = UIColor.greenColor()
		}
	}
	
	func updateTimeLabel(timer: NSTimer) {
		if stopwatch.isRunning {
			timerLabel.text = stopwatch.elapsedTimeAsString
		} else {
			timer.invalidate()
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

protocol StandsScoutingDetailProtocol {
}
