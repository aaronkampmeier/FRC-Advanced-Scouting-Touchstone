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
            detailValues.removeAll()
            if let team = selectedTeam {
                let possibleTeamStats = Team.StatName.teamDetailValues
                
                var values: [(String,String?)] = []
                
                for statName in possibleTeamStats {
                    values.append((statName.description,team.statValue(forStat: statName).description))
                }
                
                detailValues = values
            }
            
//            collectionView?.reloadData()
        }
    }
    
    var selectedTeamEventPerformance: TeamEventPerformance? {
        didSet {
            eventStats.removeAll()
            if let eventPerformance = selectedTeamEventPerformance {
                let possibleStats = TeamEventPerformance.StatName.allValues
                
                var values: [(String, String?)] = []
                
                for statName in possibleStats {
                    values.append((statName.description, eventPerformance.statValue(forStat: statName).description))
                }
                
                eventStats = values
            }
            
            collectionView?.reloadData()
        }
    }
    
    var detailValues: [(String, String?)] = []
    
    var eventStats: [(String, String?)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize = CGSize(width: self.view.frame.width, height: 30)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).invalidateLayout()
    }
    
    func load(withTeam team: Team?, andEventPerformance eventPerformance: TeamEventPerformance?) {
        selectedTeam = team
        selectedTeamEventPerformance = eventPerformance
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
        if let _ = selectedTeamEventPerformance {
            return 2
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch section {
        case 0:
            return detailValues.count
        case 1:
            return eventStats.count
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyValue", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let value = detailValues[indexPath.item]
            
            (cell.viewWithTag(1) as! UILabel).text = value.0
            (cell.viewWithTag(2) as! UILabel).text = value.1
        case 1:
            let value = eventStats[indexPath.item]
            
            (cell.viewWithTag(1) as! UILabel).text = value.0
            (cell.viewWithTag(2) as! UILabel).text = value.1
        default:
            break
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        
        switch indexPath.section {
        case 0:
            headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        case 1:
            (headerView.viewWithTag(1) as! UILabel).text = "Event: \(selectedTeamEventPerformance?.event.name ?? "") Stats"
        default:
            break
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 65)
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