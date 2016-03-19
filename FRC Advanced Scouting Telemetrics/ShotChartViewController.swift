//
//  ShotChartViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/25/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class ShotChartViewController: UIViewController {
	@IBOutlet weak var offenseImage: UIImageView!
	
	let invisibleView = UIView()
	var teamListVC: TeamListController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		offenseImage.addSubview(invisibleView)
		teamListVC = parentViewController as! TeamListController
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		reloadInvisibleView()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		let previousSize = invisibleView.frame.size
		coordinator.animateAlongsideTransition(nil, completion: {_ in self.reloadInvisibleView(); self.reloadPoints(previousSize)})
	}
	
	func reloadInvisibleView() {
		let rect = AVMakeRectWithAspectRatioInsideRect(offenseImage.image!.size, offenseImage.bounds)
		invisibleView.frame = rect
	}
	
	func reloadPoints(oldSize: CGSize) {
		for pointView in invisibleView.subviews {
			pointView.frame.origin = translatePoint(pointView.frame.origin, fromSize: oldSize, toSize: invisibleView.frame.size)
		}
	}
	
	func selectedMatchPerformance(matchPerformance: TeamMatchPerformance?) {
		//First, remove all the previous points
		for view in invisibleView.subviews {
			view.removeFromSuperview()
		}
		
		var matchPerformances = [TeamMatchPerformance]()
		
		//Then add all the new ones
		if let matchPerformance = matchPerformance {
		    matchPerformances.append(matchPerformance)
		} else {
			if let performance = teamListVC.teamRegionalPerformance {
				for mPerformance in performance.matchPerformances?.allObjects as! [TeamMatchPerformance] {
					matchPerformances.append(mPerformance)
				}
			} else {
				for tPerformance in teamListVC.selectedTeamCache?.team.regionalPerformances?.allObjects as? [TeamRegionalPerformance] ?? [TeamRegionalPerformance]() {
					for mPerformance in tPerformance.matchPerformances?.allObjects as! [TeamMatchPerformance] {
						matchPerformances.append(mPerformance)
					}
				}
			}
		}
	
		for matchPerformance in matchPerformances {
		for shot in matchPerformance.offenseShots?.allObjects as! [Shot] {
			let coordinate = CGPoint(x: shot.xLocation!.doubleValue, y: shot.yLocation!.doubleValue)
			
			//Convert stored coordinate to point
			let point = translateStoredCoordinateToPoint(coordinate, storedSize: ImageConstants.offenseImageStoredSize, viewSize: invisibleView.frame.size)
			
			let rect = CGRect(origin: point, size: CGSize(width: 6, height: 6)).offsetBy(dx: -3, dy: -3)
			let pointView = UIView(frame: rect)
			pointView.layer.cornerRadius = 3

			//Set the correct color
			if shot.blocked == true {
				pointView.backgroundColor = UIColor.redColor()
			} else {
				pointView.backgroundColor = UIColor.greenColor()
			}

			invisibleView.addSubview(pointView)
		}
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
