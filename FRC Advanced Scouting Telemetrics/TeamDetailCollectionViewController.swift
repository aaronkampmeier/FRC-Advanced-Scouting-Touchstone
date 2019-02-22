//
//  TeamDetailCollectionViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import Crashlytics

let TeamDetailCollectionViewNeedsHeightResizing = NSNotification.Name("TeamDetailCollectionViewNeedsHeightResizing")


class TeamDetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var eventStats = [ScoutedTeamStat]()
    var scoutedTeam: ScoutedTeam?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 3
        
        collectionView?.isScrollEnabled = false
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.layoutIfNeeded()
    }
    
    func loadStats(forScoutedTeam scoutedTeam: ScoutedTeam?) {
        eventStats.removeAll()
        
        //Collect the stats
        self.eventStats = StatisticsDataSource().getStats(forType: ScoutedTeam.self)
        self.scoutedTeam = scoutedTeam
        
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
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
        return scoutedTeam != nil ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Globals.isInSpectatorMode {
            return 0
        } else {
            return eventStats.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyValue", for: indexPath) as! TeamDetailStatisticCell
        
        let stat = self.eventStats[indexPath.item]
        cell.load(forStatistic: stat, andScoutedTeam: self.scoutedTeam!)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Figure out the stat
        let stat = eventStats[indexPath.item]
        guard stat.hasCompositeTrend else {
            return
        }
        
        //Present the stat chart vc
        let chartVC = storyboard?.instantiateViewController(withIdentifier: "chartVC") as! StatChartViewController
        chartVC.setUp(forStatistic: stat, andScoutedTeam: self.scoutedTeam!)
        let navController = UINavigationController(rootViewController: chartVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
        
        Answers.logContentView(withName: "Team Stat Graph", contentType: "Graph", contentId: nil, customAttributes: ["Stat Graphed":stat.name])
    }
    
    //TODO: - Add back the header as a floating ui view
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch (indexPath.section, kind) {
//        case (_, UICollectionElementKindSectionFooter):
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
//            (footerView.viewWithTag(1) as! UIButton).setTitle("Show More Stats and Features by Signing In", for: .normal)
//            (footerView.viewWithTag(1) as! UIButton).addTarget(self, action: #selector(showFASTPromotional), for: .touchUpInside)
//
//            return footerView
//        default:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
//            (footerView.viewWithTag(1) as! UIButton).setTitle(nil, for: .normal)
//            (footerView.viewWithTag(1) as! UIButton).removeTarget(self, action: #selector(showFASTPromotional), for: .touchUpInside)
//            footerView.isHidden = true
//            return footerView
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 65)
    }
    
    @objc func showFASTPromotional() {
        let loginPromotional = storyboard!.instantiateViewController(withIdentifier: "loginPromotional")
        self.present(loginPromotional, animated: true, completion: nil)
        Answers.logContentView(withName: "Login Promotional", contentType: nil, contentId: nil, customAttributes: ["Source":"Team Detail Stats Collection View"])
    }
}

class TeamDetailStatisticCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var chartImageView: UIImageView!
    
    var stat: ScoutedTeamStat?
    var scoutedTeam: ScoutedTeam?
    
    func load(forStatistic stat: ScoutedTeamStat, andScoutedTeam scoutedTeam: ScoutedTeam) {
        self.stat = stat
        self.scoutedTeam = scoutedTeam
        titleLabel.text = nil
        valueLabel.text = nil
        hideImageView()
        
        titleLabel.text = stat.name
        
        stat.calculate(forObject: scoutedTeam) {value in
            //Check if this cell hasn't already been moved on to be reused with something else
            if self.scoutedTeam == scoutedTeam && self.stat?.id == stat.id {
                if self.valueLabel.text != value.description {
                    self.valueLabel.text = value.description
                }
            }
        }
        
        if stat.hasCompositeTrend {
            showImageView()
        } else {
            hideImageView()
        }
    }
    
    func hideImageView() {
        for constraint in chartImageView.constraints {
            if constraint.identifier == "width" {
                constraint.constant = 0
            }
        }
        chartImageView.isHidden = true
        chartImageView.updateConstraints()
    }
    
    func showImageView() {
        for constraint in chartImageView.constraints {
            if constraint.identifier == "width" {
                constraint.constant = 20
            }
        }
        chartImageView.isHidden = false
        chartImageView.updateConstraints()
    }
}
