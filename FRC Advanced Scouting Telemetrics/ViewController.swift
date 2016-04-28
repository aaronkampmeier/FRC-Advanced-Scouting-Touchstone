//
//  ViewController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 1/4/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
	func presentViewControllerFromVisibleViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		if let navigationController = self as? UINavigationController, let topViewController = navigationController.topViewController {
			topViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: completion)
		} else if (presentedViewController != nil) {
			presentedViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: completion)
		} else {
			presentViewController(viewControllerToPresent, animated: true, completion: completion)
		}
	}
}