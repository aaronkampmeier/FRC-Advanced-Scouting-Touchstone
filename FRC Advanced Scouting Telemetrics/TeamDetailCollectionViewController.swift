//
//  TeamDetailCollectionViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

let TeamDetailCollectionViewNeedsHeightResizing = NSNotification.Name("TeamDetailCollectionViewNeedsHeightResizing")

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
        }
    }
    
    var selectedTeamEventPerformance: TeamEventPerformance? {
        didSet {
            eventStats.removeAll()
            if let eventPerformance = selectedTeamEventPerformance {
                let possibleStats = TeamEventPerformance.StatName.allValues
                
                var values: [(String, String?, [TeamMatchPerformance.StatName])] = []
                
                for statName in possibleStats {
                    values.append((statName.description, eventPerformance.statValue(forStat: statName).description, statName.visualizableAssociatedStats))
                }
                
                eventStats = values
            }
            
            collectionView?.reloadData()
            collectionView?.layoutIfNeeded()
            
            NotificationCenter.default.post(name: TeamDetailCollectionViewNeedsHeightResizing, object: self, userInfo: nil)
        }
    }
    
    var detailValues: [(String, String?)] = []
    
    var eventStats: [(name: String, value: String?, visualizableMatchStats: [TeamMatchPerformance.StatName])] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize = CGSize(width: self.view.frame.width, height: 30)
        (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 3
        
        collectionView?.isScrollEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NotificationCenter.default.post(name: TeamDetailCollectionViewNeedsHeightResizing, object: self, userInfo: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.layoutIfNeeded()
        NotificationCenter.default.post(name: TeamDetailCollectionViewNeedsHeightResizing, object: self, userInfo: nil)
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
        } else if let _ = selectedTeam {
            return 1
        } else {
            return 0
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
            
            let chartImage = cell.viewWithTag(3) as! UIImageView
            chartImage.isHidden = true
            for constraint in chartImage.constraints {
                if constraint.identifier == "width" {
                    constraint.constant = 0
                }
            }
            chartImage.updateConstraints()
        case 1:
            let value = eventStats[indexPath.item]
            
            (cell.viewWithTag(1) as! UILabel).text = value.0
            let textLabel = cell.viewWithTag(2) as! UILabel
            textLabel.text = value.1
            
            let chartImage = cell.viewWithTag(3) as! UIImageView
            if value.visualizableMatchStats.count > 0 {
                for constraint in chartImage.constraints {
                    if constraint.identifier == "width" {
                        constraint.constant = 20
                    }
                }
                chartImage.isHidden = false
            } else {
                for constraint in chartImage.constraints {
                    if constraint.identifier == "width" {
                        constraint.constant = 0
                    }
                }
                chartImage.isHidden = true
            }
            chartImage.updateConstraints()
        default:
            break
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Figure out the stat
        if indexPath.section == 0 {
            //Team Stats, we don't select these so do nothing
        } else if indexPath.section == 1 {
            //Team Event Perf stats, okay make sure it has assoc stats
            let stat = eventStats[indexPath.item]
            guard stat.visualizableMatchStats.count > 0 else {
                return //Yeet
            }
            
            //Present the stat charting vc
            let chartVC = storyboard?.instantiateViewController(withIdentifier: "chartVC") as! StatChartViewController
            chartVC.setUp(forTeamPerformances: Array(selectedTeamEventPerformance!.matchPerformances), withStats: stat.visualizableMatchStats, andStatDescription: stat.name)
            let navController = UINavigationController(rootViewController: chartVC)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch (indexPath.section, kind) {
        case (0,UICollectionElementKindSectionHeader):
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            (headerView.viewWithTag(1) as! UILabel).text = "General"
            return headerView
        case (1, UICollectionElementKindSectionHeader):
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            (headerView.viewWithTag(1) as! UILabel).text = "\(selectedTeamEventPerformance?.event?.name ?? "") Stats"
            return headerView
        case (_, UICollectionElementKindSectionFooter):
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            (footerView.viewWithTag(1) as! UIButton).setTitle(nil, for: .normal)
            (footerView.viewWithTag(1) as! UIButton).removeTarget(self, action: #selector(viewShotChartPressed(_:)), for: .touchUpInside)

            return footerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 65)
    }
    
    @objc func viewShotChartPressed(_ sender: UIButton) {
        let shotChartNav = storyboard?.instantiateViewController(withIdentifier: "shotChartNav") as! UINavigationController
        (shotChartNav.topViewController as! ShotChartViewController).dataSource = self
        
        present(shotChartNav, animated: true, completion: nil)
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

extension TeamDetailCollectionViewController: ShotChartDataSource {
    func teamEventPerformance() -> TeamEventPerformance? {
        return selectedTeamEventPerformance
    }
}
