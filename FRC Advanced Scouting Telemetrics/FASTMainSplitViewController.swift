//
//  TeamListSplitViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

internal class FASTMainSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    //MARK: - View Controller Storage
    
    private(set) var baseNavController: UINavigationController!
    private(set) var secondaryNavController: UINavigationController!
    private(set) var teamListTableVC: TeamListTableViewController!
    private(set) var teamDetailVC : TeamListDetailViewController!
    private(set) var matchOverviewMasterVC: MatchOverviewMasterViewController!
    private(set) var matchOverviewDetailVC: MatchOverviewDetailViewController!
    
    private(set) var currentContentMode = FASTMainContentMode.Teams
    
    /// All the views that the base app can show in the split view, right now it is just Teams and Matches
    enum FASTMainContentMode {
        case Teams
        case Matches
        
        /// The master view controller for this mode
        /// - Parameter splitVC: The associated split view controller instance for the current UISceneSession
        fileprivate func masterVC(_ splitVC: FASTMainSplitViewController) -> UIViewController {
            switch self {
            case .Teams:
                return splitVC.teamListTableVC
            case .Matches:
                return splitVC.matchOverviewMasterVC
            }
        }
        
        fileprivate func detailVC(_ splitVC: FASTMainSplitViewController) -> UIViewController {
            switch self {
            case .Teams:
                return splitVC.teamDetailVC
            case .Matches:
                return splitVC.matchOverviewDetailVC
            }
        }
        
        /// Tells if the detail view is considered actively showing content, i.e. whether it should be displayed or not
        /// - Parameter splitVC: The split vc for the current UISceneSession
        fileprivate func isDetailActive(_ splitVC: FASTMainSplitViewController) -> Bool {
            switch self {
            case .Teams:
                // If the detail vc has a team selected then it is active
                return splitVC.teamDetailVC.selectedTeam != nil
            case .Matches:
                return splitVC.matchOverviewDetailVC.displayedMatch != nil
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        teamListTableVC = (storyboard.instantiateViewController(withIdentifier: "teamListTableView") as! TeamListTableViewController)
        teamDetailVC = (storyboard.instantiateViewController(withIdentifier: "teamListDetail") as! TeamListDetailViewController)
        matchOverviewMasterVC = (storyboard.instantiateViewController(withIdentifier: "matchMaster") as! MatchOverviewMasterViewController)
        matchOverviewDetailVC = (storyboard.instantiateViewController(withIdentifier: "matchOverviewDetail") as! MatchOverviewDetailViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    /// Switch the view controller over to showing a different base mode
    /// - Parameter newMode: The new content mode
    internal func switchToContentMode(_ newMode: FASTMainContentMode) {
        
        if newMode == .Teams && currentContentMode == .Matches {
            //When coming back from matches, give the appearance that the nav controller is popping instead of pushing. To do this, first insert the new master vc at the bottom of the view controller stack so that the nav controller will "pop" off the top.
            baseNavController.viewControllers = [newMode.masterVC(self), currentContentMode.masterVC(self)]
        }
        
        baseNavController.setViewControllers([newMode.masterVC(self)], animated: true)
        if !self.isCollapsed {
            secondaryNavController.setViewControllers([newMode.detailVC(self)], animated: false)
        }
        
        currentContentMode = newMode
    }
	
	internal func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
		return .all
	}
	
	internal func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
		return .automatic
	}
	
	internal func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
		
	}

    /// When the split view controller will go into a collapsed state, it will attempt to push the secondary vc onto the primary vc's nav controller stack.
    /// Because our secondary vc is a nav controller we need to instead push all of the secondary nav vcs onto the primary nav vcs.
    /// And then reverse this change when the split view controller is expanded. Reference: http://commandshift.co.uk/blog/2016/04/11/understanding-split-view-controller/
    
    internal func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //Check to make sure these view controllers are what we expect
        guard let primaryNav = primaryViewController as? UINavigationController, let secondaryNav = secondaryViewController as? UINavigationController, primaryNav == baseNavController && secondaryNav == secondaryNavController else {
            return false
        }
        
        if currentContentMode.isDetailActive(self) {
            //Show the detail's vcs on top as well
            baseNavController.setViewControllers([currentContentMode.masterVC(self)] + secondaryNav.viewControllers, animated: false)
            self.viewControllers = [baseNavController]
            return true
        } else {
            baseNavController.setViewControllers([currentContentMode.masterVC(self)], animated: false)
            self.viewControllers = [baseNavController]
            return true
        }
    }
    
    internal func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        //Check to make sure these view controllers are what we expect
        guard let primaryNav = primaryViewController as? UINavigationController, primaryNav == baseNavController else {
            return nil
        }
        
        var viewControllerStack = baseNavController.viewControllers
        //Remove the first view controller to be used in the baseNav and then put the rest in the secondaryNav
        baseNavController.viewControllers = [viewControllerStack.removeFirst()]
        if viewControllerStack.count == 0 {
            viewControllerStack = [currentContentMode.detailVC(self)]
        }
        secondaryNavController.viewControllers = viewControllerStack
        
        return secondaryNavController
    }
    
    
    internal func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        return false
    }
    
    internal func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        //Checks if the split view is collapsed or not. If collapsed, then conditionally push the vc's view controllers onto the primary stack.
        if self.isCollapsed {
            baseNavController.setViewControllers([currentContentMode.masterVC(self), vc], animated: true)
            return true
        } else {
            secondaryNavController.setViewControllers([vc], animated: true)
            return true
        }
    }
}
