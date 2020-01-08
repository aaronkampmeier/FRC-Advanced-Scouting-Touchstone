//
//  SuperNotesCollectionViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/30/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase

private let reuseIdentifier = "notesCell"

class SuperNotesCollectionViewController: UICollectionViewController {
    
    var eventKey: String?
    var teamKeys = [String]()
    var scoutTeam: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        Globals.recordAnalyticsEvent(eventType: AnalyticsEventSelectContent, attributes: ["content_type":"screen", "item_id":"super_notes"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(inScoutTeam scoutTeam: String, forEventKey eventKey: String, withTeamKeys teamKeys: [String]) {
        self.eventKey = eventKey
        self.teamKeys = teamKeys
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if eventKey != nil {
            return 1
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamKeys.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SuperNotesCollectionViewCell
    
        //It is not possible to add a container view into a collection view cell from storyboard, so it has to be done manually
        //1. Create a notes viewcontroller and put it into the cell's variable to hold it
        cell.notesVC = self.storyboard?.instantiateViewController(withIdentifier: "commentNotesVC") as? TeamCommentsTableViewController
        
        //Set up the cell and notes vc for the team
        cell.setUp(inScoutTeam: scoutTeam ?? "", forEventKey: eventKey!, teamKey: teamKeys[indexPath.item])
        
        //2. Add the notesvc's view to the cell
        cell.notesVC.willMove(toParent: self)
        addChild(cell.notesVC)
        
        // 2.1. Have to turn off translates Autoresizing Mask Into Constraints to be able to add all the constraints programaticallly
        cell.notesVC.view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cell.notesVC.view)
        
        //3. Constrain the view
        NSLayoutConstraint.activate([
            cell.notesVC.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            cell.notesVC.view.topAnchor.constraint(equalTo: cell.teamLabel.bottomAnchor, constant: 10),
            cell.notesVC.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            cell.notesVC.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        cell.notesVC.didMove(toParent: self)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
