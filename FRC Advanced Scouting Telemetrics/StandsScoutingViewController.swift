//
//  StandsScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/13/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class StandsScoutingViewController: UIViewController, ProvidesTeam {
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
		}
	}
	var team: Team {
		return teamPerformance!.team!
	}
	var defenses: [Defense]? {
		get {
			switch matchPerformance!.allianceColor!.integerValue {
			case 0:
				return matchPerformance?.match?.blueDefenses?.allObjects as! [Defense]
			case 1:
				return matchPerformance?.match?.redDefenses?.allObjects as! [Defense]
			default:
				return [Defense]()
			}
		}
	}
	let dataManager = TeamDataManager()
	
	let stopwatch = Stopwatch()
	var isRunning = false {
		willSet {
		if newValue {
			NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
			stopwatch.start()
			
			//Reset previous data
			//dataManager.discardChanges()
			
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
		
		setUpStandsScouting()
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
	
	func setUpStandsScouting() {
		let defenseSelectorVC = storyboard?.instantiateViewControllerWithIdentifier("defenseSelector") as! DefenseSelector
		defenseSelectorVC.standsScoutingVC = self
		
		if matchPerformance == nil {
			//Ask for the match to use
			let askAction = UIAlertController(title: "Select Match", message: "Select the match for Team \(teamPerformance!.team!.teamNumber!) in the regional \(teamPerformance!.regional!.name!) for stands scouting.", preferredStyle: .Alert)
			for match in (teamPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]).sort({Int($0.match!.matchNumber!) < Int($1.match!.matchNumber!)}) {
				askAction.addAction(UIAlertAction(title: "Match \(match.match!.matchNumber!)", style: .Default, handler: {_ in self.matchPerformance = match; self.presentViewController(defenseSelectorVC, animated: true, completion: nil); defenseSelectorVC.loadDefenses(forMatch: match.match!)}))
			}
			
			askAction.addAction(UIAlertAction(title: "Cancel", style: .Destructive) {action in
				self.close(andSave: false)
			})
			presentViewController(askAction, animated: true, completion: nil)
		} else {
			defenseSelectorVC.loadDefenses(forMatch: matchPerformance!.match!)
			presentViewController(defenseSelectorVC, animated: true, completion: nil)
		}
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
		
		notesVC?.originatingView = self
		
		notesVC?.modalPresentationStyle = .Popover
		let popoverController = notesVC?.popoverPresentationController
		popoverController?.permittedArrowDirections = .Any
		popoverController?.sourceView = sender
		notesVC?.preferredContentSize = CGSize(width: 400, height: 600)
		presentViewController(notesVC!, animated: true, completion: nil)
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
		notesTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		notesTextView.text = originatingView.team.notes
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		originatingView.team.notes = notesTextView.text
	}
	
	@IBAction func donePressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

class DefenseSelector: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var defenseCollectionView: UICollectionView!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	let dataManager = TeamDataManager()
	var standsScoutingVC: StandsScoutingViewController?
	
	var redDefenses: [TeamDataManager.DefenseCategory:Defense] = Dictionary<TeamDataManager.DefenseCategory, Defense>() {
		didSet {
			if redDefenses.count == 4 && blueDefenses.count == 4 {
				doneButton.enabled = true
			} else {
				doneButton.enabled = false
			}
		}
	}
	var blueDefenses: [TeamDataManager.DefenseCategory:Defense] = Dictionary<TeamDataManager.DefenseCategory, Defense>() {
		didSet {
			if redDefenses.count == 4 && blueDefenses.count == 4 {
				doneButton.enabled = true
			} else {
				doneButton.enabled = false
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		doneButton.enabled = false
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		for cell in defenseCollectionView.visibleCells() as! [DefenseSelectionCell] {
			switch cell.color! {
			case .Red:
				cell.defenseSelection = redDefenses[cell.defenseCategory!]?.defenseType
			case .Blue:
				cell.defenseSelection = blueDefenses[cell.defenseCategory!]?.defenseType
			}
		}
	}
	
	@IBAction func cancelPressed(sender: UIBarButtonItem) {
		dismissViewControllerAnimated(true, completion: nil)
		standsScoutingVC?.close(andSave: false)
	}
	
	func loadDefenses(forMatch match: Match) {
		for defense in (match.redDefenses?.allObjects as! [Defense]) {
			redDefenses[defense.defenseCategory] = defense
		}
		for defense in (match.blueDefenses?.allObjects as! [Defense]) {
			blueDefenses[defense.defenseCategory] = defense
		}
		defenseCollectionView.reloadData()
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 2
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DefenseSelectionCell
		
		cell.defenseSelector = self
		cell.defenseCategory = TeamDataManager.DefenseCategory(rawValue: indexPath.item)
		if indexPath.section == 0 {
			cell.color = TeamDataManager.AllianceColor.Red
		} else {
			cell.color = TeamDataManager.AllianceColor.Blue
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		switch kind {
		case UICollectionElementKindSectionHeader:
			let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath)
			let titleLabel = header.viewWithTag(1) as! UILabel
			if indexPath.section == 0 {
				titleLabel.text = "Red Defenses"
				titleLabel.textColor = UIColor.redColor()
			} else {
				titleLabel.text = "Blue Defenses"
				titleLabel.textColor = UIColor.blueColor()
			}
			return header
		default:
			assertionFailure("Unknown supplementary view identifier.")
			fatalError()
		}
	}
	
	func didSelectDefense(color: TeamDataManager.AllianceColor, defense: TeamDataManager.DefenseType) {
		switch color {
		case .Red:
			redDefenses[defense.category] = defense.defense
		case .Blue:
			blueDefenses[defense.category] = defense.defense
		}
	}
	
	@IBAction func donePressed(sender: UIBarButtonItem) {
		standsScoutingVC?.matchPerformance?.match?.redDefenses = NSSet(array: Array(redDefenses.values))
		standsScoutingVC?.matchPerformance?.match?.blueDefenses = NSSet(array: Array(blueDefenses.values))
		dataManager.commitChanges()
		dismissViewControllerAnimated(true, completion: nil)
	}
}

class DefenseSelectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var tableView: UITableView!
	
	var color: TeamDataManager.AllianceColor?
	var defenseCategory: TeamDataManager.DefenseCategory? {
		didSet {
			tableView.reloadData()
		}
	}
	var defenseSelection: TeamDataManager.DefenseType? {
		didSet {
			if let defenseSelection = defenseSelection {
				tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: defenseCategory!.defenses.indexOf(defenseSelection) ?? 2, inSection: 0), animated: false, scrollPosition: .None)
			} else {
				if let selectedPath = tableView.indexPathForSelectedRow {
					tableView.deselectRowAtIndexPath(selectedPath, animated: false)
				}
			}
		}
	}
	var defenseSelector: DefenseSelector?
	
	override func layoutSubviews() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell")
		
		cell?.textLabel?.text = defenseCategory?.defenses[indexPath.row].description ?? ""
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		defenseSelector?.didSelectDefense(color!, defense: defenseCategory!.defenses[indexPath.row])
	}
}

