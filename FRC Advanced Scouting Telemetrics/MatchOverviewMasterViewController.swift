//
//  MatchOverviewMasterViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class MatchOverviewMasterViewController: UIViewController {

    private var fastSplitViewController: FASTMainSplitViewController {
        get {
            return self.splitViewController as! FASTMainSplitViewController
        }
    }
    private var eventKey: String?
    private var selectedMatch: Match?
    
    var matchesTableVC: MatchesTableViewController?
    
    let viewIsLoadedSemaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        matchesTableVC = (self.children.first as! MatchesTableViewController)
        matchesTableVC?.delegate = self
        matchesTableVC?.tableView.allowsSelection = true
        
        let teamsButton = UIBarButtonItem(title: "Return to Teams", style: .plain, target: self, action: #selector(teamsPressed(_:)))
        if #available(iOS 13.0, *) {
//            teamsButton.image = UIImage(systemName: "arrowtriangle.left.fill")
        }
        setToolbarItems(nil, animated: false)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.leftBarButtonItems = [teamsButton]
        //Set the style of the navigation bar
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.titleTextAttributes = textAttributes
            appearance.largeTitleTextAttributes = textAttributes
            appearance.backgroundColor = UIColor.systemRed
            
            navigationItem.standardAppearance = appearance
            navigationItem.compactAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
            
            teamsButton.tintColor = .white
        }
        viewIsLoadedSemaphore.signal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    internal func load(forEventKey eventKey: String?) {
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.viewIsLoadedSemaphore.wait()
            self?.viewIsLoadedSemaphore.signal()
            DispatchQueue.main.async {
                self?.eventKey = eventKey
                self?.matchesTableVC?.load(forEventKey: eventKey)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func teamsPressed(_ sender: Any) {
        fastSplitViewController.switchToContentMode(.Teams)
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        let splitVC = self.fastSplitViewController
        splitVC.dismiss(animated: true, completion: nil)
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

extension MatchOverviewMasterViewController: MatchesTableViewControllerDelegate {
    func matchesTableViewController(_ matchesTableViewController: MatchesTableViewController, selectedMatchCell: UITableViewCell?, withAssociatedMatch associatedMatch: Match?) {
        fastSplitViewController.showDetailViewController(fastSplitViewController.matchOverviewDetailVC, sender: self)
        self.selectedMatch = associatedMatch
        fastSplitViewController.matchOverviewDetailVC.load(forMatchKey: associatedMatch?.key ?? "", shouldShowExitButton: false)
    }

    func hasSelectionEnabled() -> Bool {
        return true
    }
}
