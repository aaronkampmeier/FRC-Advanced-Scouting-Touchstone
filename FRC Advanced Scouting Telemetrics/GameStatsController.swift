//
//  GameStatsController.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/25/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

class GameStatsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var collectionView: UICollectionView!
	
	var teamListController: TeamListController?
	
	private var contentWidth: CGFloat {
		let insets = collectionView!.contentInset
		return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
	}
	private var padding = 6
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		teamListController = parentViewController as? TeamListController
		
		//Set collection view's data source and delegate
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.backgroundColor = UIColor.whiteColor()
		collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
		
		//Register cell for Collection View
		collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "teamCell")
		collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "matchCell")
	}
	
	func selectedNewThing(newTeamPerformance: TeamRegionalPerformance?) {
		collectionView.reloadData()
	}
	
	//---FUNCTIONS FOR GAME STATS---
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let performance = teamListController?.teamRegionalPerformance {
			return (performance.matchPerformances?.count)! * 6 + (performance.matchPerformances?.count)!
		}
		
		return 0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		//Get the matches for selected team
		let matches: [Match] = (teamListController?.teamRegionalPerformance?.matchPerformances!.allObjects as! [TeamMatchPerformance]).map({$0.match!}).sort({$0.matchNumber?.intValue < $1.matchNumber?.intValue})
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("teamTrialCell", forIndexPath: indexPath) as! GameStatsCollectionViewCell
		if indexPath.item % 7 == 0 {
			let matchNumber = matches[indexPath.item/7].matchNumber
			//Set the matches label
			let label = cell.label
			label.text = "\(matchNumber!)"
			
			//Make sure the background color is white
			cell.contentView.backgroundColor = nil
			label.textColor = UIColor(white: 0, alpha: 1)
		} else if indexPath.item % 7 == 1 || indexPath.item == 1 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if indexPath.item % 7 == 2 || indexPath.item == 2 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			
			let filteredTeams = (matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 2})
			
			let matchPerformance = filteredTeams.first
			cell.label.text = (matchPerformance?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			
			//			if filteredTeams.count > 0 {
			//				cell.label.text = (filteredTeams[0].regionalPerformance?.valueForKey("team") as! Team).teamNumber
			//			} else {
			//				cell.label.text = nil
			//			}
			
			//cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 2})[0]).regionalPerformance?.valueForKey("team") as! Team).teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if indexPath.item % 7 == 3 || indexPath.item == 3 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if indexPath.item % 7 == 4 || indexPath.item == 4 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if indexPath.item % 7 == 5 || indexPath.item == 5 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 2})[safe: 0])?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if indexPath.item % 7 == 6 || indexPath.item == 6 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[indexPath.item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.valueForKey("team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else {
			cell.label.text = nil
			cell.contentView.backgroundColor = nil
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: 95, height: 50)
		
		let columnWidth = contentWidth / CGFloat(7)
		
		return CGSize(width: columnWidth, height: 50)
	}
}
