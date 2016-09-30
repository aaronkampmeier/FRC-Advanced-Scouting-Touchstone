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
	var storedSizeOfImage: CGSize!
	
	struct CourtyardShot {
		let shot: Shot?
		var storedCoordinate: CGPoint {
			get {
				return CGPoint(x: (shot?.xLocation?.doubleValue)!, y: (shot?.yLocation?.doubleValue)!)
			}
			
			set {
				shot?.xLocation = newValue.x as NSNumber?
				shot?.yLocation = newValue.y as NSNumber?
			}
		}
		
		var pointView: UIView!
		
		init(shot: Shot) {
			self.shot = shot
			
			storedCoordinate = CGPoint(x: (shot.xLocation?.doubleValue)!, y: (shot.yLocation?.doubleValue)!)
		}
	}
	
	enum DefenseOrOffense {
		case defense
		case offense
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//Add the invisible layer and add the tap gesture recognizer
		courtyardImage.addSubview(invisibleView)
		tapGesture.addTarget(self, action: #selector(CourtyardViewController.tappedOnImage(_:)))
		invisibleView.addGestureRecognizer(tapGesture)
		
		standsScoutingVC = parent as? StandsScoutingViewController
		
		courtyardImage.image = UIImage(named: "OffenseRender")
		storedSizeOfImage = ImageConstants.offenseImageStoredSize
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//Get the CGRect of the actual image and set the invisible view's frame to be that rect
		reloadInvisibleView()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: nil){_ in self.reloadInvisibleView()}
	}
	
	func reloadInvisibleView() {
		//Get the previous size
		let previousSize = invisibleView.bounds.size
		
		//Reload the invisible view's rect
		let rect = AVMakeRect(aspectRatio: courtyardImage.image!.size, insideRect: courtyardImage.bounds)
		invisibleView.frame = rect
		
		//Reload the points
		reloadPointLocations(previousSize)
	}
	
	func reloadPointLocations(_ previousSize: CGSize) {
		for pointView in invisibleView.subviews {
			pointView.frame.origin = translatePoint(pointView.frame.origin, fromSize: previousSize, toSize: invisibleView.frame.size)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	var finishedEditingShot: Bool = false
	
	func tappedOnImage(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: invisibleView)
		//Create a new shot
		selectedShot = CourtyardShot(shot: dataManager.createShot(atPoint: translatePointCoordinateToStoredCordinate(location, viewSize: invisibleView.frame.size, storedSize: storedSizeOfImage)))
		selectedShot?.shot?.shootingTeam = standsScoutingVC?.matchPerformance
		
		//Make a view for the shot
		let point = location
		let pointView = UIView(frame: CGRect(origin: point, size: CGSize(width: 6, height: 6)).offsetBy(dx: -3, dy: -3))
		pointView.layer.cornerRadius = 3
		pointView.backgroundColor = UIColor.blue
		//Add the point to the view
		invisibleView.addSubview(pointView)
		
		//Save it in the struct
		selectedShot?.pointView = pointView
		
		let popoverVC = storyboard?.instantiateViewController(withIdentifier: "standsCourtyardPopover")
		//Set up the tables
		let teamTable = popoverVC!.view.viewWithTag(7) as! UITableView
		let blockedTable = popoverVC?.view.viewWithTag(2) as! UITableView
		teamTable.dataSource = self
		teamTable.delegate = self
		blockedTable.dataSource = self
		blockedTable.delegate = self
		
		popoverVC?.modalPresentationStyle = .popover
		let popover = popoverVC?.popoverPresentationController
		popoverVC?.preferredContentSize = CGSize(width: 300, height: 150)
		popover?.delegate = self
		popover?.sourceView = pointView
		present(popoverVC!, animated: true, completion: nil)
	}
	
	func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
		let teamTable = popoverPresentationController.presentedViewController.view.viewWithTag(7) as! UITableView
		let blockedTable = popoverPresentationController.presentedViewController.view.viewWithTag(2) as! UITableView
		
		if let _ = teamTable.indexPathForSelectedRow {
			if let _ = blockedTable.indexPathForSelectedRow {
				finishedEditingShot = true
				return true
			}
		}
		
		finishedEditingShot = false
		let alert = UIAlertController(title: "Select Team and Blocked status", message: "Please select the goal and if the shot was blocked or not, or else the shot will be removed.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Remove shot", style: .destructive, handler: {_ in self.dismiss(animated: true, completion: {_ in self.popoverPresentationControllerDidDismissPopover(popoverPresentationController)})}))
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		popoverPresentationController.presentedViewController.present(alert, animated: true, completion: nil)
		
		return false
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		if finishedEditingShot {
			//Update the dot (rect) on the screen and save a time marker
			
			if selectedShot!.shot?.blocked == true {
				selectedShot?.pointView.backgroundColor = UIColor.red
			} else {
				selectedShot?.pointView.backgroundColor = UIColor.green
			}
			
			if let highGoal = selectedShot?.shot?.highGoal?.boolValue {
				if highGoal && selectedShot!.shot?.blocked == true {
					dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.failedHighShot, atTime: standsScoutingVC!.stopwatch.elapsedTime, inMatchPerformance: standsScoutingVC!.matchPerformance!)
				} else if highGoal && selectedShot!.shot?.blocked == false {
					dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.successfulHighShot, atTime: standsScoutingVC!.stopwatch.elapsedTime, inMatchPerformance: standsScoutingVC!.matchPerformance!)
				} else if !highGoal && selectedShot!.shot?.blocked == true {
					dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.failedLowShot, atTime: standsScoutingVC!.stopwatch.elapsedTime, inMatchPerformance: standsScoutingVC!.matchPerformance!)
				} else if !highGoal && selectedShot!.shot?.blocked == false {
					dataManager.addTimeMarker(withEvent: TeamDataManager.TimeMarkerEventType.successfulLowShot, atTime: standsScoutingVC!.stopwatch.elapsedTime, inMatchPerformance: standsScoutingVC!.matchPerformance!)
				}
			}
		} else {
			dataManager.remove(selectedShot!.shot!)
			selectedShot?.pointView.removeFromSuperview()
			selectedShot = nil
		}
	}
	
	//Table View
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch tableView.tag {
		case 7:
			return 2
		case 2:
			return 2
		default:
			return 0
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "basic")
		switch tableView.tag {
		case 7:
			switch (indexPath as NSIndexPath).row {
			case 0:
				cell?.textLabel?.text = "Low Goal"
			case 1:
				cell?.textLabel?.text = "High Goal"
			default:
				cell?.textLabel?.text = ""
			}
			return cell!
		case 2:
			switch (indexPath as NSIndexPath).row {
			case 0:
				cell?.textLabel?.text = "No"
			case 1:
				cell?.textLabel?.text = "Yes"
			default:
				cell?.textLabel?.text = ""
			}
			return cell!
		default:
			return cell!
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch tableView.tag {
		case 7:
			//Save if it was the high goal or not
			selectedShot?.shot?.highGoal = (indexPath as NSIndexPath).row as NSNumber?
		case 2:
			if (indexPath as NSIndexPath).row == 0 {
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

class DefenseVC: UIViewController {
	let dataManager = TeamDataManager()
	var standsScoutingVC: StandsScoutingViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		standsScoutingVC = (parent as! StandsScoutingViewController)
	}
	
	@IBAction func contact(_ sender: UIButton) {
		dataManager.addTimeMarker(withEvent: .contact, atTime: (standsScoutingVC?.stopwatch.elapsedTime)!, inMatchPerformance: (standsScoutingVC?.matchPerformance)!)
	}
	
	@IBAction func contactDisruptingShot(_ sender: UIButton) {
		dataManager.addTimeMarker(withEvent: .contactDisruptingShot, atTime: (standsScoutingVC?.stopwatch.elapsedTime)!, inMatchPerformance: (standsScoutingVC?.matchPerformance)!)
	}
}
