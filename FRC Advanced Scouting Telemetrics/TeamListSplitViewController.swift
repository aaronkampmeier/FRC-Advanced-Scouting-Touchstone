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
    
    private(set) var baseNavController: UINavigationController!
    private(set) var secondaryNavController: UINavigationController!
    private(set) var teamListTableVC: TeamListTableViewController!
    private(set) var teamDetailVC : TeamListDetailViewController!
    
//    private(set) lazy var teamListTableNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "teamListTableNav") as! UINavigationController
//    private(set) lazy var teamListTableVC: TeamListTableViewController = {
//        teamListTableNavigationController.topViewController as! TeamListTableViewController
//    }()
//    private(set) lazy var teamDetailNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "secondaryNav") as! UINavigationController
//    private(set) lazy var teamDetailVC = {
//        teamDetailNavigationController.topViewController as! TeamListDetailViewController
//    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamListTableVC = storyboard?.instantiateViewController(withIdentifier: "teamListTableView") as! TeamListTableViewController
        teamDetailVC = storyboard?.instantiateViewController(withIdentifier: "teamListDetail") as! TeamListDetailViewController
        
//        teamListTableVC.teamListSplitVC = self
        teamDetailVC.teamListSplitVC = self
        
        baseNavController = UINavigationController(rootViewController: teamListTableVC)
        secondaryNavController = UINavigationController(rootViewController: teamDetailVC)
        baseNavController.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
        self.viewControllers = [baseNavController, secondaryNavController]
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
        //Check to make sure these view controllers are what we expect
        guard let primaryNav = primaryViewController as? UINavigationController, let secondaryNav = secondaryViewController as? UINavigationController, primaryNav == baseNavController && secondaryNav == secondaryNavController else {
            return false
        }
        
        //Check if there's a team being shown
        if let _ = teamDetailVC.selectedTeam {
            //There is a team being shown, so put that view on top
            baseNavController.setViewControllers([teamListTableVC] + secondaryNavController.viewControllers, animated: false)
            self.viewControllers = [baseNavController]
            return true
        } else {
            baseNavController.setViewControllers([teamListTableVC], animated: false)
            self.viewControllers = [baseNavController]
            return true
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        //Check to make sure these view controllers are what we expect
        guard let primaryNav = primaryViewController as? UINavigationController, primaryNav == baseNavController else {
            return nil
        }
        
        var viewControllerStack = baseNavController.viewControllers
        //Remove the first view controller to be used in the baseNav and then put the rest in the secondaryNav
        baseNavController.viewControllers = [viewControllerStack.removeFirst()]
        if viewControllerStack.count == 0 {
            viewControllerStack = [teamDetailVC]
        }
        secondaryNavController.viewControllers = viewControllerStack
        
        return secondaryNavController
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        //Checks if the split view is collapsed or not. If collapsed, then conditionally push the vc's view controllers onto the primary stack.
        if self.isCollapsed {
            baseNavController.setViewControllers([teamListTableVC, vc], animated: true)
            return true
        } else {
            secondaryNavController.setViewControllers([vc], animated: true)
            return true
        }
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
