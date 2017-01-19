//
//  SSOffenseFuelViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit
import VerticalSlider

class SSOffenseFuelViewController: UIViewController {
    @IBOutlet weak var addFuelButton: UIButton!
    @IBOutlet weak var fuelTankSlider: VerticalSlider!
    
    var loadingWhereVC: SSOffenseWhereViewController! {
        didSet {
            loadingWhereVC.delegate = self
            loadingWhereVC.setUpWithButtons(buttons: [FuelLoadingLocations.Hopper.button, FuelLoadingLocations.LoadingStation.button, FuelLoadingLocations.Floor.button], time: 0)
        }
    }
    var scoringWhereVC: SSOffenseWhereViewController! {
        didSet {
            scoringWhereVC.delegate = self
            scoringWhereVC.setUpWithButtons(buttons: [FuelScoringLocations.HighGoal.button, FuelScoringLocations.LowGoal.button], time: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFuelButtonPressed(_ sender: UIButton) {
        loadingWhereVC.show()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier ?? "" {
        case "loadingWhereVC":
            loadingWhereVC = segue.destination as! SSOffenseWhereViewController
        case "scoringWhereVC":
            scoringWhereVC = segue.destination as! SSOffenseWhereViewController
        default:
            break
        }
    }
    
    enum FuelLoadingLocations: Int, CustomStringConvertible {
        case Hopper
        case LoadingStation
        case Floor
        
        var description: String {
            get {
                switch self {
                case .Hopper:
                    return "Hopper"
                case .LoadingStation:
                    return "Loading Station"
                case .Floor:
                    return "Floor"
                }
            }
        }
        
        var button: SSOffenseWhereViewController.Button {
            get {
                return SSOffenseWhereViewController.Button(title: self.description, color: .orange, id: self.rawValue)
            }
        }
    }
    
    enum FuelScoringLocations: Int, CustomStringConvertible {
        case LowGoal
        case HighGoal
        
        var description: String {
            switch self {
            case .LowGoal:
                return "Low Goal"
            case .HighGoal:
                return "High Goal"
            }
        }
        
        var button: SSOffenseWhereViewController.Button {
            get {
                return SSOffenseWhereViewController.Button(title: self.description, color: .orange, id: self.rawValue)
            }
        }
    }
}

extension SSOffenseFuelViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: Int) {
        
    }
}
