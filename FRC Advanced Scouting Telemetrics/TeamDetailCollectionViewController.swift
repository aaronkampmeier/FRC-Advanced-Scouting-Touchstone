//
//  TeamDetailCollectionViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var selectedTeam: Team? {
        didSet {
            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(withTeam team: Team?) {
        selectedTeam = team
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
    
        if let team = selectedTeam {
            switch indexPath.item {
            case 0:
                let tableCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionView", for: indexPath) as! TeamDetailKeyValueSpreadCollectionViewCell
                
                //General Team Info Cell
                let attendingEvents = (team.eventPerformances?.allObjects as! [TeamEventPerformance]).map() {eventPerformance in
                    return eventPerformance.event
                }
                //Create a string of all the attending events
                var eventString = ""
                
                for (index, event) in attendingEvents.enumerated() {
                    eventString += "\(event.name!)"
                    
                    if !(attendingEvents.count - 1 == index) {
                        eventString += ", "
                    }
                }
                
                let values: [(String,String?)] = [("Name",team.name), ("Location",team.location), ("Rookie Year",team.rookieYear?.description), ("Events Attending",eventString)]
                
                tableCell.load(withTitle: "General", andValues: values)
                
                tableCell.contentView.layer.borderWidth = 2
                tableCell.contentView.layer.borderColor = UIColor.green.cgColor
                tableCell.contentView.layer.cornerRadius = 30
                
                cell = tableCell
                
            default:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 600, height: 150)
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
