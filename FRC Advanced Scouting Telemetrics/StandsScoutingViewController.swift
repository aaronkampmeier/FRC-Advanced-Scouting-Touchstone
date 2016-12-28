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
	
	var teamPerformance: TeamEventPerformance?
	var matchPerformance: TeamMatchPerformance? {
		willSet {
		matchAndEventLabel.text = "Event: \(teamPerformance!.event.name!)  Match: \(newValue!.match!.matchNumber!)"
		}
	}
	var team: Team {
		return teamPerformance!.team
	}
	let dataManager = DataManager()
	
	let stopwatch = Stopwatch()
	var isRunning = false {
		willSet {
		if newValue {
			Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StandsScoutingViewController.updateTimeLabel(_:)), userInfo: nil, repeats: true)
			stopwatch.start()
			
			//Reset previous data
			//dataManager.discardChanges()
			
			//Update the button
			timerButton.setTitle("Stop", for: UIControlState())
			timerButton.backgroundColor = UIColor.red
			
			//Set appropriate state for elements in the view
			closeButton.isHidden = true
			
			//Let the user now select new segments
			segmentedControl.isEnabled = true
		} else {
			stopwatch.stop()
			
			//Update the button
			timerButton.setTitle("Start", for: UIControlState())
			timerButton.backgroundColor = UIColor.green
			
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
	
	var currentVC: UIViewController?
	var initialChild: UIViewController?
	var defenseVC: UIViewController?
	var offenseVC: CourtyardViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		teamLabel.text = "Team \(teamPerformance!.team.teamNumber!)"
		
		//Get all the view controllers
		defenseVC = storyboard?.instantiateViewController(withIdentifier: "standsDefense")
		offenseVC = storyboard?.instantiateViewController(withIdentifier: "standsCourtyard") as? CourtyardViewController
		
		//Make it look nice
		timerButton.layer.cornerRadius = 10
		closeButton.layer.cornerRadius = 10
		notesButton.layer.cornerRadius = 10
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
		let defenseSelectorVC = storyboard?.instantiateViewController(withIdentifier: "defenseSelector") as! DefenseSelector
		defenseSelectorVC.standsScoutingVC = self
		
		if matchPerformance == nil {
			//Ask for the match to use
			let askAction = UIAlertController(title: "Select Match", message: "Select the match for Team \(teamPerformance!.team.teamNumber!) in the event \(teamPerformance!.event.name!) for stands scouting.", preferredStyle: .alert)
			for match in (teamPerformance?.matchPerformances?.allObjects as! [TeamMatchPerformance]).sorted(by: {Int($0.match!.matchNumber!) < Int($1.match!.matchNumber!)}) {
				askAction.addAction(UIAlertAction(title: "Match \(match.match!.matchNumber!)", style: .default, handler: {_ in self.matchPerformance = match; self.present(defenseSelectorVC, animated: true, completion: nil)}))
			}
			
			askAction.addAction(UIAlertAction(title: "Cancel", style: .destructive) {action in
				self.close(andSave: false)
			})
			present(askAction, animated: true, completion: nil)
		} else {
			present(defenseSelectorVC, animated: true, completion: nil)
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
			dataManager.commitChanges()
		} else {
			dataManager.discardChanges()
		}
		
		dismiss(animated: true, completion: nil)
		Answers.logCustomEvent(withName: "Closed Stands Scouting", customAttributes: ["With Save":shouldSave.description])
	}
    
	@IBAction func selectedNewPart(_ sender: UISegmentedControl) {
//		switch sender.selectedSegmentIndex {
//		case 0:
//			cycleFromViewController(currentVC!, toViewController: autonomousVC!)
//		case 1:
//			cycleFromViewController(currentVC!, toViewController: offenseVC!)
////			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.movedToOffenseCourtyard, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
//		case 2:
//			cycleFromViewController(currentVC!, toViewController: neutralVC!)
////			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.movedToNeutral, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
//		case 3:
//			cycleFromViewController(currentVC!, toViewController: defenseVC!)
////			dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.movedToDefenseCourtyard, atTime: stopwatch.elapsedTime, inMatchPerformance: matchPerformance!)
//		default:
//			break
//		}
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
				//Change the color of the start/stop button to be blue signifying it is safe to stop it
				timerButton.backgroundColor = UIColor.blue
			}
		} else {
			timer.invalidate()
		}
	}

	@IBAction func gotBallPressed(_ sender: UIButton) {
		let pickUpTime = stopwatch.elapsedTime
		let locationSelector = UIAlertController(title: "Select Pickup Location", message: "Select where the ball was retrieved from.", preferredStyle: .actionSheet)
		locationSelector.popoverPresentationController?.sourceView = sender
		locationSelector.addAction(UIAlertAction(title: "Offense Courtyard", style: .default) {_ in
//			self.dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.ballPickedUpFromOffense, atTime: pickUpTime, inMatchPerformance: self.matchPerformance!)
			})
		locationSelector.addAction(UIAlertAction(title: "Neutral Zone", style: .default) {_ in
//			self.dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.ballPickedUpFromNeutral, atTime: pickUpTime, inMatchPerformance: self.matchPerformance!)
			})
		locationSelector.addAction(UIAlertAction(title: "Defense Courtyard", style: .default) {_ in
//			self.dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.ballPickedUpFromDefense, atTime: pickUpTime, inMatchPerformance: self.matchPerformance!)
			})
		present(locationSelector, animated: true, completion: nil)
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

class DefenseSelector: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var defenseCollectionView: UICollectionView!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	let dataManager = TeamDataManager()
	var standsScoutingVC: StandsScoutingViewController?
	
	var redDefenses: [DefenseCategory:Defense] = Dictionary<DefenseCategory, Defense>() {
		didSet {
			if redDefenses.count == 4 && blueDefenses.count == 4 {
				doneButton.isEnabled = true
			} else {
				doneButton.isEnabled = false
			}
		}
	}
	var blueDefenses: [DefenseCategory:Defense] = Dictionary<DefenseCategory, Defense>() {
		didSet {
			if redDefenses.count == 4 && blueDefenses.count == 4 {
				doneButton.isEnabled = true
			} else {
				doneButton.isEnabled = false
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		doneButton.isEnabled = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		for cell in defenseCollectionView.visibleCells as! [DefenseSelectionCell] {
			switch cell.color! {
			case .red:
				cell.defenseSelection = redDefenses[cell.defenseCategory!]
			case .blue:
				cell.defenseSelection = blueDefenses[cell.defenseCategory!]
			}
		}
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
		standsScoutingVC?.close(andSave: false)
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DefenseSelectionCell
		
		cell.defenseSelector = self
		cell.defenseCategory = DefenseCategory(rawValue: (indexPath as NSIndexPath).item)
		if (indexPath as NSIndexPath).section == 0 {
			cell.color = TeamDataManager.AllianceColor.red
		} else {
			cell.color = TeamDataManager.AllianceColor.blue
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		switch kind {
		case UICollectionElementKindSectionHeader:
			let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
			let titleLabel = header.viewWithTag(1) as! UILabel
			if (indexPath as NSIndexPath).section == 0 {
				titleLabel.text = "Red Defenses"
				titleLabel.textColor = UIColor.red
			} else {
				titleLabel.text = "Blue Defenses"
				titleLabel.textColor = UIColor.blue
			}
			return header
		default:
			assertionFailure("Unknown supplementary view identifier.")
			fatalError()
		}
	}
	
	func didSelectDefense(_ color: TeamDataManager.AllianceColor, defense: Defense) {
		switch color {
		case .red:
			redDefenses[defense.category] = defense
		case .blue:
			blueDefenses[defense.category] = defense
		}
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
//		do {
//		try dataManager.setDefenses(inMatch: standsScoutingVC!.matchPerformance!.match!, redOrBlue: TeamDataManager.AllianceColor.red, withDefenseArray: Array(redDefenses.values))
//		try dataManager.setDefenses(inMatch: standsScoutingVC!.matchPerformance!.match!, redOrBlue: TeamDataManager.AllianceColor.blue, withDefenseArray: Array(blueDefenses.values))
//		} catch {
//			CLSNSLogv("\(error)", getVaList([]))
//		}
		dataManager.commitChanges()
		dismiss(animated: true, completion: nil)
	}
}

class DefenseSelectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var tableView: UITableView!
	
	var color: TeamDataManager.AllianceColor?
	var defenseCategory: DefenseCategory? {
		didSet {
			tableView.reloadData()
		}
	}
	var defenseSelection: Defense? {
		didSet {
			if let defenseSelection = defenseSelection {
				tableView.selectRow(at: IndexPath.init(row: defenseCategory!.defenses.index(of: defenseSelection) ?? 2, section: 0), animated: false, scrollPosition: .none)
			} else {
				if let selectedPath = tableView.indexPathForSelectedRow {
					tableView.deselectRow(at: selectedPath, animated: false)
				}
			}
		}
	}
	var defenseSelector: DefenseSelector?
	
	override func layoutSubviews() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		
		cell?.textLabel?.text = defenseCategory?.defenses[(indexPath as NSIndexPath).row].description ?? ""
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defenseSelector?.didSelectDefense(color!, defense: defenseCategory!.defenses[(indexPath as NSIndexPath).row])
	}
}

