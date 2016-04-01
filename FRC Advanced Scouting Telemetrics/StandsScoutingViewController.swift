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
	@IBOutlet weak var finalTowerView: UIView!
	@IBOutlet weak var challengedTowerSwitch: UISwitch!
	@IBOutlet weak var scaledTowerSwitch: UISwitch!
	@IBOutlet weak var notesButton: UIButton!
	
	var teamPerformance: TeamRegionalPerformance?
	var matchPerformance: TeamMatchPerformance? {
		willSet {
		matchAndRegionalLabel.text = "Regional: \(teamPerformance!.regional!.name!)  Match: \(newValue!.match!.matchNumber!)"
		switch newValue!.allianceColor!.integerValue {
		case 0:
			defenses = newValue?.match?.blueDefenses?.allObjects as? [Defense]
		case 1:
			defenses = newValue?.match?.redDefenses?.allObjects as? [Defense]
		default:
			break
		}
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
			
			//Reset previous data
			dataManager.discardChanges()
			
			//Update the button
			timerButton.setTitle("Stop", forState: .Normal)
			timerButton.backgroundColor = UIColor.redColor()
			
			//Set appropriate state for elements in the view
			ballButton.enabled = true
			closeButton.hidden = true
			
			//Let the user now select new segments
			segmentedControl.enabled = true
			
			//Go to autonomous
			cycleFromViewController(currentVC!, toViewController: autonomousVC!)
		} else {
			stopwatch.stop()
			
			//Update the button
			timerButton.setTitle("Start", forState: .Normal)
			timerButton.backgroundColor = UIColor.greenColor()
			
			//Set appropriate state for elements in the view
			ballButton.enabled = false
			closeButton.hidden = false
			
			//Turn off ability to select new segments
			segmentedControl.enabled = false
			
			//Go back to the initial screen
			cycleFromViewController(currentVC!, toViewController: initialChild!)
			segmentedControl.selectedSegmentIndex = 0
			selectedNewPart(segmentedControl)
			
			//Ask for the final score if it lasted longer than 2:15
			if stopwatch.elapsedTime >= 135 {
				finalScorePrompt = UIAlertController(title: "Final Scores", message: "Enter the final score for the alliance your team was on.", preferredStyle: .Alert)
				finalScorePrompt.addTextFieldWithConfigurationHandler() {
					self.configureTextField($0, label: 0)
				}
				finalScorePrompt.addTextFieldWithConfigurationHandler() {
					self.configureTextField($0, label: 1)
				}
				finalScorePrompt.addTextFieldWithConfigurationHandler() {
					self.configureTextField($0, label: 2)
				}
				finalScorePrompt.addTextFieldWithConfigurationHandler() {
					self.configureTextField($0, label: 3)
				}
				finalScorePrompt.addAction(UIAlertAction(title: "Save", style: .Default, handler: getFinalScore))
				presentViewController(finalScorePrompt, animated: true, completion: nil)
			}
		}
		}
	}
	var finalScorePrompt: UIAlertController!
	func configureTextField(textField: UITextField, label: Int) {
		textField.keyboardType = .NumberPad
		
		switch label {
		case 0:
			textField.placeholder = "Red Final Score"
		case 1:
			textField.placeholder = "Red Ranking Points"
		case 2:
			textField.placeholder = "Blue Final Score"
		case 3:
			textField.placeholder = "Blue Ranking Points"
		default:
			break
		}
	}
	func getFinalScore(action: UIAlertAction) {
		for textField in finalScorePrompt.textFields! {
			switch textField {
			case finalScorePrompt.textFields![0]:
				//Red Final Score
				matchPerformance?.match?.redFinalScore = Double(textField.text!)
			case finalScorePrompt.textFields![1]:
				//Red Ranking Points
				matchPerformance?.match?.redRankingPoints = Double(textField.text!)
			case finalScorePrompt.textFields![2]:
				//Blue Final Score
				matchPerformance?.match?.blueFinalScore = Double(textField.text!)
			case finalScorePrompt.textFields![3]:
				//Blue Ranking Points
				matchPerformance?.match?.blueRankingPoints = Double(textField.text!)
			default:
				break
			}
		}
	}
	
	var currentVC: UIViewController?
	var initialChild: UIViewController?
	var autonomousVC: AutonomousViewController?
	var defenseVC: UIViewController?
	var offenseVC: CourtyardViewController?
	var neutralVC: NeutralViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamLabel.text = "Team \(teamPerformance!.team!.teamNumber!)"
		
		//Get all the view controllers
		autonomousVC = storyboard?.instantiateViewControllerWithIdentifier("standsAutonomous") as? AutonomousViewController
		defenseVC = storyboard?.instantiateViewControllerWithIdentifier("standsDefense")
		offenseVC = storyboard?.instantiateViewControllerWithIdentifier("standsCourtyard") as? CourtyardViewController
		neutralVC = storyboard?.instantiateViewControllerWithIdentifier("standsNeutral") as? NeutralViewController
		
		//Set the type for the courtyard view controller
		offenseVC?.defenseOrOffense = .Offense
		
		//Make it look nice
		timerButton.layer.cornerRadius = 10
		ballView.layer.borderWidth = 4
		ballView.layer.cornerRadius = 5
		ballView.layer.borderColor = UIColor.grayColor().CGColor
		finalTowerView.layer.borderWidth = 4
		finalTowerView.layer.cornerRadius = 5
		finalTowerView.layer.borderColor = UIColor.grayColor().CGColor
		closeButton.layer.cornerRadius = 10
		notesButton.layer.cornerRadius = 10
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if matchPerformance == nil {
			//Ask for the match to use
			let askAction = UIAlertController(title: "Select Match", message: "Select the match for Team \(teamPerformance!.team!.teamNumber!) in the regional \(teamPerformance!.regional!.name!) for stands scouting.", preferredStyle: .Alert)
			for match in (teamPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]).sort({Int($0.match!.matchNumber!) < Int($1.match!.matchNumber!)}) {
				askAction.addAction(UIAlertAction(title: "Match \(match.match!.matchNumber!)", style: .Default, handler: {_ in self.matchPerformance = match}))
			}
			presentViewController(askAction, animated: true, completion: nil)
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		initialChild = childViewControllers.first
		currentVC = initialChild
		
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
			dataManager.commitChanges()
		} else {
			dataManager.discardChanges()
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
			cycleFromViewController(currentVC!, toViewController: neutralVC!)
			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.MovedToNeutral, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
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
				let alert = UIAlertController(title: "Too Long", message: "The match should have ended at 2 minutes 30 seconds; the timer has already passed that and automatically stopped. All data will be saved unless the timer is started again.", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
				presentViewController(alert, animated: true, completion: nil)
			} else if stopwatch.elapsedTime > 135 {
				//Show the final tower settings
				finalTowerView.hidden = false
				
				//Change the color of the start/stop button to be blue signifying it is safe to stop it
				timerButton.backgroundColor = UIColor.blueColor()
			}
		} else {
			timer.invalidate()
		}
	}

	@IBAction func gotBallPressed(sender: UIButton) {
		dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEvent.BallPickedUp, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
	}
	
	//FINAL TOWER VIEW
	@IBAction func challengedTowerSwitched(sender: UISwitch) {
		matchPerformance?.didChallengeTower = sender.on
	}
	
	@IBAction func scaledTowerSwitched(sender: UISwitch) {
		matchPerformance?.didScaleTower = sender.on
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func returnToStandsScouting(segue: UIStoryboardSegue) {
		
	}

	var notesVC: NotesViewController?
	@IBAction func notesButtonPressed(sender: UIButton) {
		if notesVC == nil {
			notesVC = storyboard?.instantiateViewControllerWithIdentifier("notesVC") as! NotesViewController
		}
		
		notesVC?.standsScoutingVC = self
		
		notesVC?.modalPresentationStyle = .Popover
		let popoverController = notesVC?.popoverPresentationController
		popoverController?.permittedArrowDirections = .Any
		popoverController?.sourceView = sender
		notesVC?.preferredContentSize = CGSize(width: 400, height: 600)
		presentViewController(notesVC!, animated: true, completion: nil)
	}
}

class NotesViewController: UIViewController {
	@IBOutlet weak var notesTextView: UITextView!
	
	var standsScoutingVC: StandsScoutingViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		notesTextView.layer.cornerRadius = 5
		notesTextView.layer.borderWidth = 3
		notesTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		notesTextView.text = standsScoutingVC.matchPerformance?.regionalPerformance?.team?.notes
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		standsScoutingVC.matchPerformance?.regionalPerformance?.team?.notes = notesTextView.text
	}
}
