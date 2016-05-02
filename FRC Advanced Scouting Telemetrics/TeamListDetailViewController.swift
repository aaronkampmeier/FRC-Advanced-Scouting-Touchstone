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
	@IBOutlet weak var driverExpLabel: UILabel!
	@IBOutlet weak var weightLabel: UILabel!
	@IBOutlet weak var standsScoutingButton: UIBarButtonItem!
	
	var frontImage: TeamImagePhoto? {
		didSet {
			frontImageButton.setImage(frontImage?.image, forState: .Normal)
		}
	}
	
	var sideImage: TeamImagePhoto? {
		didSet {
			sideImageButton.setImage(sideImage?.image, forState: .Normal)
		}
	}

	let teamManager = TeamDataManager()
	var selectedTeam: Team? {
		didSet {
			if let team = selectedTeam {
				teamNumberLabel.text = team.teamNumber
				
				weightLabel.text = "Weight: \(team.robotWeight ?? 0) lbs"
				
				driverExpLabel.text = "Driver Exp: \(team.driverExp ?? 0) yrs"
				
				//Populate the images, if there are images
				if let image = team.frontImage {
					frontImage = TeamImagePhoto(image: UIImage(data: image), attributedCaptionTitle: NSAttributedString(string: "Team \(team.teamNumber!): Front Image"))
				} else {
					frontImage = nil
				}
				if let image = team.sideImage {
					sideImage = TeamImagePhoto(image: UIImage(data: image), attributedCaptionTitle: NSAttributedString(string: "Team \(team.teamNumber!): Side Image"))
				} else {
					sideImage = nil
				}
			} else {
				
			}
		}
	}
	var selectedRegional: Regional?
	var teamRegionalPerformance: TeamRegionalPerformance? {
		get {
			if let team = selectedTeam {
				if let regional = selectedRegional {
					//Get two sets
					let regionalPerformances: Set<TeamRegionalPerformance> = Set(regional.teamRegionalPerformances?.allObjects as! [TeamRegionalPerformance])
					let teamPerformances = Set(team.regionalPerformances?.allObjects as! [TeamRegionalPerformance])
					
					//Combine the two sets to find the one in both
					let teamRegionalPerformance = Array(regionalPerformances.intersect(teamPerformances)).first!
					
					return teamRegionalPerformance
				}
			}
			return nil
		}
	}
	
	//Child View Controllers
	var currentChildVC: UIViewController?
	var gameStatsController: GameStatsController?
	var shotChartController: ShotChartViewController?
	var statsViewController: StatsVC?
	var sortVC: SortVC!
	var teamDetailVC: UIViewController?
	var matchOverviewVC: MatchOverviewViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading trhe view.
		
		//Set the labels' default text
		weightLabel.text = ""
		driverExpLabel.text = ""
		
		//Set the stands scouting button to not selectable since there is no team selected
		standsScoutingButton.enabled = false
		
		//Get the child view controllers
		gameStatsController = (storyboard?.instantiateViewControllerWithIdentifier("gameStatsCollection") as! GameStatsController)
		shotChartController = (storyboard?.instantiateViewControllerWithIdentifier("shotChart") as! ShotChartViewController)
		statsViewController = (storyboard?.instantiateViewControllerWithIdentifier("statsView") as! StatsVC)
		teamDetailVC = storyboard?.instantiateViewControllerWithIdentifier("teamDetail")
		matchOverviewVC = (storyboard?.instantiateViewControllerWithIdentifier("matchOverview") as! MatchOverviewViewController)
		sortVC = storyboard!.instantiateViewControllerWithIdentifier("statsSortView") as! SortVC
		
		//Set the images(buttons) content sizing property
		frontImageButton.imageView?.contentMode = .ScaleAspectFit
		sideImageButton.imageView?.contentMode = .ScaleAspectFit
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		//Move initially to the game stats
		if currentChildVC != gameStatsController {
			cycleFromViewController(childViewControllers.first!, toViewController: gameStatsController!)
		}
	}
	
	func cycleFromViewController(oldVC: UIViewController, toViewController newVC: UIViewController) {
		oldVC.willMoveToParentViewController(nil)
		addChildViewController(newVC)
		
		newVC.view.frame = oldVC.view.frame
		
		transitionFromViewController(oldVC, toViewController: newVC, duration: 0, options: .TransitionNone, animations: {}, completion: {_ in oldVC.removeFromParentViewController(); newVC.didMoveToParentViewController(self); self.currentChildVC = newVC})
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: - Master View Delegate
	func selectedTeam(team: Team) {
		selectedTeam = team
	}
	
	func selectedRegional(regional: Regional) {
		selectedRegional = regional
	}
	
	//MARK: Segmented Control
	//Functionality for the Segemented Control
	@IBAction func segmentChanged(sender: UISegmentedControl) {
		//Check which row control it is
		if sender == segmentControl {
			segmentControl2.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex, sender: sender)
		} else if sender == segmentControl2 {
			segmentControl.selectedSegmentIndex = -1
			segmentSelected(sender.selectedSegmentIndex + 3, sender: sender)
		}
	}
	
	func segmentSelected(segment: Int, sender: UISegmentedControl?) {
		switch segment {
		case 0, -1:
			//Check to see if the current view controller is the same as the game stats controller. If it is different, than switch to it.
			if currentChildVC != gameStatsController {
				cycleFromViewController(currentChildVC!, toViewController: gameStatsController!)
			}
		case 1:
			if selectedRegional == nil {
				//Haha, nope. You aren't in a regional
				setSelectedSegment(0)
			} else {
				//Check to see if the current view controller is the same as the shot chart controller. If it is different, than switch to it.
				if currentChildVC != shotChartController {
					cycleFromViewController(currentChildVC!, toViewController: shotChartController!)
				}
				
				//Present Alert asking for the match the user would like to view
				let alert = UIAlertController(title: "Select Match", message: "Select a match to see its shots.", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "Overall", style: .Default, handler: {_ in self.shotChartController?.selectedMatchPerformance(nil)}))
				let sortedMatchPerformances = (teamRegionalPerformance?.matchPerformances?.allObjects as? [TeamMatchPerformance] ?? [TeamMatchPerformance]()).sort() {$0.0.match?.matchNumber?.integerValue < $0.1.match?.matchNumber?.integerValue}
				for matchPerformance in sortedMatchPerformances {
					alert.addAction(UIAlertAction(title: String(matchPerformance.match!.matchNumber!), style: .Default, handler: {_ in self.shotChartController!.selectedMatchPerformance(matchPerformance)}))
				}
				presentViewController(alert, animated: true, completion: nil)
			}
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
	
	func setSelectedSegment(segment: Int) {
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
	
	func setUpTeamDetailController(detailController: UIViewController) {
		//		let detailTable = detailController.view.viewWithTag(1) as! UITableView
		//		let dataAndDelegate = TeamDetailTableViewDataAndDelegate(withTableView: detailTable)
		//		detailTable.dataSource = dataAndDelegate
		//		detailTable.delegate = dataAndDelegate
		//
		//		dataAndDelegate.setUpWithTeam(team)
		
		let detailsLabel = detailController.view.viewWithTag(2) as! UILabel
		var detailString = ""
		detailString.appendContentsOf("Height: \((selectedTeam?.height) ?? 0)")
		detailString.appendContentsOf("\nDrive Train: \(selectedTeam?.driveTrain ?? "")")
		detailString.appendContentsOf("\nVision Tracking Rating: \(selectedTeam?.visionTrackingRating ?? 0)")
		detailString.appendContentsOf("\nClimber: \(selectedTeam?.climber?.boolValue ?? false)")
		detailString.appendContentsOf("\nHigh Goal: \(selectedTeam?.highGoal?.boolValue ?? false)")
		detailString.appendContentsOf("\nLow Goal: \(selectedTeam?.lowGoal?.boolValue ?? false)")
		detailString.appendContentsOf("\nAutonomous Defenses Able To Cross: ")
		for defense in selectedTeam?.autonomousDefensesAbleToCrossArray ?? [] {
			detailString.appendContentsOf(" \(defense),")
		}
		detailString.appendContentsOf("\nAutonomous Defenses Able To Shoot From: ")
		for defense in selectedTeam?.autonomousDefensesAbleToShootArray ?? [] {
			detailString.appendContentsOf(" \(defense),")
		}
		detailString.appendContentsOf("\nDefenses Able To Cross: ")
		for defense in selectedTeam?.defensesAbleToCrossArray ?? [] {
			detailString.appendContentsOf(" \(defense),")
		}
		
		detailsLabel.text = detailString
		
		let notesView = detailController.view.viewWithTag(3) as! UITextView
		notesView.text = selectedTeam?.notes
		notesView.layer.cornerRadius = 5
		notesView.layer.borderWidth = 3
		notesView.layer.borderColor = UIColor.lightGrayColor().CGColor
		
		notesView.delegate = self
	}
	
	//MARK: Displaying full screen photos
	@IBAction func selectedImage(sender: UIButton) {
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
		presentViewController(photoVC, animated: true, completion: nil)
		Answers.logContentViewWithName("Team Robot Images", contentType: "Photo", contentId: nil, customAttributes: ["Team":"\(selectedTeam?.teamNumber ?? "")"])
	}
}

class TeamImagePhoto: NSObject, NYTPhoto {
	var image: UIImage?
	var imageData: NSData?
	var placeholderImage: UIImage?
	var attributedCaptionTitle: NSAttributedString?
	var attributedCaptionCredit: NSAttributedString?
	var attributedCaptionSummary: NSAttributedString?
	
	init(image: UIImage?, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString) {
		self.image = image
		self.imageData = imageData
		self.attributedCaptionTitle = attributedCaptionTitle
	}
}

extension TeamListDetailViewController: UITextViewDelegate {
	func textViewDidEndEditing(textView: UITextView) {
		selectedTeam?.notes = textView.text
		teamManager.commitChanges()
	}
}

extension TeamListDetailViewController: NYTPhotosViewControllerDelegate {
	func photosViewController(photosViewController: NYTPhotosViewController, captionViewForPhoto photo: NYTPhoto) -> UIView? {
		return nil
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, referenceViewForPhoto photo: NYTPhoto) -> UIView? {
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
	
	func photosViewController(photosViewController: NYTPhotosViewController, titleForPhoto photo: NYTPhoto, atIndex photoIndex: UInt, totalPhotoCount: UInt) -> String? {
		return nil
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, maximumZoomScaleForPhoto photo: NYTPhoto) -> CGFloat {
		return CGFloat(2)
	}
	
	func photosViewController(photosViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
		NSLog("Completed Action: \(activityType ?? "Unknown")")
		Answers.logShareWithMethod(activityType, contentName: "Team Photos", contentType: "Photo", contentId: nil, customAttributes: nil)
	}
}
