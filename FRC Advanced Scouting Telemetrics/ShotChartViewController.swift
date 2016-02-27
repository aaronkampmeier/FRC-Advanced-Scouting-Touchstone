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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		offenseImage.addSubview(invisibleView)
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
		reloadInvisibleView()
		
		let previousSize = invisibleView.frame.size
		coordinator.animateAlongsideTransition(nil, completion: {_ in self.reloadPoints(previousSize)})
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
	
	func selectedMatchPerformance(matchPerformance: TeamMatchPerformance) {
		//First, remove all the previous points
		for view in invisibleView.subviews {
			view.removeFromSuperview()
		}
		
		//Then add all the new ones
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
