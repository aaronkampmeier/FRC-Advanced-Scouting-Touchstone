//
//  DefenseViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/20/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class CourtyardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
	@IBOutlet weak var courtyardImage: UIImageView!
	
	let dataManager = TeamDataManager()
	
	let tapGesture = UITapGestureRecognizer()
	let invisibleView = UIView()
	var selectedShot: CourtyardShot?
	
	var standsScoutingVC: StandsScoutingViewController?
	var defenseOrOffense: DefenseOrOffense?
	
	struct CourtyardShot {
		let shot: Shot?
		var point: CGPoint {
			get {
				return pointView.frame.origin
			}
			
			set {
				shot?.xLocation = newValue.x
				shot?.yLocation = newValue.y
				pointView.frame.origin = newValue
			}
		}
		var pointView: UIView = UIView()
		
		init(shot: Shot) {
			self.shot = shot
			
			point = CGPoint(x: (shot.xLocation?.doubleValue)!, y: (shot.yLocation?.doubleValue)!)
			
			pointView = UIView(frame: CGRect(origin: point, size: CGSize(width: 6, height: 6)).offsetBy(dx: -3, dy: -3))
			pointView.layer.cornerRadius = 3
			pointView.backgroundColor = UIColor.blueColor()
		}
	}
	
	enum DefenseOrOffense {
		case Defense
		case Offense
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//Set the image
		
		
		tapGesture.addTarget(self, action: "tappedOnImage:")
		courtyardImage.addGestureRecognizer(tapGesture)
		//view.addSubview(invisibleView)
		
		standsScoutingVC = parentViewController as? StandsScoutingViewController
		
		switch defenseOrOffense! {
		case .Defense:
			courtyardImage.image = UIImage(named: "DefenseRender")
		case .Offense:
			courtyardImage.image = UIImage(named: "OffenseRender")
		}
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let rect = AVMakeRectWithAspectRatioInsideRect(courtyardImage.image!.size, courtyardImage.bounds)
		invisibleView.frame = rect
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		let rect = AVMakeRectWithAspectRatioInsideRect(courtyardImage.image!.size, courtyardImage.bounds)
		invisibleView.frame = rect
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	var finishedEditingShot: Bool = false
	
	func tappedOnImage(sender: UITapGestureRecognizer) {
		let location = sender.locationInView(courtyardImage)
		//Create a new shot
		selectedShot = CourtyardShot(shot: dataManager.createShot(atPoint: location))
		switch defenseOrOffense! {
		case .Defense:
			selectedShot?.shot?.blockingTeam = standsScoutingVC?.matchPerformance
		case .Offense:
			selectedShot?.shot?.shootingTeam = standsScoutingVC?.matchPerformance
		}
		
		courtyardImage.addSubview((selectedShot?.pointView)!)
		
		let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("standsCourtyardPopover")
		//Set up the tables
		let teamTable = popoverVC!.view.viewWithTag(7) as! UITableView
		let blockedTable = popoverVC?.view.viewWithTag(2) as! UITableView
		teamTable.dataSource = self
		teamTable.delegate = self
		blockedTable.dataSource = self
		blockedTable.delegate = self
		teamsOfOppositeColor = (standsScoutingVC?.matchPerformance?.match?.teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor != standsScoutingVC?.matchPerformance?.allianceColor})
		
		popoverVC?.modalPresentationStyle = .Popover
		let popover = popoverVC?.popoverPresentationController
		popoverVC?.preferredContentSize = CGSizeMake(300, 200)
		popover?.delegate = self
		popover?.sourceView = self.view
		popover?.sourceRect = (selectedShot?.pointView.frame)!
		presentViewController(popoverVC!, animated: true, completion: {})
	}
	
	func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
		let teamTable = popoverPresentationController.presentedViewController.view.viewWithTag(7) as! UITableView
		let blockedTable = popoverPresentationController.presentedViewController.view.viewWithTag(2) as! UITableView
		
		if let _ = teamTable.indexPathForSelectedRow {
			if let _ = blockedTable.indexPathForSelectedRow {
				finishedEditingShot = true
				return true
			}
		}
		
		finishedEditingShot = false
		let alert = UIAlertController(title: "Select Team and Blocked status", message: "Please select an opposing team and if the shot was blocked or not, or else the shot will be removed.", preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Remove shot", style: .Destructive, handler: {_ in self.dismissViewControllerAnimated(true, completion: {_ in self.popoverPresentationControllerDidDismissPopover(popoverPresentationController)})}))
		alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		popoverPresentationController.presentedViewController.presentViewController(alert, animated: true, completion: nil)
		
		return false
	}
	
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
		if finishedEditingShot {
			dataManager.save()
			
			//Update the dot (rect) on the screen and save a time marker
			var markerType: TeamDataManager.TimeMarkerEvent
			switch defenseOrOffense! {
			case .Defense:
				if selectedShot!.shot?.blocked == true {
					selectedShot?.pointView.backgroundColor = UIColor.greenColor()
				} else {
					selectedShot?.pointView.backgroundColor = UIColor.redColor()
				}
				markerType = TeamDataManager.TimeMarkerEvent.DefenseAttemptedBlock
			case .Offense:
				if selectedShot!.shot?.blocked == true {
					selectedShot?.pointView.backgroundColor = UIColor.redColor()
				} else {
					selectedShot?.pointView.backgroundColor = UIColor.greenColor()
				}
				markerType = TeamDataManager.TimeMarkerEvent.OffenseAttemptedShot
			}
			dataManager.addTimeMarker(withEvent: markerType, atTime: (standsScoutingVC?.stopwatch.elapsedTime)!, inMatchPerformance: (standsScoutingVC?.matchPerformance)!)
		} else {
			dataManager.remove(selectedShot!.shot!)
			selectedShot?.pointView.removeFromSuperview()
			selectedShot = nil
		}
	}
	
	//Table View
	var teamsOfOppositeColor: [TeamMatchPerformance]?
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch tableView.tag {
		case 7:
			return teamsOfOppositeColor!.count
		case 2:
			return 2
		default:
			return 0
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("basic")
		switch tableView.tag {
		case 7:
			
			if standsScoutingVC?.matchPerformance?.allianceColor == 0 {
				cell?.textLabel?.text = "Red Team \(teamsOfOppositeColor![indexPath.row].regionalPerformance!.valueForKey("team")!.valueForKey("teamNumber")!)"
			} else {
				cell?.textLabel?.text = "Blue Team \(teamsOfOppositeColor![indexPath.row].regionalPerformance!.valueForKey("team")!.valueForKey("teamNumber")!)"
			}
			return cell!
		case 2:
			switch indexPath.row {
			case 0:
				cell?.textLabel?.text = "Yes"
			case 1:
				cell?.textLabel?.text = "No"
			default:
				break
			}
			return cell!
		default:
			return cell!
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch tableView.tag {
		case 7:
			//Get the team at the selected index path
			let team = teamsOfOppositeColor![indexPath.row]
			
			switch defenseOrOffense! {
			case .Defense:
				selectedShot?.shot?.shootingTeam = team
			case .Offense:
				selectedShot?.shot?.blockingTeam = team
			}
		case 2:
			if indexPath.row == 0 {
				selectedShot?.shot?.blocked = true
			} else {
				selectedShot?.shot?.blocked = false
			}
		default:
			break
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
