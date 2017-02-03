//
//  PitScoutingViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 2/1/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

typealias PitScoutingUpdateHandler = ((Any?)->Void)
typealias PitScoutingCurrentValue = ()->Any?

class PitScoutingCell: UICollectionViewCell {
    func setUp(label: String, options: [String]?, updateHandler: @escaping PitScoutingUpdateHandler) {
        
    }
    func setValue(value: Any?) {
        
    }
}

class PitScoutingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var teamLabel: UILabel?
    @IBOutlet weak var teamNicknameLabel: UILabel?
    
    var scoutedTeam: Team? {
        didSet {
            collectionView?.reloadData()
            teamLabel?.text = scoutedTeam?.teamNumber
            teamNicknameLabel?.text = scoutedTeam?.nickname
        }
    }
    
    //An array of all the things to show in pit scouting 0. Type of Input 1. Label of Value 2. Array of options to be selected (can be nil for text field cells) 3. Closure returning current value 4. Closure updating stored varaible with new value
    var pitScoutingParameters: [(PitScoutingParameterType, String, [String]?, PitScoutingCurrentValue, PitScoutingUpdateHandler)] = []
    
    
    enum PitScoutingParameterType: String {
        case TextField = "pitTextFieldCell"
        case SegmentedSelector = "pitSegmentSelectorCell"
        case TableViewSelector = "pitTableViewCell"
        case ImageSelector = "pitImageSelectorCell"
        
        var cellID: String {
            return self.rawValue
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        pitScoutingParameters = [
            (.TextField, "Weight", nil, {self.scoutedTeam?.local.robotWeight?.intValue}, {newValue in
                if let intValue = newValue as? Int {
                    let number = NSNumber(integerLiteral: intValue)
                    self.scoutedTeam?.local.robotWeight = number
                } else {
                    self.scoutedTeam?.local.robotWeight = nil
                }
            })
        ]
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        teamLabel?.text = scoutedTeam?.teamNumber
        teamNicknameLabel?.text = scoutedTeam?.nickname
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager().commitChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pitScoutingParameters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let parameter = pitScoutingParameters[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: parameter.0.cellID, for: indexPath) as! PitScoutingCell
        
        cell.setUp(label: parameter.1, options: parameter.2, updateHandler: parameter.4)
        cell.setValue(value: parameter.3())
        
        return cell
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
