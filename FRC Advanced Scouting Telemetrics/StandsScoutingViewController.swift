//
//  StandsScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

class StandsScoutingViewController: UIViewController, ProvidesTeam {
	@IBOutlet weak var timerButton: UIButton!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var teamLabel: UILabel!
	@IBOutlet weak var matchAndEventLabel: UILabel!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var endAutonomousButton: UIButton!
    @IBOutlet weak var autonomousLabel: UILabel!
	
	var teamEventPerformance: TeamEventPerformance?
	var matchPerformance: TeamMatchPerformance? {
		willSet {
            matchAndEventLabel.text = "\(teamEventPerformance!.event.name!)  \(newValue!.match!.competitionLevel!) \(newValue!.match!.matchNumber!)"
            ssDataManager = SSDataManager(teamBeingScouted: team, matchBeingScouted: newValue!.match!, stopwatch: stopwatch)
            
            //Ask for where the robot is starting
//            let startingPositionHandler: (UIAlertAction) -> Void = {alertAction in
//                let position = StartingPosition(rawValue: alertAction.title!)
//                self.ssDataManager.startingPosition = position
//            }
//            
//            let alert = UIAlertController(title: "Starting Location", message: "In what position is the robot starting?", preferredStyle: .alert)
//            for position in StartingPosition.allPositions {
//                alert.addAction(UIAlertAction(title: position.description, style: .default, handler: startingPositionHandler))
//            }
//            present(alert, animated: true, completion: nil)
		}
	}
	var team: Team {
		return teamEventPerformance!.team
	}
	let dataManager = DataManager()
    var ssDataManager: SSDataManager!
	
	let stopwatch = Stopwatch()
	var isRunning = false {
		willSet {
		if newValue {
			Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StandsScoutingViewController.updateTimeLabel(_:)), userInfo: nil, repeats: true)
			stopwatch.start()
			
			//Reset previous data
			ssDataManager.rollback()
			
			//Update the button
			timerButton.setTitle("Stop", for: UIControlState())
			timerButton.backgroundColor = UIColor.red
			
			//Set appropriate state for elements in the view
			closeButton.isHidden = true
			
			//Let the user now select new segments
			segmentedControl.isEnabled = true
            
            cycleFromViewController(currentVC!, toViewController: offenseVC!)
            
            endAutonomousButton.isHidden = false
            autonomousLabel.isHidden = false
		} else {
            stopwatch.stop()
            
            //Update the button
            timerButton.setTitle("Ended", for: UIControlState())
            timerButton.backgroundColor = UIColor.gray
            timerButton.isEnabled = false
            
            //Set appropriate state for elements in the view
            closeButton.isHidden = false
            
            //Turn off ability to select new segments
            segmentedControl.isEnabled = false
            
            //Go back to the initial screen
            cycleFromViewController(currentVC!, toViewController: initialChild!)
            segmentedControl.selectedSegmentIndex = 0
            
            //Ask for the final score if it lasted longer than 2:15
            if stopwatch.elapsedTime >= 135 {
                finalScorePrompt = UIAlertController(title: "Final Scores", message: "Enter the final score for the alliances.", preferredStyle: .alert)
                finalScorePrompt.addTextField() {
                    self.configureTextField($0, label: 0)
                }
                finalScorePrompt.addTextField() {
                    self.configureTextField($0, label: 1)
                }
                finalScorePrompt.addTextField() {
                    self.configureTextField($0, label: 2)
                }
                finalScorePrompt.addTextField() {
                    self.configureTextField($0, label: 3)
                }
                finalScorePrompt.addAction(UIAlertAction(title: "Save", style: .default, handler: getFinalScore))
                present(finalScorePrompt, animated: true, completion: nil)
            }
            
            Answers.logCustomEvent(withName: "Stopped Stands Scouting Timer", customAttributes: ["At Time":stopwatch.elapsedTimeAsString])
            
            endAutonomousButton.isHidden = true
            autonomousLabel.isHidden = true
        }
        }
	}
	var finalScorePrompt: UIAlertController!
	func configureTextField(_ textField: UITextField, label: Int) {
		textField.keyboardType = .numberPad
		
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
	func getFinalScore(_ action: UIAlertAction) {
		for textField in finalScorePrompt.textFields! {
			switch textField {
			case finalScorePrompt.textFields![0]:
				//Red Final Score
//				matchPerformance?.match?.redFinalScore = Double(textField.text!) as NSNumber?
                break
			case finalScorePrompt.textFields![1]:
				//Red Ranking Points
//				matchPerformance?.match?.redRankingPoints = Double(textField.text!) as NSNumber?
                break
			case finalScorePrompt.textFields![2]:
				//Blue Final Score
//				matchPerformance?.match?.blueFinalScore = Double(textField.text!) as NSNumber?
                break
			case finalScorePrompt.textFields![3]:
				//Blue Ranking Points
//				matchPerformance?.match?.blueRankingPoints = Double(textField.text!) as NSNumber?
                break
			default:
				break
			}
		}
	}
	
    //Child view controllers
	var currentVC: UIViewController?
	var initialChild: UIViewController?
    var offenseVC: SSOffenseViewController?
    var defenseVC: SSDefenseViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamLabel.text = "Team \(teamEventPerformance!.team.teamNumber!)"
		
		//Get all the view controllers
        offenseVC = (storyboard?.instantiateViewController(withIdentifier: "SSOffense") as! SSOffenseViewController)
        defenseVC = (storyboard?.instantiateViewController(withIdentifier: "ssDefense") as! SSDefenseViewController)
		
		//Make it look nice
		timerButton.layer.cornerRadius = 10
		closeButton.layer.cornerRadius = 10
		notesButton.layer.cornerRadius = 10
        
        autonomousLabel.layer.cornerRadius = 5
        endAutonomousButton.layer.cornerRadius = 10
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setUpStandsScouting()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		initialChild = childViewControllers.first
		currentVC = initialChild
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setUpStandsScouting() {
		if matchPerformance == nil {
			//Ask for the match to use
			let askAction = UIAlertController(title: "Select Match", message: "Select the match for Team \(teamEventPerformance!.team.teamNumber!) in the event \(teamEventPerformance!.event.name!) for stands scouting.", preferredStyle: .alert)
            let sortedMatchPerformances = (teamEventPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]).sorted() {(firstMatchPerformance, secondMatchPerformance) in
                if firstMatchPerformance.match!.competitionLevelEnum.rankedPosition > secondMatchPerformance.match!.competitionLevelEnum.rankedPosition {
                    return true
                } else if firstMatchPerformance.match!.competitionLevelEnum.rankedPosition == secondMatchPerformance.match!.competitionLevelEnum.rankedPosition {
                    return firstMatchPerformance.match!.matchNumber!.intValue < secondMatchPerformance.match!.matchNumber!.intValue
                } else {
                    return false
                }
            }
			for match in sortedMatchPerformances {
				askAction.addAction(UIAlertAction(title: "\(match.match!.competitionLevel!) \(match.match!.matchNumber!)", style: .default, handler: {_ in
                    self.matchPerformance = match
                }))
			}
			
			askAction.addAction(UIAlertAction(title: "Cancel", style: .destructive) {action in
				self.close(andSave: false)
			})
			present(askAction, animated: true, completion: nil)
		}
	}
	
	@IBAction func closePressed(_ sender: UIButton) {
		if 150 - stopwatch.elapsedTime > 15 {
			let alert = UIAlertController(title: "Hold On, You're Not Finished", message: "It doesn't look like you've completed a full 2 minute 30 second match. Are you sure you want to close with this partial data?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "No, don't close", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "Yes, close and save final data", style: .default, handler: {_ in self.close(andSave: true)}))
			alert.addAction(UIAlertAction(title: "Yes, close but don't save final data", style: .destructive, handler: {_ in self.close(andSave: false)}))
			present(alert, animated: true, completion: nil)
		} else {
			close(andSave: true)
		}
	}
	
	func close(andSave shouldSave: Bool) {
		if shouldSave {
            if !ssDataManager.save() {
                //There was a problem saving
                let alert = UIAlertController(title: "Unable to save", message: "There was a problem saving the scouted data. This is problematic and rare; please file a bug report.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
		} else {
			ssDataManager.rollback()
		}
		
		dismiss(animated: true, completion: nil)
		Answers.logCustomEvent(withName: "Closed Stands Scouting", customAttributes: ["With Save":shouldSave.description])
	}
    
	@IBAction func selectedNewPart(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			cycleFromViewController(currentVC!, toViewController: offenseVC!)
		case 1:
            cycleFromViewController(currentVC!, toViewController: defenseVC!)
		default:
			break
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
	}
	
	func cycleFromViewController(_ oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMove(toParentViewController: nil)
		addChildViewController(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transition(from: oldVC, to: newVC, duration: 0, options: UIViewAnimationOptions(), animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMove(toParentViewController: self); self.currentVC = newVC})
	}
	
	//Timer
	@IBAction func timerButtonTapped(_ sender: UIButton) {
		isRunning = !isRunning
	}
	
	func updateTimeLabel(_ timer: Timer) {
		if stopwatch.isRunning {
			timerLabel.text = stopwatch.elapsedTimeAsString
			
			if stopwatch.elapsedTime > 160 {
				isRunning = false
				let alert = UIAlertController(title: "Too Long", message: "The match should have ended at 2 minutes 30 seconds; the timer has already passed that and automatically stopped. All data will be saved unless the timer is started again.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(alert, animated: true, completion: nil)
			} else if stopwatch.elapsedTime > 135 {
				//Change the color of the start/stop button to blue signifying that it is safe to stop it.
				timerButton.backgroundColor = UIColor.blue
            }
		} else {
			timer.invalidate()
		}
	}
    
    @IBAction func endAutonomousPressed(_ sender: UIButton) {
        ssDataManager.isAutonomous = false
        endAutonomousButton.isHidden = true
        autonomousLabel.isHidden = true
    }
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func returnToStandsScouting(_ segue: UIStoryboardSegue) {
		
	}

	var notesVC: NotesViewController?
	@IBAction func notesButtonPressed(_ sender: UIButton) {
		if notesVC == nil {
			notesVC = (storyboard?.instantiateViewController(withIdentifier: "notesVC") as! NotesViewController)
		}
		
		notesVC?.originatingView = self
		
		notesVC?.modalPresentationStyle = .popover
		let popoverController = notesVC?.popoverPresentationController
		popoverController?.permittedArrowDirections = .any
		popoverController?.sourceView = sender
		notesVC?.preferredContentSize = CGSize(width: 400, height: 600)
		present(notesVC!, animated: true, completion: nil)
	}
}

protocol ProvidesTeam {
	var team: Team {get}
}

class NotesViewController: UIViewController {
	@IBOutlet weak var notesTextView: UITextView!
	
	var originatingView: ProvidesTeam!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		notesTextView.layer.cornerRadius = 5
		notesTextView.layer.borderWidth = 3
		notesTextView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
//		notesTextView.text = originatingView.team.notes
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
//		originatingView.team.notes = notesTextView.text
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
}

