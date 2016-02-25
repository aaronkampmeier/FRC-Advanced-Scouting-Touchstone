//
//  StandsScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class StandsScoutingViewController: UIViewController {
	@IBOutlet weak var ballButton: UIButton!
	@IBOutlet weak var ballView: UIView!
	@IBOutlet weak var timerButton: UIButton!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var matchAndRegionalLabel: UILabel!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var closeButton: UIButton!
	
	var teamPerformance: TeamRegionalPerformance?
	var matchPerformance: TeamMatchPerformance? {
		willSet {
		matchAndRegionalLabel.text = "Regional: \(teamPerformance!.regional!.name!)  Match: \(newValue!.match!.matchNumber!)"
		defenses = newValue?.match?.defenses?.allObjects as? [Defense]
		}
	}
	var defenses: [Defense]?
	let dataManager = TeamDataManager()
	
	let stopwatch = Stopwatch()
	var isRunning = false {
		willSet {
		if newValue {
			NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
			stopwatch.start()
			
			//Update the button
			timerButton.setTitle("Stop", forState: .Normal)
			timerButton.backgroundColor = UIColor.redColor()
			
			//Set appropriate state for elements in the view
			ballButton.enabled = true
			closeButton.hidden = true
		} else {
			stopwatch.stop()
			
			//Update the button
			timerButton.setTitle("Start", forState: .Normal)
			timerButton.backgroundColor = UIColor.greenColor()
			
			//Set appropriate state for elements in the view
			ballButton.enabled = false
			closeButton.hidden = false
		}
		}
	}
	
	var currentDetailViewController: StandsScoutingDetailProtocol?
	var currentVC: UIViewController?
	var autonomousVC: AutonomousViewController?
	var defenseVC: CourtyardViewController?
	var offenseVC: CourtyardViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamLabel.text = "Team \(teamPerformance!.team!.teamNumber!)"
		
		//Get all the view controllers
		autonomousVC = storyboard?.instantiateViewControllerWithIdentifier("standsAutonomous") as? AutonomousViewController
		defenseVC = storyboard?.instantiateViewControllerWithIdentifier("standsCourtyard") as? CourtyardViewController
		offenseVC = storyboard?.instantiateViewControllerWithIdentifier("standsCourtyard") as? CourtyardViewController
		
		//Set the type for each courtyard view controller
		defenseVC?.defenseOrOffense = .Defense
		offenseVC?.defenseOrOffense = .Offense
		
		//Make it look nice
		timerButton.layer.cornerRadius = 10
		ballView.layer.borderWidth = 4
		ballView.layer.cornerRadius = 5
		ballView.layer.borderColor = UIColor.grayColor().CGColor
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = UIBezierPath(roundedRect: ballView.frame, byRoundingCorners: .TopLeft, cornerRadii: CGSize(width: 3, height: 3)).CGPath
		//ballView.layer.mask = shapeLayer
		
		closeButton.layer.cornerRadius = 10
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//Ask for the match to use
		let askAction = UIAlertController(title: "Select Match", message: "Select the match for team \(teamPerformance!.team!.teamNumber!) in the regional \(teamPerformance!.regional!.name!) for stands scouting.", preferredStyle: .Alert)
		for match in (teamPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]) {
			askAction.addAction(UIAlertAction(title: "Match \(match.match!.matchNumber!)", style: .Default, handler: {_ in self.matchPerformance = match; /*Initially go to autonomous*/ let initialChild = self.childViewControllers.first; self.cycleFromViewController(initialChild!, toViewController: self.autonomousVC!)}))
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
	
	@IBAction func closePressed(sender: UIButton) {
		if 150 - stopwatch.elapsedTime > 5 {
			let alert = UIAlertController(title: "Hold On, You're Not Finished", message: "It doesn't look like you've completed a full 2 minute 30 second match. Are you sure you want to close with this partial data?", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "No, don't close", style: .Cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "Yes, close and save final data", style: .Default, handler: {_ in self.close(andSave: true)}))
			alert.addAction(UIAlertAction(title: "Yes, close but don't save final data", style: .Destructive, handler: {_ in self.close(andSave: false)}))
			presentViewController(alert, animated: true, completion: nil)
		} else {
			close(andSave: true)
		}
	}
	
	func close(andSave shouldSave: Bool) {
		if shouldSave {
			dataManager.save()
		}
		
		dismissViewControllerAnimated(true, completion: nil)
	}
    
	@IBAction func selectedNewPart(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			cycleFromViewController(currentVC!, toViewController: autonomousVC!)
		case 1:
			cycleFromViewController(currentVC!, toViewController: offenseVC!)
			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.MovedToOffenseCourtyard, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
		case 2:
			break
		case 3:
			cycleFromViewController(currentVC!, toViewController: defenseVC!)
			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.MovedToDefenseCourtyard, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
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
		isRunning = !isRunning
	}
	
	func updateTimeLabel(timer: NSTimer) {
		if stopwatch.isRunning {
			timerLabel.text = stopwatch.elapsedTimeAsString
			
			if stopwatch.elapsedTime > 160 {
				isRunning = false
				let alert = UIAlertController(title: "Too Long", message: "The match should have ended at 2 minutes 30 seconds; the timer has already passed that and automatically stopped. All data will be saved unless timer is started again.", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
				presentViewController(alert, animated: true, completion: nil)
			}
		} else {
			timer.invalidate()
		}
	}

	@IBAction func gotBallPressed(sender: UIButton) {
		dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.BallPickedUp, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
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
