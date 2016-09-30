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
	
	var dataSource: TeamListSegmentsDataSource? {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(GameStatsController.reload), name: "TeamSelectedChanged" as NSNotification.Name, object: nil)
		}
	}
	
	private var contentWidth: CGFloat {
		let insets = collectionView!.contentInset
		return collectionView!.bounds.width - (insets.left + insets.right)
	}
	private var padding = 6
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Set collection view's data source and delegate
		collectionView.dataSource = self
		collectionView.delegate = self
		
		collectionView.backgroundColor = UIColor.white
		
		//Register cell for Collection View
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "teamCell")
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "matchCell")
	}
	
	func reload() {
		collectionView?.reloadData()
	}
	
	//---FUNCTIONS FOR GAME STATS---
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let performance = dataSource?.currentRegionalPerformance() {
			return (performance.matchPerformances?.count)! * 6 + (performance.matchPerformances?.count)!
		}
		
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		//Get the matches for selected team
		let matches: [Match] = dataSource?.currentMatchPerformances().map({$0.match!}).sorted(by: {($0.matchNumber?.int32Value)! < ($1.matchNumber?.int32Value)!}) ?? []
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamTrialCell", for: indexPath) as! GameStatsCollectionViewCell
		
		cell.tapDelegate = self
		
		if (indexPath as NSIndexPath).item % 7 == 0 {
			let matchNumber = matches[(indexPath as NSIndexPath).item/7].matchNumber
			//Set the matches label
			let label = cell.label
			label?.text = "\(matchNumber!)"
			
			//Make sure the background color is white
			cell.contentView.backgroundColor = nil
			label?.textColor = UIColor(white: 0, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 1 || (indexPath as NSIndexPath).item == 1 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			cell.label.text = (((matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 2 || (indexPath as NSIndexPath).item == 2 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			
			let filteredTeams = (matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 2})
			
			let matchPerformance = filteredTeams.first
			cell.label.text = (matchPerformance?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 3 || (indexPath as NSIndexPath).item == 3 {
			cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
			cell.label.text = (((matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 0 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 4 || (indexPath as NSIndexPath).item == 4 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 1}).first)?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 5 || (indexPath as NSIndexPath).item == 5 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 2}).first)?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else if (indexPath as NSIndexPath).item % 7 == 6 || (indexPath as NSIndexPath).item == 6 {
			cell.contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
			cell.label.text = (((matches[(indexPath as NSIndexPath).item/7 as Int].teamPerformances?.allObjects as! [TeamMatchPerformance]).filter({$0.allianceColor! == 1 && $0.allianceTeam! == 3}).first)?.regionalPerformance?.value(forKey: "team") as? Team)?.teamNumber
			cell.label.textColor = UIColor(white: 1, alpha: 1)
		} else {
			cell.label.text = nil
			cell.contentView.backgroundColor = nil
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		return CGSize(width: 95, height: 50)
		
		let columnWidth = collectionView.bounds.width / CGFloat(7)
		
		return CGSize(width: columnWidth, height: 50)
	}
}

extension GameStatsController: GameStatsCollectionViewCellTapDelegate {
	func gameStatsCellDidTap(onCell cell: UICollectionViewCell) {
//		//Find what row it is in
//		let indexPath = collectionView.indexPathForCell(cell)
//		if let item = indexPath?.item {
//			let row = item / 7
//			
//		}
	}
}
