//
//  TeamListSplitViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    //MARK: - View Controller Storage
    private(set) lazy var teamListTableNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "teamListTableNav") as! UINavigationController
    private(set) lazy var teamListTableVC: TeamListTableViewController = {
        teamListTableNavigationController.topViewController as! TeamListTableViewController
    }()
    private(set) lazy var teamDetailNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "secondaryNav") as! UINavigationController
    private(set) lazy var teamDetailVC = {
        teamDetailNavigationController.topViewController as! TeamListDetailViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewControllers = [teamListTableNavigationController, teamDetailNavigationController]
		self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
		return .all
	}
	
	func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
		return .automatic
	}
	
	func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
		
	}

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //Check if there is a team being shown
        if primaryViewController == teamListTableNavigationController && secondaryViewController == teamDetailNavigationController {
            if teamDetailVC.selectedTeam != nil {
                //There is a team so show this detail view within the primary's navigation stack
                teamListTableNavigationController.setViewControllers(teamListTableNavigationController.viewControllers + teamDetailNavigationController.viewControllers, animated: false)
                return true
            } else {
                //There isn't a team. just show the default primary vc
                return false
            }
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        //Check if it is the team list
        if primaryViewController == teamListTableNavigationController {
            //Get the first vc to use as the primary
            let secondaryViewControllers = teamListTableNavigationController.popToRootViewController(animated: false) ?? []
            if secondaryViewControllers.count > 0 {
                teamDetailNavigationController.setViewControllers(secondaryViewControllers, animated: false)
            } else {
                teamDetailNavigationController.setViewControllers([teamDetailVC], animated: false)
            }
            
            return teamDetailNavigationController
        }
        
        return nil
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        //Checks if the split view is collapsed or not. If collapsed, then conditionally push the vc's view controllers onto the primary stack.
        if self.isCollapsed {
            if let firstNav = viewControllers.first as? UINavigationController, let vc = vc as? UINavigationController {
                firstNav.setViewControllers(firstNav.viewControllers + vc.viewControllers, animated: true)
                return true
            }
        }
        
        return false
    }
}

extension UINavigationController {
    /// When the split view controller will go into a collapsed state, it will attempt to push the secondary vc onto the primary vc's nav controller stack.
    /// Because our secondary vc is a nav controller we need to instead push all of the secondary nav vcs onto the primary nav vcs.
    /// And then reverse this change when the split view controller is expanded. Reference: http://commandshift.co.uk/blog/2016/04/11/understanding-split-view-controller/
	
//	override open func separateSecondaryViewController(for splitViewController: UISplitViewController) -> UIViewController? {
//		//Grab the first vc to keep in this nav controller, then take all the other vcs and push them onto a second nav controller and use that as the secondary vc for the split vc.
//		NSLog("Expanding view controllers")
//		var vcs = viewControllers
//		let primaryContentVC = vcs.removeFirst()
//
//        if let matchSplitVC = splitViewController as? MatchOverviewSplitViewController {
//            let detailNav = UINavigationController(rootViewController: matchSplitVC.matchesDetail!)
//
//            self.setViewControllers([primaryContentVC], animated: true)
//            return detailNav
//        } else {
//            var secondaryVCs = vcs
//            let secondaryNav = storyboard?.instantiateViewController(withIdentifier: "secondaryNav") as! UINavigationController
//
//            if secondaryVCs.isEmpty {
//                secondaryVCs = [(splitViewController as! TeamListSplitViewController).teamListDetailVC]
//            }
//            secondaryNav.setViewControllers(secondaryVCs, animated: false)
//            self.setViewControllers([primaryContentVC], animated: false)
//            return secondaryNav
//        }
//	}
}
