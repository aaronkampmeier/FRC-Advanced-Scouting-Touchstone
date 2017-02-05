//
//  SSOffenseGearViewController.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 1/18/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

import UIKit

class SSOffenseGearViewController: UIViewController {
    @IBOutlet weak var addGearButton: UIButton!
    
    let ssDataManager = SSDataManager.currentSSDataManager()!
    
    var loadingWhereVC: SSOffenseWhereViewController! {
        didSet {
            loadingWhereVC.delegate = self
            loadingWhereVC.setUpWithButtons([GearLoadingLocations.LoadingStation.button(.purple), GearLoadingLocations.Floor.button(.purple)], time: 3)
        }
    }
    var mountingWhereVC: SSOffenseWhereViewController! {
        didSet {
            mountingWhereVC.delegate = self
            mountingWhereVC.setUpWithButtons([GearMountingLocations.Peg1.button(.purple), GearMountingLocations.Peg2.button(.purple), GearMountingLocations.Peg3.button(.purple)], time: 3)
        }
    }
    
    var hasLoadedGear: Bool = false {
        didSet {
            if hasLoadedGear {
                mountingWhereVC.show()
                addGearButton.isEnabled = false
            } else {
                mountingWhereVC.hide()
                addGearButton.isEnabled = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hasLoadedGear = ssDataManager.preloadedGear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addGearPressed(_ sender: UIButton) {
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
        case "mountingWhereVC":
            mountingWhereVC = segue.destination as! SSOffenseWhereViewController
        default:
            break
        }
    }
    
    enum GearLoadingLocations: String, CustomStringConvertible, FASTSSButtonable {
        case LoadingStation = "Loading Station"
        case Floor
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
    enum GearMountingLocations: String, CustomStringConvertible, FASTSSButtonable {
        case Peg1 = "Peg 1"
        case Peg2 = "Peg 2"
        case Peg3 = "Peg 3"
        
        var description: String {
            get {
                return self.rawValue
            }
        }
    }
    
}

extension SSOffenseGearViewController: WhereDelegate {
    func selected(_ whereVC: SSOffenseWhereViewController, id: String) {
        switch whereVC {
        case loadingWhereVC:
            ssDataManager.recordGearLoading(fromLocation: id, atTime: ssDataManager.stopwatch.elapsedTime)
            hasLoadedGear = true
        case mountingWhereVC:
            var mountedPeg = 0
            switch id {
            case "Peg 1":
                mountedPeg = 1
            case "Peg 2":
                mountedPeg = 2
            case "Peg 3":
                mountedPeg = 3
            default:
                assertionFailure()
            }
            ssDataManager.recordGearMounting(onPeg: mountedPeg, atTime: ssDataManager.stopwatch.elapsedTime)
            hasLoadedGear = false
        default:
            break
        }
    }
    
    func shouldSelect(_ whereVC: SSOffenseWhereViewController, id: String, handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
