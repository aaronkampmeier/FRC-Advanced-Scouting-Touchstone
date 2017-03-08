//
//  TeamListSplitViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 5/1/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamListSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    static var `default`: TeamListSplitViewController!

    var teamListTableVC: TeamListTableViewController {
        get {
            if let master = teamListMasterVC {
                return master
            } else if let master = self.viewControllers.first as? TeamListTableViewController {
                teamListMasterVC = master
                return master
            } else {
                teamListMasterVC = storyboard?.instantiateViewController(withIdentifier: "teamListTableView") as! TeamListTableViewController
                return teamListMasterVC!
            }
        }
        
        set {
            teamListMasterVC = newValue
        }
    }
    weak fileprivate var teamListMasterVC: TeamListTableViewController?
    
    var teamListDetailVC: TeamListDetailViewController {
        get {
            if let secondary = teamListSecondaryVC {
                return secondary
            } else if let secondary = self.viewControllers.last as? TeamListDetailViewController {
                teamListSecondaryVC = secondary
                return secondary
            } else {
                //There is none, create one
                teamListSecondaryVC = storyboard?.instantiateViewController(withIdentifier: "teamListDetail") as! TeamListDetailViewController
                return teamListSecondaryVC!
            }
        }
        
        set {
            teamListSecondaryVC = newValue
        }
    }
    fileprivate var teamListSecondaryVC: TeamListDetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TeamListSplitViewController.default = self
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

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let secondaryNav = secondaryViewController as? UINavigationController {
            if let teamDetail = secondaryNav.topViewController as? TeamListDetailViewController {
                self.teamListDetailVC = teamDetail
                if teamDetail.selectedTeam == nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        if let teamListTable = vc as? TeamListTableViewController {
            let primaryNav = UINavigationController(rootViewController: teamListTable)
            self.show(primaryNav, sender: self)
            return true
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        //Checks if the split view is collapsed or not. If it is then simply present the detail view controller because it will push onto self's navigation controller. If it isn't, then present the detail view controller in a navigation controller because it is actually a "split" view.
        if let teamListDetail = vc as? TeamListDetailViewController {
            //If the split view is collapsed then just show the detail view controller because it will be pushed onto self's nav stack. Otherwise present it with a nav controller.
            if !self.isCollapsed {
                let secondaryNav = UINavigationController(rootViewController: teamListDetail)
                self.showDetailViewController(secondaryNav, sender: self)
                return true
            } else {
                return false
            }
        } else {
            return false
        }
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
        
        if let matchSplitVC = splitViewController as? MatchOverviewSplitViewController {
            let detailNav = UINavigationController(rootViewController: matchSplitVC.matchesDetail!)
            
            self.setViewControllers([primaryContentVC], animated: true)
            return detailNav
        } else {
            var secondaryVCs = vcs
            let secondaryNav = storyboard?.instantiateViewController(withIdentifier: "secondaryNav") as! UINavigationController
            
            if secondaryVCs.isEmpty {
                secondaryVCs = [((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! TeamListSplitViewController).teamListDetailVC]
            }
            secondaryNav.setViewControllers(secondaryVCs, animated: false)
            self.setViewControllers([primaryContentVC], animated: false)
            return secondaryNav
        }
	}
}
