//
//  TeamListDetailViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import Crashlytics

class TeamListDetailViewController: UIViewController, TeamSelectionDelegate {
	@IBOutlet weak var frontImageButton: UIButton!
	@IBOutlet weak var sideImageButton: UIButton!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var segmentControl2: UISegmentedControl!
	@IBOutlet weak var teamNumberLabel: UILabel!
	@IBOutlet weak var standsScoutingButton: UIBarButtonItem!
	@IBOutlet weak var navBar: UINavigationItem!
	
	var frontImage: TeamImagePhoto? {
		didSet {
			frontImageButton.setImage(frontImage?.image, for: UIControlState())
		}
	}
	
	var sideImage: TeamImagePhoto? {
		didSet {
			sideImageButton.setImage(sideImage?.image, for: UIControlState())
		}
	}

	let teamManager = TeamDataManager()
	var selectedTeam: ObjectPair<Team,LocalTeam>? {
		didSet {
			if let team = selectedTeam {
				navBar.title = team.universal.nickname
				teamNumberLabel.text = team.universal.teamNumber
				
				//Populate the images, if there are images
				if let image = team.local.frontImage {
					frontImage = TeamImagePhoto(image: UIImage(data: image as Data), attributedCaptionTitle: NSAttributedString(string: "Team \(team.universal.teamNumber!): Front Image"))
				} else {
					frontImage = nil
				}
				if let image = team.local.sideImage {
					sideImage = TeamImagePhoto(image: UIImage(data: image as Data), attributedCaptionTitle: NSAttributedString(string: "Team \(team.universal.teamNumber!): Side Image"))
				} else {
					sideImage = nil
				}
				
				if let _ = selectedEvent {
					standsScoutingButton.isEnabled = true
				} else {
					standsScoutingButton.isEnabled = false
				}
			} else {
				
			}
			
			NotificationCenter.default.post(name: Notification.Name(rawValue: "TeamSelectedChanged"), object: self)
		}
	}
	var selectedEvent: Event?
	var teamEventPerformance: TeamEventPerformance? {
		get {
			if let team = selectedTeam {
				if let event = selectedEvent {
					//Get two sets
					let eventPerformances: Set<TeamEventPerformance> = Set(event.teamEventPerformances?.allObjects as! [TeamEventPerformance])
					let teamPerformances = Set(team.universal.eventPerformances?.allObjects as! [TeamEventPerformance])
					
					//Combine the two sets to find the one in both
					let teamEventPerformance = Array(eventPerformances.intersection(teamPerformances)).first!
					
					return teamEventPerformance
				}
			}
			return nil
		}
	}
	
	//Child View Controllers
	var currentChildVC: UIViewController?
	var gameStatsController: GameStatsController?
	var statsViewController: StatsVC?
	var teamDetailVC: UIViewController?
	var matchOverviewVC: MatchOverviewViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading trhe view.
		
		(UIApplication.shared.delegate as! AppDelegate).teamListDetailVC = self
		
		navigationItem.leftItemsSupplementBackButton = true
		
		//Set the stands scouting button to not selectable since there is no team selected
		standsScoutingButton.isEnabled = false
		
		//Get the child view controllers
		gameStatsController = (storyboard?.instantiateViewController(withIdentifier: "gameStatsCollection") as! GameStatsController)
		gameStatsController?.dataSource = self
		statsViewController = (storyboard?.instantiateViewController(withIdentifier: "statsView") as! StatsVC)
		statsViewController?.dataSource = self
		teamDetailVC = storyboard?.instantiateViewController(withIdentifier: "teamDetail")
		matchOverviewVC = (storyboard?.instantiateViewController(withIdentifier: "matchOverview") as! MatchOverviewViewController)
		matchOverviewVC?.dataSource = self
		
		//Set the images(buttons) content sizing property
		frontImageButton.imageView?.contentMode = .scaleAspectFit
		sideImageButton.imageView?.contentMode = .scaleAspectFit
		
		let displayModeButtonItem = splitViewController!.displayModeButtonItem
//		displayModeButtonItem.title = "Teams"
		
		if navigationItem.leftBarButtonItems?.isEmpty ?? true {
			navigationItem.leftBarButtonItems = [displayModeButtonItem]
		} else {
			navigationItem.leftBarButtonItems?.insert(displayModeButtonItem, at: 0)
		}
		
		//Set the delegate on the TeamListTableView
//		var vc = splitViewController?.viewControllers.first
//		repeat {
//			vc = (vc as! UINavigationController).topViewController
//		} while !(vc is TeamListTableViewController)
//		
//		let masterVC = vc as! TeamListTableViewController
//		masterVC.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//Move initially to the game stats
		if currentChildVC != gameStatsController {
			cycleFromViewController(childViewControllers.first!, toViewController: gameStatsController!)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if segue.identifier == "standsScouting" {
			let destinationVC = segue.destination as! StandsScoutingViewController
			destinationVC.teamEventPerformance = teamEventPerformance
		}
	}
	
	func cycleFromViewController(_ oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMove(toParentViewController: nil)
		addChildViewController(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transition(from: oldVC, to: newVC, duration: 0, options: UIViewAnimationOptions(), animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMove(toParentViewController: self); self.currentChildVC = newVC})
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	//MARK: - Master View Delegate
	func selectedTeam(_ team: ObjectPair<Team,LocalTeam>?) {
		selectedTeam = team
	}
	
	func selectedEvent(_ event: Event?) {
		selectedEvent = event
	}
	
	//MARK: Segmented Control
	//Functionality for the Segemented Control
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		//Check which row control it is
		if sender == segmentControl {
			segmentControl2.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex, sender: sender)
		} else if sender == segmentControl2 {
			segmentControl.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex + 3, sender: sender)
		}
	}
	
	@IBAction func listPressed(_ sender: UIBarButtonItem) {
		//splitViewController?.showViewController(splitViewController!.viewControllers.first!, sender: self)
	}
	
	func segmentSelected(_ segment: Int, sender: UISegmentedControl?) {
		switch segment {
		case 0, -1:
			//Check to see if the current view controller is the same as the game stats controller. If it is different, then switch to it.
			if currentChildVC != gameStatsController {
				cycleFromViewController(currentChildVC!, toViewController: gameStatsController!)
			}
		case 1:
			break
		case 2:
			cycleFromViewController(currentChildVC!, toViewController: statsViewController!)
		case 3:
			setUpTeamDetailController(teamDetailVC!)
			cycleFromViewController(currentChildVC!, toViewController: teamDetailVC!)
		case 4:
			cycleFromViewController(currentChildVC!, toViewController: matchOverviewVC!)
		default:
			break
		}
	}
	
	func setSelectedSegment(_ segment: Int) {
		if segment == -1 {
			segmentControl.selectedSegmentIndex = -1
			segmentControl2.selectedSegmentIndex = -1
		} else if segment <= 2 {
			segmentControl.selectedSegmentIndex = segment
			segmentControl2.selectedSegmentIndex = -1
		} else {
			segmentControl2.selectedSegmentIndex = segment - 3
			segmentControl.selectedSegmentIndex = -1
		}
	}
	
	func setUpTeamDetailController(_ detailController: UIViewController) {
		//		let detailTable = detailController.view.viewWithTag(1) as! UITableView
		//		let dataAndDelegate = TeamDetailTableViewDataAndDelegate(withTableView: detailTable)
		//		detailTable.dataSource = dataAndDelegate
		//		detailTable.delegate = dataAndDelegate
		//
		//		dataAndDelegate.setUpWithTeam(team)
		
		/*
		let detailsLabel = detailController.view.viewWithTag(2) as! UILabel
		var detailString = ""
		detailString.append("Height: \((selectedTeam?.height) ?? 0)")
		detailString.append("\nDrive Train: \(selectedTeam?.driveTrain ?? "")")
		detailString.append("\nVision Tracking Rating: \(selectedTeam?.visionTrackingRating ?? 0)")
		detailString.append("\nClimber: \(selectedTeam?.climber?.boolValue ?? false)")
		detailString.append("\nHigh Goal: \(selectedTeam?.highGoal?.boolValue ?? false)")
		detailString.append("\nLow Goal: \(selectedTeam?.lowGoal?.boolValue ?? false)")
		detailString.append("\nAutonomous Defenses Able To Cross: ")
		for defense in selectedTeam?.autonomousDefensesAbleToCrossArray ?? [] {
			detailString.append(" \(defense),")
		}
		detailString.append("\nAutonomous Defenses Able To Shoot From: ")
		for defense in selectedTeam?.autonomousDefensesAbleToShootArray ?? [] {
			detailString.append(" \(defense),")
		}
		detailString.append("\nDefenses Able To Cross: ")
		for defense in selectedTeam?.defensesAbleToCrossArray ?? [] {
			detailString.append(" \(defense),")
		}
		
		detailsLabel.text = detailString
		
		let notesView = detailController.view.viewWithTag(3) as! UITextView
		notesView.text = selectedTeam?.notes
		notesView.layer.cornerRadius = 5
		notesView.layer.borderWidth = 3
		notesView.layer.borderColor = UIColor.lightGray.cgColor
		
		notesView.delegate = self
*/
	}
	
	//MARK: Displaying full screen photos
	@IBAction func selectedImage(_ sender: UIButton) {
		let photo: NYTPhoto
		var photosArray: [NYTPhoto] = []
		switch sender {
		case frontImageButton:
			if let image = frontImage {
				photo = image
			} else {return}
		case sideImageButton:
			if let image = sideImage {
				photo = image
			} else {return}
		default:
			return
		}
		
		if let image = frontImage {
			photosArray.append(image)
		}
		if let image = sideImage {
			photosArray.append(image)
		}
		
		let photoVC = NYTPhotosViewController(photos: photosArray, initialPhoto: photo, delegate: self)
		present(photoVC, animated: true, completion: nil)
		Answers.logContentView(withName: "Team Robot Images", contentType: "Photo", contentId: nil, customAttributes: ["Team":"\(selectedTeam?.universal.teamNumber ?? "")"])
	}
}

class TeamImagePhoto: NSObject, NYTPhoto {
	var image: UIImage?
	var imageData: Data?
	var placeholderImage: UIImage?
	var attributedCaptionTitle: NSAttributedString?
	var attributedCaptionCredit: NSAttributedString?
	var attributedCaptionSummary: NSAttributedString?
	
	init(image: UIImage?, imageData: Data? = nil, attributedCaptionTitle: NSAttributedString) {
		self.image = image
		self.imageData = imageData
		self.attributedCaptionTitle = attributedCaptionTitle
	}
}

extension TeamListDetailViewController: UITextViewDelegate {
	func textViewDidEndEditing(_ textView: UITextView) {
//		selectedTeam?.notes = textView.text
		teamManager.commitChanges()
	}
}

extension TeamListDetailViewController: NYTPhotosViewControllerDelegate {
	func photosViewController(_ photosViewController: NYTPhotosViewController, captionViewFor photo: NYTPhoto) -> UIView? {
		return nil
	}
	
	func photosViewController(_ photosViewController: NYTPhotosViewController, referenceViewFor photo: NYTPhoto) -> UIView? {
		if let photo = photo as? TeamImagePhoto {
			if photo == frontImage {
				return frontImageButton
			} else if photo == sideImage {
				return sideImageButton
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	func photosViewController(_ photosViewController: NYTPhotosViewController, titleFor photo: NYTPhoto, at photoIndex: UInt, totalPhotoCount: UInt) -> String? {
		return nil
	}
	
	func photosViewController(_ photosViewController: NYTPhotosViewController, maximumZoomScaleFor photo: NYTPhoto) -> CGFloat {
		return CGFloat(2)
	}
	
	func photosViewController(_ photosViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
		NSLog("Completed Action: \(activityType ?? "Unknown")")
		Answers.logShare(withMethod: activityType, contentName: "Team Photos", contentType: "Photo", contentId: nil, customAttributes: nil)
	}
}

extension TeamListDetailViewController: TeamListSegmentsDataSource {
	func currentMatchPerformances() -> [ObjectPair<TeamMatchPerformance,LocalMatchPerformance>] {
        return ObjectPair<TeamMatchPerformance,LocalMatchPerformance>.fromArray(universals: teamEventPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance] ?? []) ?? []
	}
	
	func currentTeam() -> ObjectPair<Team,LocalTeam>? {
		return selectedTeam
	}
	
	func currentEventPerformance() -> TeamEventPerformance? {
		return teamEventPerformance
	}
}

protocol TeamListSegmentsDataSource {
	func currentMatchPerformances() -> [ObjectPair<TeamMatchPerformance,LocalMatchPerformance>]
	func currentEventPerformance() -> TeamEventPerformance?
	func currentTeam() -> ObjectPair<Team,LocalTeam>?
}

