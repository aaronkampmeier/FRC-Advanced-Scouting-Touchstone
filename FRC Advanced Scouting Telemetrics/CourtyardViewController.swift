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
	var storedSizeOfImage: CGSize!
	
	struct CourtyardShot {
		let shot: Shot?
		var storedCoordinate: CGPoint {
			get {
				return CGPoint(x: (shot?.xLocation?.doubleValue)!, y: (shot?.yLocation?.doubleValue)!)
			}
			
			set {
				shot?.xLocation = newValue.x
				shot?.yLocation = newValue.y
			}
		}
		
		var pointView: UIView!
		
		init(shot: Shot) {
			self.shot = shot
			
			storedCoordinate = CGPoint(x: (shot.xLocation?.doubleValue)!, y: (shot.yLocation?.doubleValue)!)
		}
	}
	
	enum DefenseOrOffense {
		case Defense
		case Offense
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//Add the invisible layer and add the tap gesture recognizer
		courtyardImage.addSubview(invisibleView)
		tapGesture.addTarget(self, action: "tappedOnImage:")
		invisibleView.addGestureRecognizer(tapGesture)
		
		standsScoutingVC = parentViewController as? StandsScoutingViewController
		
		//Set the image
		switch defenseOrOffense! {
		case .Defense:
			courtyardImage.image = UIImage(named: "DefenseRender")
			storedSizeOfImage = ImageConstants.defenseImageStoredSize
		case .Offense:
			courtyardImage.image = UIImage(named: "OffenseRender")
			storedSizeOfImage = ImageConstants.offenseImageStoredSize
		}
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		//Get the CGRect of the actual image and set the invisible view's frame to be that rect
		reloadInvisibleView()
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		coordinator.animateAlongsideTransition(nil){_ in self.reloadInvisibleView()}
	}
	
	func reloadInvisibleView() {
		//Get the previous size
		let previousSize = invisibleView.bounds.size
		
		//Reload the invisible view's rect
		let rect = AVMakeRectWithAspectRatioInsideRect(courtyardImage.image!.size, courtyardImage.bounds)
		invisibleView.frame = rect
		
		//Reload the points
		reloadPointLocations(previousSize)
	}
	
	func reloadPointLocations(previousSize: CGSize) {
		for pointView in invisibleView.subviews {
			pointView.frame.origin = translatePoint(pointView.frame.origin, fromSize: previousSize, toSize: invisibleView.frame.size)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	var finishedEditingShot: Bool = false
	
	func tappedOnImage(sender: UITapGestureRecognizer) {
		let location = sender.locationInView(invisibleView)
		//Create a new shot
		selectedShot = CourtyardShot(shot: dataManager.createShot(atPoint: translatePointCoordinateToStoredCordinate(location, viewSize: invisibleView.frame.size, storedSize: storedSizeOfImage)))
		selectedShot?.shot?.shootingTeam = standsScoutingVC?.matchPerformance
		
		//Make a view for the shot
		let point = location
		let pointView = UIView(frame: CGRect(origin: point, size: CGSize(width: 6, height: 6)).offsetBy(dx: -3, dy: -3))
		pointView.layer.cornerRadius = 3
		pointView.backgroundColor = UIColor.blueColor()
		//Add the point to the view
		invisibleView.addSubview(pointView)
		
		//Save it in the struct
		selectedShot?.pointView = pointView
		
		let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("standsCourtyardPopover")
		//Set up the tables
		let teamTable = popoverVC!.view.viewWithTag(7) as! UITableView
		let blockedTable = popoverVC?.view.viewWithTag(2) as! UITableView
		teamTable.dataSource = self
		teamTable.delegate = self
		blockedTable.dataSource = self
		blockedTable.delegate = self
		
		popoverVC?.modalPresentationStyle = .Popover
		let popover = popoverVC?.popoverPresentationController
		popoverVC?.preferredContentSize = CGSizeMake(300, 200)
		popover?.delegate = self
		popover?.sourceView = pointView
		presentViewController(popoverVC!, animated: true, completion: nil)
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
			//Update the dot (rect) on the screen and save a time marker
			var markerType: TeamDataManager.TimeMarkerEvent
			switch defenseOrOffense! {
			case .Defense:
				markerType = TeamDataManager.TimeMarkerEvent.OffenseAttemptedShot
				break
				//Deprecated
//				if selectedShot!.shot?.blocked == true {
//					selectedShot?.pointView.backgroundColor = UIColor.greenColor()
//				} else {
//					selectedShot?.pointView.backgroundColor = UIColor.redColor()
//				}
//				markerType = TeamDataManager.TimeMarkerEvent.DefenseAttemptedBlock
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
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch tableView.tag {
		case 7:
			return 2
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
			switch indexPath.row {
			case 0:
				cell?.textLabel?.text = "Low Goal"
			case 1:
				cell?.textLabel?.text = "High Goal"
			default:
				cell?.textLabel?.text = ""
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
			//Save if it was the high goal or not
			selectedShot?.shot?.highGoal = indexPath.row
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
