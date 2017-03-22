//
//  MatchOverviewSplitViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/5/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    static var `default`: MatchOverviewSplitViewController?
    
    var matchesMaster: MatchOverviewMasterViewController!
    var matchesDetail: MatchOverviewDetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        MatchOverviewSplitViewController.default = self
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let secondaryNav = secondaryViewController as? UINavigationController {
            if let matchDetail = secondaryNav.topViewController as? MatchOverviewDetailViewController {
                self.matchesDetail = matchDetail
                if matchDetail.dataSource?.match() == nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if let matchDetail = vc as? MatchOverviewDetailViewController {
            if !self.isCollapsed {
                let secondaryNav = UINavigationController(rootViewController: matchDetail)
                self.showDetailViewController(secondaryNav, sender: self)
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
