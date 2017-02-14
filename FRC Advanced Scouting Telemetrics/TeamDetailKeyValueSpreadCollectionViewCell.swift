//
//  TeamDetailKeyValueSpreadCollectionViewCell.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/11/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class TeamDetailKeyValueSpreadCollectionViewCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var values: [(String, String?)] = []
    
    func load(withTitle title: String, andValues values: [(String, String?)]) {
        titleLabel.text = title
        self.values = values
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyValue", for: indexPath)
        
        (cell.contentView.viewWithTag(1) as! UILabel).text = values[indexPath.item].0
        (cell.contentView.viewWithTag(2) as! UILabel).text = values[indexPath.item].1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 70)
    }
}
