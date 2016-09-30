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
	var dataSource: TeamListSegmentsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		offenseImage.addSubview(invisibleView)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		reloadInvisibleView()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		let previousSize = invisibleView.frame.size
		coordinator.animate(alongsideTransition: nil, completion: {_ in self.reloadInvisibleView(); self.reloadPoints(previousSize)})
	}
	
	private func reloadInvisibleView() {
		let rect = AVMakeRect(aspectRatio: offenseImage.image!.size, insideRect: offenseImage.bounds)
		invisibleView.frame = rect
	}
	
	private func reloadPoints(_ oldSize: CGSize) {
		for pointView in invisibleView.subviews {
			pointView.frame.origin = translatePoint(pointView.frame.origin, fromSize: oldSize, toSize: invisibleView.frame.size)
		}
	}
	
	func loadForMatchPerformance(_ matchPerformance: TeamMatchPerformance?) {
		//First, remove all the previous points
		for view in invisibleView.subviews {
			view.removeFromSuperview()
		}
		
		var matchPerformances = [TeamMatchPerformance]()
		
		//Then add all the new ones
		if let matchPerformance = matchPerformance {
		    matchPerformances.append(matchPerformance)
		} else {
			if let performance = dataSource?.currentRegionalPerformance() {
				for mPerformance in performance.matchPerformances?.allObjects as! [TeamMatchPerformance] {
					matchPerformances.append(mPerformance)
				}
			} else {
				for tPerformance in dataSource?.currentTeam()?.regionalPerformances?.allObjects as? [TeamRegionalPerformance] ?? [TeamRegionalPerformance]() {
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
				pointView.backgroundColor = UIColor.red
			} else {
				pointView.backgroundColor = UIColor.green
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
