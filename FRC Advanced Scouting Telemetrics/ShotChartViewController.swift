//
//  ShotChartViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/25/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class ShotChartViewController: UIViewController {
	@IBOutlet weak var offenseImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func selectedMatchPerformance(matchPerformance: TeamMatchPerformance) {
		//First, remove all the previous points
		for view in offenseImage.subviews {
			view.removeFromSuperview()
		}
		
		//Then add all the new ones
		for shot in matchPerformance.offenseShots?.allObjects as! [Shot] {
			let point = CGPoint(x: shot.xLocation!.doubleValue, y: shot.yLocation!.doubleValue)
			let rect = CGRect(origin: point, size: CGSize(width: 6, height: 6)).offsetBy(dx: -3, dy: -3)
			let pointView = UIView(frame: rect)
			pointView.layer.cornerRadius = 3

			//Set the correct color
			if shot.blocked == true {
				pointView.backgroundColor = UIColor.redColor()
			} else {
				pointView.backgroundColor = UIColor.greenColor()
			}

			offenseImage.addSubview(pointView)
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
