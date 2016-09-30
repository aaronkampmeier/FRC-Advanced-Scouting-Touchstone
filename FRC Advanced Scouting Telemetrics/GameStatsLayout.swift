//
//  GameStatsLayout.swift
//  FRC Advanced Scouting Telemetrics
//
//  Created by Aaron Kampmeier on 2/25/16.
//  Copyright © 2016 Kampfire Technologies. All rights reserved.
//

import UIKit

protocol GameStatsLayoutDelegate {
	
}

class GameStatsLayout: UICollectionViewLayout {
	var delegate: GameStatsLayoutDelegate!
	
	var numberOfColumns = 7
	var numberOfMatches: Int!
	var cellPadding = 6
	
	private var cache = [UICollectionViewLayoutAttributes]()
	
	private var contentHeight: CGFloat  = 0.0
	private var contentWidth: CGFloat {
		let insets = collectionView!.contentInset
		return collectionView!.bounds.width - (insets.left + insets.right)
	}
	
	override func prepare() {
		_ = contentWidth / CGFloat(numberOfColumns)
		
	}
}
