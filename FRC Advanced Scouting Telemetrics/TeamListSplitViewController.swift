//
//  TeamListSplitViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
		return .all
	}
	
	func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
		NSLog("Target Display Mode For Action")
		return .automatic
	}
	
	func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
		let displayModeString: String
		switch displayMode {
		case .allVisible:
			displayModeString = "All Visible"
		case .automatic:
			displayModeString = "Automatic"
		case .primaryHidden:
			displayModeString = "Primary Hidden"
		case .primaryOverlay:
			displayModeString = "Primary Overlay"
		}
		NSLog("SVC will change to \(displayModeString)")
	}

}

extension UINavigationController {
	//When the split view controller will go into a collapsed state, it will attempt to push the secondary vc onto the primary vc's nav controller stack. Because our secondary vc is a nav controller we need to instead push all of the secondary nav vcs onto the primary nav vcs. And then reverse this change when the split view controller is expanded. Reference: http://commandshift.co.uk/blog/2016/04/11/understanding-split-view-controller/
	
	override open func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
		if let secondaryAsNav = secondaryViewController as? UINavigationController {
			//Combine the vcs from both nav controller's stacks
			NSLog("Collapsing view controllers")
			self.setViewControllers(self.viewControllers + secondaryAsNav.viewControllers, animated: false)
		} else {
			super.collapseSecondaryViewController(secondaryViewController, for: splitViewController)
		}
	}
	
	override open func separateSecondaryViewController(for splitViewController: UISplitViewController) -> UIViewController? {
		//Grab the first vc to keep in this nav controller, then take all the other vcs and push them onto a second nav controller and use that as the secondary vc for the split vc.
		NSLog("Expanding view controllers")
		var vcs = viewControllers
		let primaryContentVC = vcs.removeFirst()
		var secondaryVCs = vcs
		let secondaryNav = storyboard?.instantiateViewController(withIdentifier: "secondaryNav") as! UINavigationController
		
		if secondaryVCs.isEmpty {
			secondaryVCs = [(UIApplication.shared.delegate as! AppDelegate).teamListDetailVC!]
		}
		secondaryNav.setViewControllers(secondaryVCs, animated: false)
		self.setViewControllers([primaryContentVC], animated: false)
		return secondaryNav
	}
}
